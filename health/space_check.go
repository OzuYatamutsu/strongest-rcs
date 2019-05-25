package health

import (
	"github.com/fatih/color"
	"strconv"
	"github.com/shirou/gopsutil/disk"
)

const SpaceCheckThresholdPercent = 80

func SpaceIsOk() (int, bool) {
	diskMetadata, _ := disk.Usage("/")
	return int(diskMetadata.UsedPercent), diskMetadata.UsedPercent <= SpaceCheckThresholdPercent
}

func SpaceCheckColorizedOutput() string {
	freeSpacePercent, isOk := SpaceIsOk()
	if isOk {
		return color.GreenString(" ✓ ") +
			"You have " + color.GreenString("plenty of space") + " on / (" +
			color.GreenString(strconv.FormatInt(int64(freeSpacePercent), 10) + "%") +
			" full)!"
	} else {
		return color.RedString(" ✗ ") +
			"You're " + color.RedString("runnin' out of space") + " on / (" +
			color.RedString(strconv.FormatInt(int64(freeSpacePercent), 10) + "%") +
			" full)!"
	}
}