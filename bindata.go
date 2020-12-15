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

var _modules_main = []byte("\x1f\x8b\x08\x00\x00\x00\x00\x00\x00\xff\x8c\x52\xef\x4f\xdb\x30\x14\xfc\xee\xbf\xe2\x30\xa1\x6a\x99\x8a\x5b\xc4\x97\xa9\x6a\x25\x56\x90\x98\xb4\xa9\x88\x0e\x69\x1b\x20\xcb\x8d\x5d\x62\x2d\xd8\x56\xe2\xb0\x42\xc9\xff\x3e\x39\x69\x9b\x76\xd5\x7e\x7c\xb3\xfd\xce\xf7\xde\xdd\xbd\xc3\x03\x56\xe4\x19\x9b\x69\xc3\x94\x79\xc6\x4c\xe4\x09\x21\xa9\x15\x92\x3f\x59\x59\xa4\xaa\xdd\x21\x4b\x02\xa4\x36\x16\x29\x84\x73\xdc\x09\x9f\x0c\x36\xa7\x21\x8d\xfa\x94\x00\x87\xc8\x13\x95\xa6\x71\xa2\xe2\x1f\x90\x3a\x17\xb3\x54\x0d\xa7\xe3\xd3\xde\xd9\x19\x01\xe6\x36\x43\x4d\x07\x6d\x10\xb5\xe7\xda\x48\xd0\x68\x4d\x42\xd1\xf5\x2f\x4e\x61\x8e\x03\x74\x8d\x78\x52\xb8\x3f\x3e\xc9\x93\xfb\xe3\xce\x00\xd2\x12\xe0\x8f\xfc\xfd\xde\xfb\x5e\x55\xcf\x6d\x91\xc5\x0a\x34\xaa\xdb\x84\x91\xa4\x35\x8a\x94\x84\x3c\x09\x6d\x56\x2a\x72\xe5\xd1\x5d\xec\xc9\xa9\x0e\x52\x67\xf5\x43\x66\x17\x2f\xc8\x0a\xb3\x32\x80\x10\xec\xaa\x1d\xe0\x0e\xdd\xd7\x9d\xf1\x1f\xd0\x6a\x61\x09\x15\x27\x16\x54\x38\x07\x63\x3d\xe6\xb6\x30\x92\x0e\xa0\x16\xda\xa3\x3f\x40\xb9\x22\x92\x3a\x1b\xd2\xa8\x8d\x38\x58\xd0\x86\xd4\x59\x25\x99\x46\xcb\x0f\xe7\xd3\x2b\x3e\x9d\xdc\xde\x8c\x2f\xef\x7a\x0f\x25\x45\x87\x62\xd4\x02\x93\xea\x99\x99\x22\x4d\x43\x17\xf7\x53\xa2\x43\x77\xa8\x96\xab\x63\xc9\xc4\x6b\x9c\xda\x42\x72\xe1\x5c\x4e\x2b\x99\x9b\x1c\xb1\x85\xa3\xac\x7e\xcb\x19\x7f\x16\x99\x0e\x5e\xe6\xff\x85\x9e\x17\x26\xf6\xda\x9a\x7c\x63\x4a\x30\x2b\xa8\x89\x85\x5f\x39\x22\x75\x46\xd9\x49\x55\xa8\xe6\x54\x0b\x67\x33\x8f\xeb\x9b\xc9\xd7\x6f\xeb\x61\xab\x6a\x49\xeb\x44\xea\x5b\x60\x3c\xff\x3e\xfe\x34\xb9\xbd\xe0\xe7\xd7\xd7\x53\x7e\xf1\x71\xfa\xe5\x26\x50\x3f\x2a\xcf\xa5\xce\x7d\xa6\x67\x45\x68\xce\x83\x5d\xdb\xd4\x15\x92\x60\x1d\xcb\x3e\xcb\x2a\xa0\xb9\xf0\x22\x05\x1d\xdb\x22\x95\x55\x42\x52\x79\x15\x7b\x6c\x93\x23\x90\x53\x52\x4f\x56\x38\x2e\x95\x53\x46\x2a\x13\x6b\x95\xe3\xed\x6d\x9f\xa3\x82\x61\x1b\x56\xfd\xfe\xa7\x97\x6b\x27\x84\x4f\x2a\x23\x9a\x85\x1b\x36\x15\xc6\x18\xe3\xe5\x60\xb7\xd8\x5c\x18\x7b\xc7\x78\xd9\x0c\x5b\xbf\x36\x99\x86\xce\x0d\xfa\xe8\x88\x1f\x97\xf4\x2f\x22\x36\xff\xe8\x5e\x18\x57\x93\xcf\x97\xc3\x26\xdf\xc6\xfb\x3d\x54\xb5\x19\xaf\x61\x01\x39\x8d\x9a\xe6\x14\xa3\xd1\xef\xd9\x04\x38\x65\xc2\xb9\x93\xd4\x3e\xe2\x74\xd4\xea\x93\x92\xfc\x0a\x00\x00\xff\xff\x60\x1a\x89\x5c\x90\x04\x00\x00")

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
