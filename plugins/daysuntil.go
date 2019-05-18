package plugins

import (
	"fmt"
	"github.com/fatih/color"
	"strconv"
	"time"
)

func PluginDaysUntil() {
	targetDate := time.Date(2019, 7, 4, 0, 0, 0, 0, time.Local)
	currentDate := time.Now()
	daysUntil := targetDate.Sub(currentDate)

	fmt.Print(color.BlueString(" i ") + "There are ")
	fmt.Print(color.BlueString(strconv.FormatInt(int64(daysUntil.Hours() / 24), 10)))
	fmt.Print(" days until " + targetDate.String() + ".")
}