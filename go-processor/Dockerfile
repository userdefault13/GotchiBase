# Phase 3: Replace with full Go build
FROM golang:1.22-alpine
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o processor .
CMD ["./processor"]
