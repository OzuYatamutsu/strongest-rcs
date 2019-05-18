package main

import (
	"fmt"
	"gopkg.in/src-d/go-git.v4"
	"os"
	"os/user"
	"strconv"
	"strings"

	"github.com/fatih/color"
)

func getUsername() string {
	currentUser, _ := user.Current()
	return currentUser.Username
}

func getHostname() string {
	hostname, _ := os.Hostname()
	return strings.Split(hostname, ".")[0]
}

func getCwd() string {
	cwd, _ := os.Getwd()
	currentUser, _ := user.Current()
	return strings.Replace(cwd, currentUser.HomeDir, "~", -1)
}

func gitStatus() string {
	cwd, _ := os.Getwd()
	repo, err := git.PlainOpen(cwd)
	if err != nil {
		return ""
	}
	ref, _ := repo.Head()
	worktree, _ := repo.Worktree()
	status, _ := worktree.Status()
	if !status.IsClean() {
		numAdded, numChanged, numUntracked := 0, 0, 0
		deltaString := ""
		for _, line := range strings.Split(strings.TrimSuffix(status.String(), "\n"), "\n") {
			if strings.HasPrefix(line, "?") {
				numUntracked += 1
			}
			if !strings.HasPrefix(line, " "){
				numAdded += 1
			}
			if strings.HasPrefix(line, "MM") || strings.HasPrefix(line, " M") {
				numChanged += 1
			}
		}
		if numAdded > 0 {
			deltaString += color.GreenString("+") + strconv.FormatInt(int64(numAdded), 10)
		}
		if numChanged > 0 {
			deltaString += color.GreenString("Δ") + strconv.FormatInt(int64(numChanged), 10)
		}
		if numUntracked > 0 {
			deltaString += "…" + strconv.FormatInt(int64(numUntracked), 10)
		}
		return " (" + color.HiBlueString(ref.Name().Short()) +
			"|" + deltaString + ")"
	}

	return " (" + color.HiBlueString(ref.Name().Short()) + ")"
}

func prompt() {
	fmt.Printf("%s%s%s %s%s> \n",
		color.BlueString(getUsername()),
		color.BlueString("@"),
		color.BlueString(getHostname()),
		color.GreenString(getCwd()),
		gitStatus(),
	)
}

func main() {
	prompt()
}
