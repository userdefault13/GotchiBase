# Phase 5: Replace with full ETL build
FROM golang:1.22-alpine
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o etl .
CMD ["./etl", "--once"]
