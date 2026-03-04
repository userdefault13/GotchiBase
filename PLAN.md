# gotchibase MVP — Planning Document

**Project:** gotchibase – Aavegotchi Ecosystem Simulator  
**Goal:** Microservices demo simulating core Aavegotchi mechanics (summon, stake, yield, rarity) using the target tech stack. All mocked locally — no real blockchain/money.  
**Target:** `docker-compose up` → full working sandbox + README + tests.

---

## 1. Scope Summary

| In Scope (MVP) | Out of Scope (Later) |
|----------------|----------------------|
| User registration, mock wallets (GHST, aDAI) | Full lending marketplace |
| Summon mock Aavegotchi (random traits, BRS) | Gotchiverse parcels |
| Stake collateral → simulated yield | Real Base chain listener |
| Stake / unstake / claim yield / equip wearable | |
| Double-entry ledger (immutable debits/credits) | Kinship/XP leveling |
| Dashboard: total staked, top rarity, yield earned | Full rarity farming |
| ETL → "Redshift" (Postgres proxy) | |

---

## 2. Architecture Overview

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   Rails API     │────▶│  Go Processor    │────▶│  Sinatra Reports │
│   (Port 3000)   │     │  (Port 8081)     │     │  (Port 4567)     │
│   Users, Gotchis│     │  Yield accrual   │     │  Leaderboards    │
│   Ledger, API  │     │  Event logs      │     │  Dashboards      │
└────────┬────────┘     └────────┬─────────┘     └────────┬────────┘
         │                      │                        │
         ▼                      ▼                        ▼
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│    Postgres      │     │     MongoDB       │     │ Redshift Proxy  │
│  (Port 5433)     │     │  (Transaction    │     │  (Port 5434)     │
│  Main relational │     │   event logs)    │     │  Analytics ETL   │
└─────────────────┘     └──────────────────┘     └─────────────────┘
```

**Data flow:**
1. **Rails** — Source of truth for users, wallets, Gotchis, ledger entries.
2. **Go Processor** — Polls/reads staked Gotchis, accrues yield, writes events to Mongo, calls Rails API to update balances.
3. **Sinatra** — Reads from Postgres for reports (leaderboards, dashboards).
4. **ETL** — Pulls from Mongo/Postgres, loads daily aggregates into Redshift proxy.

---

## 3. Tech Stack Checklist

| Component | Tech | Purpose |
|-----------|------|---------|
| Main API | Ruby on Rails + Postgres | Users, Gotchis, wallets, double-entry ledger |
| Transaction / Yield | Golang + MongoDB | High-perf yield accrual, event logs |
| Reports | Ruby Sinatra | Lightweight dashboards, leaderboards |
| Analytics | Golang ETL | Mock Redshift loader (Postgres wire-compat) |
| Orchestration | Docker + docker-compose | Full stack |
| Tests | RSpec, Go tests | Coverage target ~80% |

---

## 4. Phase Breakdown

### Phase 1: Repo & Docker Skeleton (1–2 hours)

**Tasks:**
- [ ] Create `gotchi-forge` repo
- [ ] Add `.gitignore` (Ruby, Go, Docker, IDE)
- [ ] Create `docker-compose.yml` with all services
- [ ] Create stub Dockerfiles for each service (even if empty initially)
- [ ] Verify `docker-compose up` brings up Postgres, Mongo, Redshift proxy

**Deliverable:** All containers start; no app logic yet.

---

### Phase 2: Rails Service — Core Models & API (2–4 days)

**Tasks:**
- [ ] `rails new . --api --database=postgresql` in `rails-app/`
- [ ] Models: `User`, `Wallet`, `Aavegotchi`, `Transaction`, `LedgerEntry`
- [ ] Migrations for all tables
- [ ] Double-entry logic: `Transaction#update_balances` → create `LedgerEntry` records
- [ ] API endpoints:
  - `POST /users` (register)
  - `POST /summon` (create Gotchi for user)
  - `POST /stake/:gotchi_id` (stake collateral)
  - `POST /unstake/:gotchi_id`
  - `POST /claim/:gotchi_id` (claim yield)
  - `POST /equip/:gotchi_id` (equip wearable)
  - `GET /gotchis/:id`
  - `GET /users/:id/wallets`
- [ ] Seed data: 5 users, 1000 mock GHST each, 2–3 Gotchis per user
- [ ] RSpec tests for models and controllers

**Schema notes:**
- `wallets`: `user_id`, `token_type` (ghst, adai), `balance`
- `aavegotchis`: `owner_id`, `base_rarity_score`, `collateral_value`, `traits` (JSONB)
- `transactions`: `aavegotchi_id`, `action_type`, `amount`, `metadata` (JSONB)
- `ledger_entries`: `transaction_id`, `account`, `debit`, `credit`

---

### Phase 3: Golang Processor — Yield & Events (2–3 days)

**Tasks:**
- [ ] `go mod init gotchibase/processor` in `go-processor/`
- [ ] Config: `MONGO_URI`, `RAILS_API_URL`, `INTERVAL` (seconds)
- [ ] Yield accrual loop: ticker every N seconds
- [ ] Fetch staked Gotchis (HTTP to Rails or direct Postgres)
- [ ] For each: `collateral *= (1 + dailyYieldRate)` → compute delta
- [ ] Insert event to Mongo: `{ type: "yield_accrued", gotchi_id, amount, ts }`
- [ ] Call Rails API to update balance / create claimable yield
- [ ] Mongo: capped collection for event logs (optional)
- [ ] Go tests for accrual logic

**Integration:** Go processor must know Rails base URL; Rails must expose an internal endpoint or shared DB access for "list staked Gotchis" + "apply yield".

---

### Phase 4: Sinatra Reports (1 day)

**Tasks:**
- [ ] `bundle init` in `sinatra-reports/`
- [ ] Add `sinatra`, `pg`, `json` gems
- [ ] Connect to Postgres (same DB as Rails or read replica)
- [ ] Endpoints:
  - `GET /leaderboard/rarity` — top 10 by BRS
  - `GET /dashboard` — total staked, total yield distributed, user count
  - `GET /leaderboard/yield` — top yield earners
- [ ] Return JSON

---

### Phase 5: ETL to "Redshift" (1 day)

**Tasks:**
- [ ] Golang binary in `etl-redshift/`
- [ ] Connect to Mongo + Postgres (read)
- [ ] Connect to Redshift proxy (Postgres)
- [ ] Create `daily_stats` table: `date`, `total_staked`, `avg_rarity`, `yield_distributed`, `gotchi_count`
- [ ] Run ETL: aggregate yesterday’s data, INSERT
- [ ] Support `--once` flag for manual/cron runs
- [ ] Wire into docker-compose (run on startup or cron)

---

### Phase 6: Polish & Deploy (1–2 days)

**Tasks:**
- [ ] Basic auth or JWT (Rails)
- [ ] Test coverage ~80%
- [ ] README: architecture diagram, setup instructions, "Why this matches fintech + blockchain"
- [ ] Optional: ASCII/pixel art for Gotchis, or link to Aavegotchi sprites
- [ ] Deploy to Render/Fly.io (free tier) for live demo link

---

## 5. Dependencies & Order

```
Phase 1 (Docker) ──────────────────────────────────────────────────────┐
     │                                                                  │
     ▼                                                                  │
Phase 2 (Rails) ──► Phase 3 (Go Processor) ──► Phase 5 (ETL)           │
     │                      │                                           │
     └──────────────────────┼──────────────────► Phase 4 (Sinatra)     │
                            │                                           │
                            └──────────────────────────────────────────┘
                                                                        │
Phase 6 (Polish) ◀──────────────────────────────────────────────────────┘
```

- **Rails** must be up before Go processor (needs API) and Sinatra (needs DB).
- **Go processor** must run before ETL has meaningful Mongo data.
- **Sinatra** can be developed in parallel with Go once Rails is stable.

---

## 6. Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Go ↔ Rails coupling too tight | Define clear API contract; consider event queue later |
| Double-entry bugs | Unit tests for every transaction type; audit trail in `ledger_entries` |
| ETL overwrites / duplicates | Use `ON CONFLICT` or upsert by `date` |
| Docker resource usage | Start only needed services during dev |
| Redshift proxy differs from real Redshift | Document that it's Postgres wire-compat; real Redshift would need schema tweaks |

---

## 7. Timeline Estimate

| Weekend | Focus |
|---------|-------|
| **1** | Phase 1 + Phase 2 (Docker + Rails core) |
| **2** | Phase 3 + Phase 4 (Go processor + Sinatra) |
| **3** | Phase 5 + Phase 6 (ETL + tests + README + deploy) |

**Total:** ~1–3 weeks part-time.

---

## 8. Success Criteria

- [ ] `docker-compose up --build` brings up full stack
- [ ] Can register user, summon Gotchi, stake, claim yield via API
- [ ] Ledger entries created for every financial action
- [ ] Sinatra leaderboard shows top rarity Gotchis
- [ ] ETL populates `daily_stats` in Redshift proxy
- [ ] README explains architecture and job-req alignment
- [ ] Live demo URL (Render/Fly.io) works

---

## 9. Future Extensions (Post-MVP)

- **Real Base listener** — Ingest real chain events for demo
- **Kinship/XP** — Leveling and rarity farming
- **Gotchiverse parcels** — Land/farming simulation
- **Fusion / ECS** — Entity-component style for future sim (stretch)
