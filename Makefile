build:
	go get github.com/jteeuwen/go-bindata/...
	go-bindata modules
	go build -o core

