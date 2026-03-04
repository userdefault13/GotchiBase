package main

import (
	"context"
	"database/sql"
	"errors"
	"log"
	"os"
	"time"

	_ "github.com/lib/pq"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

func main() {
	redshiftURL := getEnv("REDSHIFT_URL", "postgres://postgres:password@localhost:5434/analytics")
	postgresURL := getEnv("POSTGRES_URL", "postgres://postgres:password@localhost:5433/gotchi_forge")
	mongoURI := getEnv("MONGO_URI", "mongodb://localhost:27017")

	ctx := context.Background()

	// Connect to Redshift proxy (Postgres)
	redshift, err := sql.Open("postgres", redshiftURL)
	if err != nil {
		log.Fatalf("Redshift connect: %v", err)
	}
	defer redshift.Close()

	// Connect to main Postgres
	pg, err := sql.Open("postgres", postgresURL)
	if err != nil {
		log.Fatalf("Postgres connect: %v", err)
	}
	defer pg.Close()

	// Connect to Mongo
	mongoClient, err := mongo.Connect(ctx, options.Client().ApplyURI(mongoURI))
	if err != nil {
		log.Fatalf("Mongo connect: %v", err)
	}
	defer mongoClient.Disconnect(ctx)

	runETL(ctx, redshift, pg, mongoClient)
	log.Println("ETL complete")
}

func runETL(ctx context.Context, redshift, pg *sql.DB, mongo *mongo.Client) {
	// Wait for Rails migrations (aavegotchis table) to exist
	if err := waitForSchema(ctx, pg); err != nil {
		log.Fatalf("Schema not ready: %v", err)
	}

	// Ensure daily_stats table exists
	_, err := redshift.Exec(`
		CREATE TABLE IF NOT EXISTS daily_stats (
			date DATE PRIMARY KEY,
			total_staked DOUBLE PRECISION,
			avg_rarity DOUBLE PRECISION,
			yield_distributed DOUBLE PRECISION,
			gotchi_count INTEGER,
			user_count INTEGER,
			created_at TIMESTAMP DEFAULT NOW()
		)
	`)
	if err != nil {
		log.Fatalf("Create table: %v", err)
	}

	date := time.Now().UTC().Truncate(24 * time.Hour)

	// Aggregate from Postgres
	var totalStaked, avgRarity float64
	var gotchiCount, userCount int
	err = pg.QueryRowContext(ctx, `
		SELECT
			COALESCE(SUM(a.collateral_value), 0),
			COALESCE(AVG(a.base_rarity_score), 0),
			COUNT(a.id),
			(SELECT COUNT(*) FROM users)
		FROM aavegotchis a
	`).Scan(&totalStaked, &avgRarity, &gotchiCount, &userCount)
	if err != nil {
		log.Fatalf("Postgres query: %v", err)
	}

	// Sum yield events from Mongo for today
	coll := mongo.Database("gotchi_forge").Collection("yield_events")
	startOfDay := time.Date(date.Year(), date.Month(), date.Day(), 0, 0, 0, 0, time.UTC)
	endOfDay := startOfDay.Add(24 * time.Hour)

	cur, err := coll.Find(ctx, bson.M{
		"ts": bson.M{
			"$gte": startOfDay,
			"$lt":  endOfDay,
		},
		"type": "yield_accrued",
	})
	if err != nil {
		log.Printf("Mongo find: %v", err)
	}

	var yieldDistributed float64
	for cur.Next(ctx) {
		var doc struct {
			Amount float64 `bson:"amount"`
		}
		if err := cur.Decode(&doc); err != nil {
			continue
		}
		yieldDistributed += doc.Amount
	}
	cur.Close(ctx)

	// Upsert into Redshift
	_, err = redshift.ExecContext(ctx, `
		INSERT INTO daily_stats (date, total_staked, avg_rarity, yield_distributed, gotchi_count, user_count)
		VALUES ($1, $2, $3, $4, $5, $6)
		ON CONFLICT (date) DO UPDATE SET
			total_staked = EXCLUDED.total_staked,
			avg_rarity = EXCLUDED.avg_rarity,
			yield_distributed = EXCLUDED.yield_distributed,
			gotchi_count = EXCLUDED.gotchi_count,
			user_count = EXCLUDED.user_count,
			created_at = NOW()
	`, date, totalStaked, avgRarity, yieldDistributed, gotchiCount, userCount)
	if err != nil {
		log.Fatalf("Insert: %v", err)
	}

	log.Printf("ETL: date=%s total_staked=%.2f avg_rarity=%.2f yield=%.6f gotchis=%d users=%d",
		date.Format("2006-01-02"), totalStaked, avgRarity, yieldDistributed, gotchiCount, userCount)
}

func getEnv(k, def string) string {
	if v := os.Getenv(k); v != "" {
		return v
	}
	return def
}

func waitForSchema(ctx context.Context, pg *sql.DB) error {
	const maxAttempts = 30
	const interval = 2 * time.Second
	for i := 0; i < maxAttempts; i++ {
		var exists bool
		err := pg.QueryRowContext(ctx, `
			SELECT EXISTS (
				SELECT 1 FROM information_schema.tables
				WHERE table_schema = 'public' AND table_name = 'aavegotchis'
			)
		`).Scan(&exists)
		if err == nil && exists {
			log.Println("Schema ready (aavegotchis table exists)")
			return nil
		}
		if err != nil {
			log.Printf("Schema check attempt %d: %v", i+1, err)
		}
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-time.After(interval):
			// retry
		}
	}
	return errors.New("aavegotchis table not found after max retries")
}
