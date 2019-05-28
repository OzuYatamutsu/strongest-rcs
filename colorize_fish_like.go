package main

import (
	"fmt"
	"os"
	"regexp"
	"strings"
)

var IRColorSymMapFish = map[string]string {
	"<*BOLD>": "\u001b[1m",
	"<PURPLE>": "\u001b[34m",
	"<GREEN>": "\u001b[32m",
	"<WHITE>": "\u001b[37m",
	"<CYAN>": "\u001b[36m",
	"<RED>": "\u001b[31m",
	"<YELLOW>": "\u001b[33m",
	"<BLUE>": "\u001b[34m",
	"<MAGENTA>": "\u001b[35m",
	"<RESET>": "\u001b[0m",
	"<SYM:UP>": "↑",
	"<SYM:DOWN>": "↓",
	"<SYM:ADD>": "+",
	"<SYM:CHG>": "Δ",
	"<SYM:UNTRACKED>": "…",
}

func colorizeFish(rawString string) string {
	// Convert style types to their ascii prefixes
	boldRegex := regexp.MustCompile(`<BOLD:(.+?)>(.+?)($|<)`)
	rawString = boldRegex.ReplaceAllString(rawString, `<*BOLD><$1>$2<RESET>$3`)

	for ir, asciiCode := range IRColorSymMapFish {
		rawString = strings.Replace(rawString, ir, asciiCode, -1)
	}

	// Auto revert back to normal colors
	return IRColorSymMapFish["<RESET>"] + rawString + IRColorSymMapFish["<RESET>"]
}

func main() {
	fmt.Println(
		strings.Replace(
			colorizeFish(strings.Join(os.Args[1:], " ")),
			"\x1b",
			"\\x1b",
            -1,
		),
	)
}
