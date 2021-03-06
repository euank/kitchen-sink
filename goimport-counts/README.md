# go-importstats

This program gives you a convenient way to compare how popular go packages are based on the number of unique packages that import them.

The packages that get counted are only those who have flipped on documentation on godoc.org, and furthermore all imports are deduped to the root vcs path.

Usage:

```
go build -o importers main.go

$ ./importers <<EOF
github.com/golang/glog
github.com/go-kit/kit/log
github.com/sirupsen/logrus
github.com/Sirupsen/logrus
go.uber.org/zap
EOF

# Go get some tea; it hits the package vcs in question to find the root vcs for
# all pkg imports.
# Because of vanity urls, some also timeout, and there's no parallelization.
# Omit 'glog' to make it faster
# ...

Results:
	1966	github.com/Sirupsen/logrus
	806	github.com/golang/glog
	70	github.com/go-kit/kit/log
	57	github.com/sirupsen/logrus
	20	go.uber.org/zap
