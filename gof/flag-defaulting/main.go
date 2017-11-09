package main

import (
	"flag"
)

func main() {
	// The default flag package has incredibly lazy zero-value detection
	// https://github.com/golang/go/blob/840f2c/src/flag/flag.go#L402-L410
	flag.String("s1", "", "")
	flag.String("s2", "0", "")
	flag.String("s3", "false", "")
	flag.String("s4", "default", "")
	flag.Parse()
	flag.Usage()
}
