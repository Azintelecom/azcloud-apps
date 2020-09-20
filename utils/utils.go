package utils

import (
	"net"
	"strings"
)


func IsIPv4(addr string) bool {
    return strings.Count(addr, ":") < 2
}

func GetMyAddress(ifaceName string) (string, error ) {
	iface, err := net.InterfaceByName(ifaceName)
	if err != nil {
		return "", err
	}
	addrs, err := iface.Addrs()
	if err != nil {
		return "", err
	}
	for _,addr := range addrs {
		i := strings.Split(addr.String(),"/")[0]
		if IsIPv4(i) {
			return i, nil
		}
	}
	return "", fmt.Errorf("no address found for interface")
}

