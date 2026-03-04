package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

func getContext() context.Context {
	return context.Background()
}

const (
	defaultInterval   = 60
	defaultDailyRate  = 0.05 // 5% APY-ish for demo
	secondsPerDay     = 86400
)

type stakedGotchi struct {
	ID              int    `json:"id"`
	OwnerID         int    `json:"owner_id"`
	CollateralValue string `json:"collateral_value"`
	ClaimableYield  string `json:"claimable_yield"`
}

func main() {
	interval := getEnvInt("INTERVAL", defaultInterval)
	railsURL := getEnv("RAILS_API_URL", "http://rails-app:3000")
	mongoURI := getEnv("MONGO_URI", "mongodb://mongo:27017")

	mongoClient, err := mongo.Connect(getContext(), options.Client().ApplyURI(mongoURI))
	if err != nil {
		log.Fatalf("Mongo connect: %v", err)
	}
	defer mongoClient.Disconnect(getContext())

	coll := mongoClient.Database("gotchi_forge").Collection("yield_events")

	ticker := time.NewTicker(time.Duration(interval) * time.Second)
	log.Printf("Yield processor started (interval=%ds)", interval)

	for range ticker.C {
		if err := accrueYield(railsURL, coll); err != nil {
			log.Printf("Accrue yield error: %v", err)
		}
	}
}

func accrueYield(railsURL string, coll *mongo.Collection) error {
	gotchis, err := fetchStakedGotchis(railsURL)
	if err != nil {
		return fmt.Errorf("fetch gotchis: %w", err)
	}
	if len(gotchis) == 0 {
		log.Println("No staked Gotchis")
		return nil
	}

	for _, g := range gotchis {
		collateral, _ := strconv.ParseFloat(g.CollateralValue, 64)
		if collateral <= 0 {
			continue
		}

		// Yield = collateral * (daily_rate * interval / seconds_per_day)
		interval := float64(getEnvInt("INTERVAL", defaultInterval))
		rate := defaultDailyRate / 365
		delta := collateral * rate * (interval / secondsPerDay)

		if delta < 0.00000001 {
			continue
		}

		// Apply via Rails API
		if err := applyYield(railsURL, g.ID, delta); err != nil {
			log.Printf("Apply yield gotchi %d: %v", g.ID, err)
			continue
		}

		// Log to Mongo
		doc := bson.M{
			"type":           "yield_accrued",
			"gotchi_id":      g.ID,
			"amount":         delta,
			"collateral_at":  collateral,
			"ts":             time.Now().UTC(),
		}
		if _, err := coll.InsertOne(getContext(), doc); err != nil {
			log.Printf("Mongo insert: %v", err)
		}
	}

	log.Printf("Accrued yield for %d Gotchis", len(gotchis))
	return nil
}

func fetchStakedGotchis(baseURL string) ([]stakedGotchi, error) {
	resp, err := http.Get(baseURL + "/api/internal/staked_gotchis")
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("status %d", resp.StatusCode)
	}

	var gotchis []stakedGotchi
	if err := json.NewDecoder(resp.Body).Decode(&gotchis); err != nil {
		return nil, err
	}
	return gotchis, nil
}

func applyYield(baseURL string, gotchiID int, amount float64) error {
	body, _ := json.Marshal(map[string]interface{}{
		"gotchi_id": gotchiID,
		"amount":    fmt.Sprintf("%.8f", amount),
	})
	req, _ := http.NewRequest(http.MethodPost, baseURL+"/api/internal/apply_yield", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("status %d", resp.StatusCode)
	}
	return nil
}

func getEnv(k, def string) string {
	if v := os.Getenv(k); v != "" {
		return v
	}
	return def
}

func getEnvInt(k string, def int) int {
	if v := os.Getenv(k); v != "" {
		if i, err := strconv.Atoi(v); err == nil {
			return i
		}
	}
	return def
}
