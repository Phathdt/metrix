package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"time"
)

var start = time.Now()

func main() {
	http.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		resp := map[string]any{
			"status": "ok",
			"host":   mustHostname(),
			"uptime": time.Since(start).String(),
			"time":   time.Now().Format(time.RFC3339),
		}

		w.Header().Set("Content-Type", "application/json")
		_ = json.NewEncoder(w).Encode(resp)
	})

	addr := ":8080"
	if p := os.Getenv("PORT"); p != "" {
		addr = ":" + p
	}

	log.Printf("listening on %s", addr)
	if err := http.ListenAndServe(addr, nil); err != nil {
		log.Fatal(err)
	}
}

func mustHostname() string {
	h, _ := os.Hostname()
	return h
}
