package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"sort"
	"strings"

	"github.com/euank/kitchen-sink/goimport-counts/gddoapi"

	"golang.org/x/tools/go/vcs"
)

func main() {
	lines, err := ioutil.ReadAll(os.Stdin)
	if err != nil {
		log.Fatalf("Error reading input as packages: %v\n", err)
	}

	g := gddoapi.New()

	packages := strings.Split(string(lines), "\n")

	imports := map[string]map[string]struct{}{}
	for _, pkg := range packages {
		if pkg == "" {
			continue
		}
		imports[pkg] = make(map[string]struct{})
		res, err := g.Importers(pkg)
		if err != nil {
			log.Fatalf("error for %v: %v\n", pkg, err)
		}
		// dedupe based on reporoot
		for _, el := range res.Results {
			root, err := vcs.RepoRootForImportPath(el.Path, false)
			if err != nil {
				log.Printf("Err for %+v: %v\n", el, err)
				continue
			}
			imports[pkg][root.Root] = struct{}{}
		}
	}

	srs := []sr{}
	for pkg, importers := range imports {
		srs = append(srs, sr{
			pkg: pkg,
			num: len(importers),
		})
	}

	sort.Slice(srs, func(i, j int) bool {
		return srs[i].num > srs[j].num
	})

	fmt.Printf("Results:\n")
	for _, sr := range srs {
		fmt.Printf("\t%d\t%s\n", sr.num, sr.pkg)
	}
}

type sr struct {
	num int
	pkg string
}
