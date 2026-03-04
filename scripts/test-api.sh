#!/bin/bash
# Quick API smoke test (run after docker compose up)
set -e
BASE=${1:-http://localhost:3000}
REPORTS=${2:-http://localhost:4567}

echo "=== Rails API ==="
curl -s "$BASE/" | head -1
echo ""
curl -s -X POST "$BASE/api/users" -H "Content-Type: application/json" -d '{"user":{"username":"testuser"}}' | head -c 200
echo ""
curl -s "$BASE/api/gotchis/1" | head -c 200
echo ""

echo "=== Sinatra Reports ==="
curl -s "$REPORTS/leaderboard/rarity" | head -c 200
echo ""
curl -s "$REPORTS/dashboard" | head -c 200
echo ""

echo "=== Done ==="
