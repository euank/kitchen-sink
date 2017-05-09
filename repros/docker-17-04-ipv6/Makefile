./repro: repro.go
	go build -tags netgo repro.go

.PHONY: push
push: ./repro
	docker build -t euank/ipv6-repro:latest .
	docker push euank/ipv6-repro:latest
