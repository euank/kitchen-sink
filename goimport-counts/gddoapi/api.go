// Package gddoapi is a simplistic api for godoc.org.
// It is based on the documentation of the api found here:
// https://github.com/golang/gddo/wiki/API
package gddoapi

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
)

const baseUrl = "https://api.godoc.org"

type Result struct {
	Path     string `json:"path"`
	Synopsis string `json:"synopsis"`
}

type Import Result

type SearchResult struct {
	Results []Result `json:"results"`
}

type PackagesResult struct {
	Results []Result `json:"results"`
}

type ImportersResult struct {
	Results []Result `json:"results"`
}

type ImportsResult struct {
	Imports     []Import `json:"imports"`
	TestImports []Import `json:"testImports"`
}

type GDDO interface {
	Search(query string) (SearchResult, error)
	Packages() (PackagesResult, error)
	Importers(path string) (ImportersResult, error)
	Imports(path string) (ImportsResult, error)
}

type httpGetter interface {
	Get(string) (*http.Response, error)
}

type gddo struct {
	client httpGetter
}

func New() GDDO {
	return &gddo{http.DefaultClient}
}

func NewWithClient(c *http.Client) GDDO {
	return &gddo{c}
}

func (g *gddo) doquery(u *url.URL, into interface{}) error {
	resp, err := g.client.Get(u.String())
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if err := json.NewDecoder(resp.Body).Decode(into); err != nil {
		return fmt.Errorf("unable to decode response: %v", err)
	}
	return nil
}

func (g *gddo) Search(query string) (SearchResult, error) {
	u, err := url.Parse(fmt.Sprintf("%s/search", baseUrl))
	if err != nil {
		panic(err)
	}
	u.Query().Set("q", query)

	result := SearchResult{}
	err = g.doquery(u, &result)
	return result, err
}

func (g *gddo) Packages() (PackagesResult, error) {
	u, err := url.Parse(fmt.Sprintf("%s/packages", baseUrl))
	if err != nil {
		panic(err)
	}
	result := PackagesResult{}
	err = g.doquery(u, &result)
	return result, err
}

func (g *gddo) Importers(path string) (ImportersResult, error) {
	u, err := url.Parse(fmt.Sprintf("%s/importers/%s", baseUrl, url.PathEscape(path)))
	if err != nil {
		return ImportersResult{}, err
	}
	result := ImportersResult{}
	err = g.doquery(u, &result)
	return result, err
}

func (g *gddo) Imports(path string) (ImportsResult, error) {
	u, err := url.Parse(fmt.Sprintf("%s/imports/%s", baseUrl, url.PathEscape(path)))
	if err != nil {
		return ImportsResult{}, err
	}
	result := ImportsResult{}
	err = g.doquery(u, &result)
	return result, err
}
