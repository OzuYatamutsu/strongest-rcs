package health

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"time"

	"github.com/fatih/color"
)

const LookupHost = "www.icann.org"
var client = http.Client{
	Timeout: 2 * time.Second,
}

func GetPublicIp() string {
	response, err := client.Get("https://ifconfig.me")
	if err != nil {
		// We probably don't have internet connection
		return ""
	}

	ipAddress, err := ioutil.ReadAll(response.Body)
	response.Body.Close()

	if err != nil {
		// We probably don't have internet connection
		return ""
	}

	return fmt.Sprintf("%s", ipAddress)
}

func GetGeoIpSummary(ipAddress string) string {
	var geoIpSummary map[string]interface{}
	response, err := client.Get(fmt.Sprintf("https://ipinfo.io/%s", ipAddress))
	if err != nil {
		// We probably don't have internet connection
		return ""
	}

	apiResponse, err := ioutil.ReadAll(response.Body)
	response.Body.Close()

	if err != nil {
		// We probably don't have internet connection
		return ""
	}

	json.Unmarshal(apiResponse, &geoIpSummary)
	return fmt.Sprintf("%s, %s, %s", geoIpSummary["city"], geoIpSummary["region"], geoIpSummary["country"])
}

func NetCheckColorizedOutput() string {
	ipAddress := GetPublicIp()
	if ipAddress == "" {
		return color.RedString(" ✗ ") +
			"Your internet connection looks " + color.RedString("degraded") + ", dood."
	}

	geoIpSummary := GetGeoIpSummary(ipAddress)
	if geoIpSummary == "" {
		return color.RedString(" ✗ ") +
			"Your internet connection looks " + color.RedString("degraded") + ", dood."
	}

	return color.GreenString(" ✓ ") +
		"Your public IP is " + color.GreenString(ipAddress) + " (" + color.GreenString(geoIpSummary) + ")"
}
