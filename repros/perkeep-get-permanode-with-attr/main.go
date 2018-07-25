package main

import (
	"context"
	"fmt"
	"log"
	"strings"

	"perkeep.org/pkg/client"
	"perkeep.org/pkg/schema"
	"perkeep.org/pkg/search"
)

func main() {
	c := client.NewOrFail()
	ctx := context.Background()

	permanode, err := c.UploadNewPermanode(ctx)
	if err != nil {
		log.Fatalf("making permanode: %v", err)
	}

	fileRef, err := c.UploadFile(ctx, "example file", strings.NewReader("example"), nil)
	if err != nil {
		log.Fatalf("uploading file: %v", err)
	}

	_, err = c.UploadAndSignBlob(ctx, schema.NewAddAttributeClaim(permanode.BlobRef, "camliContent", fileRef.String()))
	if err != nil {
		log.Fatalf("claiming content: %v", err)
	}
	_, err = c.UploadAndSignBlob(ctx, schema.NewAddAttributeClaim(permanode.BlobRef, "customMetadata", "someValue"))
	if err != nil {
		log.Fatalf("claiming content: %v", err)
	}

	fmt.Printf("getting permanode %s", permanode.BlobRef)
	claims, err := c.GetClaims(ctx, &search.ClaimsRequest{
		Permanode: permanode.BlobRef,
	})
	if err != nil {
		log.Fatalf("get claims: %v", err)
	}
	fmt.Printf("had claims: ")
	for _, claim := range claims.Claims {
		fmt.Printf("%s=%s, ", claim.Attr, claim.Value)
	}

	fmt.Println("getting permanodes that have customMetadata=someValue'")
	res, err := c.GetPermanodesWithAttr(ctx, &search.WithAttrRequest{
		Attr:  "customMetadata",
		Value: "someValue",
	})
	if err != nil {
		log.Fatalf("get permanodes: %v", err)
	}
	if res.Err() != nil {
		log.Fatalf("get permanodes2: %v", res.Err())
	}

	fmt.Printf("no error, got %v results\n", len(res.WithAttr))
}
