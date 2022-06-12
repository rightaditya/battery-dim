#!/usr/bin/env bash

BATTERYDIM=/opt/battery-dim

# acpid unplug and plug events. to find these do acpi_listen, unplug the AC
# adapter, and note the event comes up; plug the AC adapter in and repeat
ACPI_UNPLUG="ac_adapter ACPI0003:00 00000080 00000000"
ACPI_PLUG="ac_adapter ACPI0003:00 00000080 00000001"

# Desired brightness as a percentage for unplug and plug states, respectively
UNPLUG_BRIGHTNESS=25
PLUG_BRIGHTNESS=100

# Minimum brightness; this is for aligning with the DE's increments; e.g.,
# GNOME's increments are 5% of the *usable* range, which it restricts to 1% of
# the maximum (on the low end)... the brightness keys therefore have an
# absolute delta of 5% * (100 - 1) = 4.95%
# Of course, this is moot if the (UN)PLUG_BRIGHTNESS values aren't multiples
# of 5...
MIN_BRIGHTNESS=1

# backlight device; it should show up in /sys/class/backlight
BACKLIGHT="/sys/class/backlight/intel_backlight"

# preserve backlight value between sleep/boot, assuming plug status hasn't
# changed?
# NOTE: this is currently unimplemented, because I don't really need it; it
# shouldn't be too hard to implement though
REMEMBER_STATE=false
STATEFILE=/tmp/acstate
