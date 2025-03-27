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

func GetPublicIpWithGeoIpSummary() (string, string, string, string) {
	var geoIpSummary map[string]interface{}
	response, err := client.Get(fmt.Sprintf("http://ipinfo.io/"))
    if err != nil {
		// We probably don't have internet connection
		return "", "", "", ""
	}

	apiResponse, err := ioutil.ReadAll(response.Body)
	response.Body.Close()
    if err != nil {
		// We probably don't have internet connection
		return "", "", "", ""
	}
	json.Unmarshal(apiResponse, &geoIpSummary)
	return geoIpSummary["ip"].(string), geoIpSummary["city"].(string), geoIpSummary["region"].(string), geoIpSummary["country"].(string)
}

func NetCheckColorizedOutput() string {
	ip, city, region, country := GetPublicIpWithGeoIpSummary()
	if ip == "" {
		return color.RedString(" ✗ ") +
			"Your internet connection looks " + color.RedString("degraded") + ", dood."
	}

	return color.GreenString(" ✓ ") +
		"Your public IP is " + color.GreenString(ip+" ("+fmt.Sprintf("%s, %s, %s", city, region, country)+")")
}
