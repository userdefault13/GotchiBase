# GotchiForge

**Aavegotchi Ecosystem Simulator** — A microservices demo simulating core Aavegotchi mechanics (summon, stake, yield, rarity) using a fintech-style stack. All mocked locally — no real blockchain or money.

## Quick Start

```bash
docker compose up --build
```

- **Rails API:** http://localhost:3000  
- **Sinatra Reports:** http://localhost:4567  
- **Go Processor:** http://localhost:8081 (internal)

## API Examples

```bash
# Register user
curl -X POST http://localhost:3000/api/users -H "Content-Type: application/json" -d '{"user":{"username":"alice"}}'

# Summon Gotchi (use user id from above)
curl -X POST http://localhost:3000/api/summon -H "Content-Type: application/json" -d '{"user_id":1}'

# Stake collateral
curl -X POST "http://localhost:3000/api/stake/1?amount=100"

# Claim yield
curl -X POST http://localhost:3000/api/claim/1

# Leaderboard
curl http://localhost:4567/leaderboard/rarity
curl http://localhost:4567/dashboard
```

## Tech Stack

| Service | Tech | Purpose |
|---------|------|---------|
| Main API | Rails + Postgres | Users, Gotchis, wallets, double-entry ledger |
| Processor | Golang + MongoDB | Yield accrual, event logs |
| Reports | Sinatra | Leaderboards, dashboards |
| Analytics | Golang ETL | Mock Redshift loader |

## Architecture

```
Rails (API) ──► Go Processor (yield) ──► Sinatra (reports)
     │                    │                     │
     ▼                    ▼                     ▼
  Postgres            MongoDB            Redshift Proxy
```

## MVP Features

- User registration + mock wallets (GHST, aDAI)
- Summon mock Aavegotchi (random traits, BRS)
- Stake collateral → simulated yield
- Stake / unstake / claim yield / equip wearable
- Double-entry ledger
- Leaderboards & basic reports
- ETL to analytics (Redshift proxy)

## Planning

See **[PLAN.md](./PLAN.md)** for the full phase-by-phase setup plan, schema notes, and timeline.

## Future

- **Real Base chain** — Ingest live events
- **Kinship/XP** — Full rarity farming

---

*Built to showcase monolith decomposition, financial reliability, and blockchain-adjacent flows — all fake/local. Ship it, fren! 👻*
