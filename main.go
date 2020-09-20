package main

import (
	"os"
	"log"
	"github.com/progrium/go-basher"
	"github.com/azintelecom/azcloud-apps/utils"
)

func main() {
	bash, _ := basher.NewContext("/bin/bash", false)
	bash.ExportFunc("GetMyAddress", utils.GetMyAddress)
	bash.Source("modules/main", Asset)
	status, err := bash.Run("main", os.Args[1:])
	if err != nil {
		log.Fatal(err)
	}
	os.Exit(status)
}
