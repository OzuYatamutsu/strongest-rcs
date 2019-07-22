package plugins

import (
	"fmt"
	"strconv"
	"time"

	"github.com/fatih/color"
)

func PluginDaysUntil() {
	targetDate := time.Date(2019, 10, 31, 0, 0, 0, 0, time.Local)
	currentDate := time.Now()
	daysUntil := targetDate.Sub(currentDate)

	fmt.Print(color.GreenString(" i ") + "There are ")
	fmt.Print(color.GreenString(strconv.FormatInt(int64(daysUntil.Hours()/24), 10)))
	fmt.Print(" days until " + color.GreenString(targetDate.Format("January 2, 2006")) + ".")
}
