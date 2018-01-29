package main

import (
	"fmt"
	"log"
	"net"
	"os"

	"golang.org/x/crypto/ssh/agent"
)

func main() {
	agentEnv := os.Getenv("SSH_AUTH_SOCK")
	if agentEnv == "" {
		log.Fatalf("SSH_AUTH_SOCK not set")
	}
	f, err := net.Dial("unix", agentEnv)
	if err != nil {
		log.Fatalf("could not connect to unix socket %q: %v", agentEnv, err)
	}
	agent := agent.NewClient(f)
	keys, err := agent.List()
	if err != nil {
		log.Fatalf("could not talk to ssh-agent: %v", err)
	}
	fmt.Printf("got %d keys:\n\n", len(keys))
	for _, key := range keys {
		fmt.Println(key.String())
	}
}
