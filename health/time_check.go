package health

import (
	"github.com/fatih/color"
	"time"
)

const HourBoundMin = 5
const HourBoundMax = 22

func TimeIsOk() bool {
	hour, _, _ := time.Now().Clock()
	return hour >= HourBoundMin && hour <= HourBoundMax
}

func TimeOkColorizedOutput() string {
	if TimeIsOk() {
		return color.GreenString(" ✓ ") +
			"It's " + color.GreenString("a good day for science") + "!"
	} else {
		return color.RedString(" ✗ ") +
			"It's " + color.RedString("late") + ". You should go to bed."
	}
}
