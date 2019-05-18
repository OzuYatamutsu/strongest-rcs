package main

import (
	"fmt"
	"github.com/fatih/color"
	"os"
	"os/user"
	"strings"
)

import "./health"
import "./plugins"

const CatHeader = `` +
`                          /:\` + "\n" +
`              __,---.__ /::::\` + "\n" +
"             `-.__     \\:::::/" + "\n" +
"              ;;:\\--.__`--.--._" + "\n" +
"            ,;;'` `    `--.__  `-._" + "\n" +
"            `,  ,\\       /,  `--.__;" + "\n" +
`            <   (o) ___ (o)   >` + "\n" +
`           <        \:/        >` + "\n" +
`            <     ._,"._,     >` + "\n" +
"    _.---._  `-.    ~~~    .-'" + "\n" +
"  .'._.--. `.   `~:~~~~~~:'" + "\n" +
"  `-'     `. `.  :        :" + "\n" +
`           :__: :________  :___` + "\n"

func getUsername() string {
	currentUser, _ := user.Current()
	return currentUser.Username
}

func getHostname() string {
	hostname, _ := os.Hostname()
	return strings.Split(hostname, ".")[0]
}

func printHeader() {
	fmt.Print(CatHeader)
	fmt.Println()

	fmt.Print("Yo! Welcome to " + color.BlueString("ＣＡＴＥＳＨＥＬＬ"))
	fmt.Print(" on " + color.MagentaString(getHostname()) + ", ")
	fmt.Print(color.BlueString(getUsername()) + "!\n")

	fmt.Print("It's currently " + color.GreenString("...TODO DATE") + ".\n")

	fmt.Print("You're running " + color.BlueString("... TODO OS") + ".\n")
}

func printHealthChecks() {
	fmt.Println(color.MagentaString("Status report!!"))
	fmt.Println(health.NetCheckColorizedOutput())
	fmt.Println(health.SpaceCheckColorizedOutput())
	fmt.Println(health.TimeOkColorizedOutput())
}

func main() {
	printHeader()
	fmt.Println()
	printHealthChecks()
	plugins.RunPlugins()
}
