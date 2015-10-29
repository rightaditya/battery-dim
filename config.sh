#!/usr/bin/env bash

BATTERYDIM=/opt/battery-dim

# acpid unplug and plug events. to find these do acpi_listen, unplug the AC
# adapter, and note the event comes up; plug the AC adapter in and repeat
ACPI_UNPLUG="ac_adapter ACPI0003:00 00000080 00000000"
ACPI_PLUG="ac_adapter ACPI0003:00 00000080 00000001"

# Desired brightness as a percentage for unplug and plug states, respectively
UNPLUG_BRIGHTNESS=25
PLUG_BRIGHTNESS=100

# backlight device; it should show up in /sys/class/backlight
BACKLIGHT="/sys/class/backlight/intel_backlight"

# preserve backlight value between sleep/boot, assuming plug status hasn't
# changed?
# NOTE: this is currently unimplemented, because I don't really need it; it
# shouldn't be too hard to implement though
REMEMBER_STATE=true
STATEFILE=/tmp/acstate
