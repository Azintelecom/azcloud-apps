package main

import (
	"bytes"
	"compress/gzip"
	"fmt"
	"io"
	"strings"
)

func bindata_read(data []byte, name string) ([]byte, error) {
	gz, err := gzip.NewReader(bytes.NewBuffer(data))
	if err != nil {
		return nil, fmt.Errorf("Read %q: %v", name, err)
	}

	var buf bytes.Buffer
	_, err = io.Copy(&buf, gz)
	gz.Close()

	if err != nil {
		return nil, fmt.Errorf("Read %q: %v", name, err)
	}

	return buf.Bytes(), nil
}

var _modules_main = []byte("\x1f\x8b\x08\x00\x00\x00\x00\x00\x00\xff\x9c\x55\x6d\x4f\xe3\x38\x10\xfe\x9e\x5f\xf1\xac\xc9\xd2\x96\x55\x31\xac\xf6\xcb\x6d\x09\xb7\x5c\x81\xdb\x4a\x40\x11\x3d\xa4\xdb\xe3\x25\x72\x63\x97\x58\x1b\x92\xc8\x71\xca\x4b\x9b\xff\x7e\xb2\x9d\xbe\xd1\xa2\x5b\x9d\xfa\xc5\xf6\x4c\x9f\x99\x67\xe6\x99\xc9\xd6\x07\x5a\x16\x8a\x0e\x65\x4a\x45\x3a\xc6\x90\x15\xb1\xe7\x25\x19\xe3\xe1\x63\xc6\xcb\x44\x34\x5b\xde\xc4\x03\x92\x2c\x62\x09\x58\x9e\x87\x39\xd3\x71\x67\x7e\x0a\x88\xbf\x4f\x3c\x60\x0b\x45\x2c\x92\x24\x8a\x45\xf4\x13\x5c\x16\x6c\x98\x88\x60\xd0\xfd\xbc\xf7\xe5\x8b\x07\x8c\x32\x05\x07\x07\x99\xc2\x6f\x8e\x64\xca\x41\xfc\x19\x08\x41\x5b\xbf\xe4\x02\x23\x7c\x40\x3b\x65\x8f\x02\xb7\x3b\xbb\x45\x7c\xbb\xd3\xea\x80\x67\x1e\xf0\x2e\xfe\xfe\xde\x6f\x7b\xd6\x5e\x64\xa5\x8a\x04\x88\xef\xc2\x98\x94\x78\x96\x0a\xaf\xf2\xbc\x47\x26\xd3\x9a\x45\xc4\x0a\xe3\xb3\x4f\x20\x53\xfb\x37\x99\x16\x9a\x25\x49\xcb\x5e\x80\xa3\x7f\xba\x67\xfd\xeb\xe3\xf0\xe8\xf2\x72\x10\x9e\xf7\x8f\x4f\x82\xda\xa1\xb6\x8b\xe7\x3c\x53\x7a\xdd\x6d\xd3\xdf\xbf\xf7\xcf\x4f\x02\x3a\x66\x8a\x26\x72\x48\xd9\x6b\x1d\x71\x33\x88\x71\xae\xcd\x45\x2c\x47\xba\x3e\x73\x91\x27\xd9\x0b\x88\xff\x8d\xa0\xd3\xb1\x8f\x3b\xad\xf7\x6c\xa2\x60\x91\xe1\xeb\x0c\x35\xe3\x42\x68\xb4\x9f\xd7\x1a\x68\x0f\x5c\x2a\xf7\xa0\xb2\xe7\x17\xa8\x32\xad\x5b\xee\x79\x58\xed\x6f\x07\x37\x68\xbf\xae\x34\xec\x0e\xdb\xdb\x98\x40\x44\x71\x06\xc2\xf2\x1c\x69\xa6\x31\xca\xca\x94\x93\x0e\xc4\xb3\xd4\xd8\xef\xa0\x32\xc2\xa8\x23\x05\xc4\x6f\x22\x32\x5d\x6f\x82\x4b\x65\xbb\x4c\xfc\xc9\x1f\x47\x83\xef\xe1\xa0\x7f\x7d\xd5\x3d\xb9\xd9\xbb\xab\x08\x5a\x04\x87\xdb\xa0\x5c\x8c\x69\x5a\x26\x89\x09\x93\x3f\x71\xb4\xc8\x2a\xd6\xa4\x3e\x56\x94\xbd\x46\x49\x56\xf2\x90\xe5\x79\x41\xea\xcc\x8d\x8f\xbf\xa9\xc0\x4b\xc2\xc6\x12\x08\xa1\xee\xad\xa0\xe1\x98\x29\x69\xc4\x55\xfc\x92\xf7\xa8\x4c\x23\x2d\xb3\xb4\x30\x35\x93\x23\xdc\x80\xf8\x6b\xea\x20\x08\x66\xdd\xba\xeb\x40\xc7\xc2\x29\x61\x5e\x7a\x53\x9a\x88\xe9\xba\xbe\x5c\x2a\x42\x77\xad\xc1\x92\x9e\x0b\xe6\xf2\xaa\xff\xf7\x8f\x19\x75\x6b\xaf\x9c\xbd\x10\xda\xdd\xcd\xa4\x49\x93\xc9\x4a\x0a\xc7\xbd\xc1\x5f\x57\x26\xc6\x83\xd0\x21\x97\x85\x56\x72\x58\x9a\xa4\x43\xd3\x04\x1b\x63\x93\x24\xed\xdf\x3c\xcc\x5a\xbf\x6e\xab\x45\x30\x62\x9a\x25\x20\xdd\xac\x4c\xb8\x55\x01\x17\x5a\x44\x1a\xcb\x91\x60\x22\x91\xb5\xcc\xec\x88\x2c\x58\xbf\x93\x88\x6d\x9d\x93\x72\x99\x87\x5c\xe4\x22\xe5\x22\x8d\xa4\x28\x30\x9d\xae\x87\xb7\x6e\x58\x76\xb3\x81\xff\xb3\x97\xb3\xc2\x32\x1d\xdb\xba\x2e\xe6\x21\x58\x58\x28\xa5\x34\xac\x3a\xab\xc6\xc5\x85\xd2\x4f\x34\xac\xfe\x87\x16\xb6\xa0\x04\xe3\x30\x6e\xbb\xdd\xfe\xc5\x69\xef\x4f\xb3\x28\x7f\x1c\x9d\x9f\x81\xa5\x1c\x4a\xb8\xc2\x58\xdf\xb9\x42\x43\x9d\x85\xee\x3d\x68\xba\xad\xf0\x14\xcb\x44\xa0\x77\x3a\x08\x1a\x0d\x87\xd8\x56\xc6\x7f\xbe\x46\xe7\x15\x26\xfe\x64\xcc\xd4\xef\xb5\x82\x36\x82\x7e\x0a\x9a\xce\xab\x22\x0e\xdd\x2c\x54\x1c\x1c\x1c\x98\x19\x76\xcd\x70\xac\x17\x33\x63\x60\x17\xd5\xa8\x48\xcb\x96\xde\xed\xff\x31\x53\x86\x93\x83\x7c\x1b\xeb\xe6\xdb\x5d\x45\x96\xb2\x74\x44\x66\x0c\xb8\xc8\xc3\x55\x16\x80\x18\x9b\xb6\xfb\x93\xda\x36\x27\xb2\xcc\xb0\xb6\x7d\xfc\x18\xec\xcc\xed\xcb\x24\x1e\x94\xc8\xeb\x84\x9c\x8f\xb9\xac\x69\x6f\xe3\x76\xa0\x6f\x98\x62\x0a\x8b\xd6\x1e\xe3\x7e\x19\xb1\x1e\x61\xfb\x2d\x9a\x4d\x67\xdd\xec\xde\x45\xf7\xec\xda\x7e\x3b\x56\xd9\x3a\xc8\x39\xd9\x5f\x10\xee\xea\x37\x6f\x85\x5d\xbb\xa7\x62\x90\xfb\x2d\xec\xd4\xe1\xbe\x92\x8d\x28\x98\x82\x3d\xfd\x44\xfb\xf4\x2b\x1a\x93\x5c\xc9\x54\xc3\xbf\x38\xad\x1a\x98\x42\x2b\x34\xcc\xef\x36\x35\xb7\xc2\xd4\xb6\x5d\x9a\x93\xe0\x68\xd0\x7b\x9f\xf2\x86\x65\x69\x76\xef\xab\xd9\xc2\x21\xf1\x17\xa5\x21\x38\x3c\x7c\x3b\x08\xa6\xaa\x84\xb2\x3c\xdf\x4d\xb2\x07\x7c\x3e\xdc\xde\xf7\x2a\xef\xdf\x00\x00\x00\xff\xff\x77\x04\x09\x0d\x89\x08\x00\x00")

func modules_main() ([]byte, error) {
	return bindata_read(
		_modules_main,
		"modules/main",
	)
}

// Asset loads and returns the asset for the given name.
// It returns an error if the asset could not be found or
// could not be loaded.
func Asset(name string) ([]byte, error) {
	cannonicalName := strings.Replace(name, "\\", "/", -1)
	if f, ok := _bindata[cannonicalName]; ok {
		return f()
	}
	return nil, fmt.Errorf("Asset %s not found", name)
}

// AssetNames returns the names of the assets.
func AssetNames() []string {
	names := make([]string, 0, len(_bindata))
	for name := range _bindata {
		names = append(names, name)
	}
	return names
}

// _bindata is a table, holding each asset generator, mapped to its name.
var _bindata = map[string]func() ([]byte, error){
	"modules/main": modules_main,
}
// AssetDir returns the file names below a certain
// directory embedded in the file by go-bindata.
// For example if you run go-bindata on data/... and data contains the
// following hierarchy:
//     data/
//       foo.txt
//       img/
//         a.png
//         b.png
// then AssetDir("data") would return []string{"foo.txt", "img"}
// AssetDir("data/img") would return []string{"a.png", "b.png"}
// AssetDir("foo.txt") and AssetDir("notexist") would return an error
// AssetDir("") will return []string{"data"}.
func AssetDir(name string) ([]string, error) {
	node := _bintree
	if len(name) != 0 {
		cannonicalName := strings.Replace(name, "\\", "/", -1)
		pathList := strings.Split(cannonicalName, "/")
		for _, p := range pathList {
			node = node.Children[p]
			if node == nil {
				return nil, fmt.Errorf("Asset %s not found", name)
			}
		}
	}
	if node.Func != nil {
		return nil, fmt.Errorf("Asset %s not found", name)
	}
	rv := make([]string, 0, len(node.Children))
	for name := range node.Children {
		rv = append(rv, name)
	}
	return rv, nil
}

type _bintree_t struct {
	Func func() ([]byte, error)
	Children map[string]*_bintree_t
}
var _bintree = &_bintree_t{nil, map[string]*_bintree_t{
	"modules": &_bintree_t{nil, map[string]*_bintree_t{
		"main": &_bintree_t{modules_main, map[string]*_bintree_t{
		}},
	}},
}}
