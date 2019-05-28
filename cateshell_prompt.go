package main

import (
	"fmt"
	"os"
	"os/exec"
	"os/user"
	"runtime"
	"strconv"
	"strings"
)

func isWindows() bool {
	return runtime.GOOS == "windows"
}

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
	// cwd, _ := os.Getwd()
	/*repo, err := git.PlainOpen(cwd)
	if err != nil {
		return ""
	}
	ref, _ := repo.Head()
	worktree, _ := repo.Worktree()
	status, _ := worktree.Status()
    */
	// Call out to shell for num unpushed/unpulled commits
    rawStatus, _ := exec.Command("git", "log", "--porcelain").Output()
    rawBranch, _ := exec.Command("git", "rev-parse", "--abbrev-ref", "HEAD").Output()
	rawUnpushed, _ := exec.Command("git", "log", "--pretty=oneline", "@{u}..").Output()
	rawUnpulled, _ := exec.Command("git", "log", "--pretty=oneline", "..@{u}").Output()
    status := string(rawStatus)
    branch := strings.TrimSpace(string(rawBranch))
    numUnpushed := len(strings.Split(string(rawUnpushed), "\n")) - 1
    numUnpulled := len(strings.Split(string(rawUnpulled), "\n")) - 1
    deltaString := ""

    if numUnpushed > 0 {
        deltaString += "<GREEN><SYM:UP><RESET>" + strconv.FormatInt(int64(numUnpushed), 10)
    }
    if numUnpulled > 0 {
        deltaString += "<GREEN><SYM:DOWN><RESET>" + strconv.FormatInt(int64(numUnpulled), 10)
    }

    if len(strings.TrimSpace(status)) != 0 {
        numAdded, numChanged, numUntracked := 0, 0, 0

		for _, line := range strings.Split(strings.TrimSuffix(status, "\n"), "\n") {
			if strings.HasPrefix(line, "?") {
				numUntracked += 1
			}
			if !strings.HasPrefix(line, " ") && len(line) > 2 {
				numAdded += 1
			}
			if strings.HasPrefix(line, "MM") || strings.HasPrefix(line, " M") {
				numChanged += 1
			}
		}
		if numAdded > 0 {
			deltaString += "<GREEN><SYM:ADD><RESET>" + strconv.FormatInt(int64(numAdded), 10)
		}
		if numChanged > 0 {
			deltaString += "<GREEN><SYM:CHG><RESET>" + strconv.FormatInt(int64(numChanged), 10)
		}
		if numUntracked > 0 {
			deltaString += "<GREEN><SYM:UNTRACKED><RESET>" + strconv.FormatInt(int64(numUntracked), 10)
		}
	}


	if len(deltaString) > 0 {
		return " (<BOLD:BLUE>" + branch + "<RESET>" +
			"|" + deltaString + ")"
	}

	return " (<BOLD:BLUE>" + branch + "<RESET>)"
}

func prompt() {
	fmt.Printf("%s%s%s %s%s> \n",
		"<BLUE>"+getUsername(),
		"@",
		getHostname(),
		"<GREEN>"+getCwd(),
		"<RESET>"+gitStatus(),
	)
}

func main() {
	prompt()
}
