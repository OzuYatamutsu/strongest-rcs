package main

import (
	"./health"
	"fmt"
)

func printHeader() {
	fmt.Println(health.NetCheckColorizedOutput())
	fmt.Println(health.SpaceCheckColorizedOutput())
	fmt.Println(health.TimeOkColorizedOutput())
}

func main() {
	printHeader()
}
