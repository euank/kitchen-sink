package main

import (
	"fmt"
	"net"
)

func main() {
	conn, _ := net.Listen("tcp", ":8080")
	_, err := net.Dial("tcp", conn.Addr().String())
	if err != nil {
		fmt.Printf("did not expect error, but got: %v", err)
	}
}
