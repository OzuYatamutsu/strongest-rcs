package health

import (
	"context"
	"github.com/fatih/color"
	"net"
	"time"
)

const LookupHost = "www.icann.org"

func DnsIsOk() bool {
	timeoutCtx, cancel := context.WithTimeout(context.TODO(), time.Millisecond * 1000)  // ms
	defer cancel()
	var r net.Resolver
	_, err := r.LookupIPAddr(timeoutCtx, LookupHost)
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