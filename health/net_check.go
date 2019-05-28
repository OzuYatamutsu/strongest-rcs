package health

import (
	"context"
	"net"
	"time"

	"github.com/fatih/color"
)

const LookupHost = "www.icann.org"

func DnsIsOk() bool {
	timeoutCtx, cancel := context.WithTimeout(context.TODO(), time.Millisecond*1500) // ms
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
