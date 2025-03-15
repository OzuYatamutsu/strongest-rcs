package main

import (
	"fmt"
	"os"
	"strings"
	"time"

	"github.com/OzuYatamutsu/strongest-rcs/health"
	"github.com/OzuYatamutsu/strongest-rcs/plugins"
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
			strings.Replace(
				strings.Replace(health.NetCheckColorizedOutput(), "✓", "+", -1),
				"✗", "x", -1,
			),
		)
		fmt.Println(
			strings.Replace(
				strings.Replace(health.SpaceCheckColorizedOutput(), "✓", "+", -1),
				"✗", "x", -1,
			),
		)
		fmt.Println(
			strings.Replace(
				strings.Replace(health.TimeOkColorizedOutput(), "✓", "+", -1),
				"✗", "x", -1,
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
