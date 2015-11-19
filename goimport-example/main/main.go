package main

import (
	"fmt"

	"fizzbuzz"
)

func main() {
	for s := range fizzbuzz.FizzBuzz() {
		fmt.Println(s)
	}
}
