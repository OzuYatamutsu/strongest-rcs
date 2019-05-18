package health

import (
	"github.com/fatih/color"
	"net"
)

const LookupHost = "www.icann.org"

func DnsIsOk() bool {
	_, err := net.LookupIP(LookupHost)
	if err != nil {
		// Lookup failed
		return false
	}

	return true
}

func NetCheckColorizedOutput() string {
	if DnsIsOk() {
		return color.GreenString(" ✓ ") +
			"Your internet connection looks " + color.GreenString("OK") + ", dood!"
	} else {
		return color.RedString(" ✗ ") +
			"Your internet connection looks " + color.RedString("degraded") + ", dood."
	}
}