package main

import (
	"fmt"
	"os"
	"regexp"
	"strings"
)

var IRColorSymMapBash = map[string]string{
	"<*BOLD>":         "\u001b[1m\\002",
	"<PURPLE>":        "\u001b[34m\\002",
	"<GREEN>":         "\u001b[32m\\002",
	"<WHITE>":         "\u001b[37m\\002",
	"<CYAN>":          "\u001b[36m\\002",
	"<RED>":           "\u001b[31m\\002",
	"<YELLOW>":        "\u001b[33m\\002",
	"<BLUE>":          "\u001b[34m\\002",
	"<MAGENTA>":       "\u001b[35m\\002",
	"<RESET>":         "\u001b[0m\\002",
	"<SYM:UP>":        "↑",
	"<SYM:DOWN>":      "↓",
	"<SYM:ADD>":       "+",
	"<SYM:CHG>":       "Δ",
	"<SYM:UNTRACKED>": "…",
}

func colorizeBash(rawString string) string {
	// Convert style types to their ascii prefixes
	boldRegex := regexp.MustCompile(`<BOLD:(.+?)>(.+?)($|<)`)
	rawString = boldRegex.ReplaceAllString(rawString, `<*BOLD><$1>$2<RESET>$3`)

	for ir, asciiCode := range IRColorSymMapBash {
		rawString = strings.Replace(rawString, ir, asciiCode, -1)
	}

	// Auto revert back to normal colors
	return IRColorSymMapBash["<RESET>"] + rawString + IRColorSymMapBash["<RESET>"]
}

func main() {
	fmt.Println(
		strings.Replace(
			colorizeBash(strings.Join(os.Args[1:], " ")),
			"\x1b",
			"\\002\\x1b",
			-1,
		),
	)
}
