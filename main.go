package main

import (
	"os"
	"log"
	"github.com/progrium/go-basher"
)

func main() {
	bash, _ := basher.NewContext("/bin/bash", false)

	bash.Source("modules/main", Asset)
	status, err := bash.Run("main", os.Args[1:])
	if err != nil {
		log.Fatal(err)
	}
	os.Exit(status)
}
