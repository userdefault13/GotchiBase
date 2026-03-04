# GotchiForge — Project Structure

```
gotchi-forge/
├── PLAN.md              # Full planning document (phases, schema, timeline)
├── README.md            # Project overview & quick start
├── STRUCTURE.md         # This file
├── docker-compose.yml   # Full orchestration (Phase 1)
│
├── rails-app/           # Main API (Phase 2)
│   ├── app/
│   │   ├── models/
│   │   │   ├── user.rb
│   │   │   ├── wallet.rb
│   │   │   ├── aavegotchi.rb
│   │   │   ├── transaction.rb
│   │   │   └── ledger_entry.rb
│   │   └── controllers/
│   │       └── api/
│   ├── db/
│   │   ├── migrate/
│   │   └── seeds.rb
│   ├── Dockerfile
│   └── Gemfile
│
├── go-processor/        # Yield & events (Phase 3)
│   ├── main.go
│   ├── processor.go
│   ├── go.mod
│   ├── Dockerfile
│   └── *_test.go
│
├── sinatra-reports/     # Dashboards (Phase 4)
│   ├── app.rb
│   ├── Gemfile
│   ├── Dockerfile
│   └── config.ru
│
└── etl-redshift/        # Analytics ETL (Phase 5)
    ├── main.go
    ├── etl.go
    ├── go.mod
    ├── Dockerfile
    └── *_test.go
```

## Data Flow

1. **Rails** — Source of truth. All user/Gotchi/wallet/ledger data in Postgres.
2. **Go Processor** — Polls Rails (or Postgres) for staked Gotchis → accrues yield → writes events to Mongo → calls Rails to update balances.
3. **Sinatra** — Reads Postgres for reports. No writes.
4. **ETL** — Reads Mongo + Postgres → writes daily aggregates to Redshift proxy (Postgres).

## Ports

| Service        | Port | Purpose                    |
|----------------|------|----------------------------|
| Rails          | 3000 | Main API                   |
| Sinatra        | 4567 | Reports / leaderboards     |
| Go Processor   | 8081 | Internal (health, metrics) |
| Postgres       | 5433 | Main DB (exposed for tools)|
| Redshift proxy | 5434 | Analytics DB               |
| Mongo          | 27017| Event logs (internal)      |
