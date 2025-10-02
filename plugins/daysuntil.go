package plugins

import (
	"fmt"
	"strconv"
	"time"

	"github.com/fatih/color"
)

func PluginDaysUntil() {
	targetDate := time.Date(2025, 10, 14, 0, 0, 0, 0, time.Local)
	currentDate := time.Now()
	daysUntil := targetDate.Sub(time.Date(
        currentDate.Year(), currentDate.Month(), currentDate.Day(),
        0, 0, 0, 0, currentDate.Location(),
    ))

	fmt.Print(color.GreenString(" i ") + "There are ")
	fmt.Print(color.GreenString(strconv.FormatInt(int64(daysUntil.Hours()/24), 10)))
	fmt.Print(" days until " + color.GreenString(targetDate.Format("January 2, 2006")) + ".")
}
