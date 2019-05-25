package main

import (
	"fmt"
	"os"
	"os/user"
	"runtime"
	"strings"
	"time"

	"./health"
	"./plugins"
	"github.com/fatih/color"
)

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

func isWindows() bool {
	return runtime.GOOS == "windows"
}

func printHeader(versionString string) {
	fmt.Print(CatHeader)
	fmt.Println()

	if !isWindows() {
		fmt.Print("Yo! Welcome to " + color.BlueString("ＣＡＴＥＳＨＥＬＬ"))
	} else {
		fmt.Print("Yo! Welcome to " + color.CyanString("C A T E S H E L L"))
	}
	fmt.Print(" on " + color.MagentaString(getHostname()) + ", ")
	if !isWindows() {
		fmt.Print(color.BlueString(getUsername()) + "!\n")
	} else {
		fmt.Print(color.CyanString(getUsername()) + "!\n")
	}

	fmt.Print("It's currently " + color.GreenString(time.Now().Format(
		"Monday, January 2, 2006 at 03:04:05 PM MST"),
	) + ".\n")

	if !isWindows() {
		fmt.Print("You're running " + color.BlueString(versionString) + ".\n")
	} else {
		fmt.Print("You're running " + color.CyanString(versionString) + ".\n")
	}
}

func printHealthChecks() {
	fmt.Println(color.MagentaString("Status report!!"))
	if !isWindows() {
		fmt.Println(health.NetCheckColorizedOutput())
		fmt.Println(health.SpaceCheckColorizedOutput())
		fmt.Println(health.TimeOkColorizedOutput())
	} else {
		fmt.Println(
			strings.ReplaceAll(
				strings.ReplaceAll(health.NetCheckColorizedOutput(), "✓", "+"),
				"✗", "x",
			),
		)
		fmt.Println(
			strings.ReplaceAll(
				strings.ReplaceAll(health.SpaceCheckColorizedOutput(), "✓", "+"),
				"✗", "x",
			),
		)
		fmt.Println(
			strings.ReplaceAll(
				strings.ReplaceAll(health.TimeOkColorizedOutput(), "✓", "+"),
				"✗", "x",
			),
		)
	}

}

func main() {
	printHeader(os.Args[1])
	fmt.Println("")
	printHealthChecks()
	plugins.RunPlugins()
	fmt.Println("")
	fmt.Println("")
	fmt.Println("What will your " + color.MagentaString("first sequence of the day") + " be?")
}
