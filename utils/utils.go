package utils

import (
	"net"
	"strings"
	"fmt"
)


func IsIPv4(addr string) bool {
    return strings.Count(addr, ":") < 2
}

func GetMyAddress(ifaceName []string) {
	iface, err := net.InterfaceByName(ifaceName[0])
	if err != nil {
		fmt.Println()
	}
	addrs, err := iface.Addrs()
	if err != nil {
		fmt.Println()
	}
	for _,addr := range addrs {
		i := strings.Split(addr.String(),"/")[0]
		if IsIPv4(i) {
			fmt.Println(i)
		}
	}
}

func GetNetworkFromAddress(addr []string) {
	_, ipnet, err := net.ParseCIDR(addr[0])
	if err != nil {
		fmt.Println("")
		return
	}
	fmt.Println(ipnet)
}
