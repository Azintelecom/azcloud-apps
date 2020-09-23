package main

import (
	"os"
	"log"
	"github.com/progrium/go-basher"
	"github.com/azintelecom/azcloud-apps/utils"
	"github.com/azintelecom/azcloud-apps/applications"
)

func main() {
	if os.Args[1] == "simple_go_app" {
		applications.SimpleGoApp()
		os.Exit(0)
	}

	bash, _ := basher.NewContext("/bin/bash", false)
	bash.Export("PATH","/root/bin:bin:/usr/bin:/sbin:/usr/sbin:/usr/local/sbin")
	bash.ExportFunc("GetMyAddress", utils.GetMyAddress)
	if 	bash.HandleFuncs(os.Args) {
		os.Exit(0)
	}
	bash.Source("modules/main", Asset)
	status, err := bash.Run("main", os.Args[1:])
	if err != nil {
		log.Fatal(err)
	}
	os.Exit(status)
}
