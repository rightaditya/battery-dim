#!/usr/bin/env bash
# NOTE: this script needs root

# Read config
. /opt/battery-dim/config.sh

max=$(cat "$BACKLIGHT/max_brightness")

echo Setting brightness to $UNPLUG_BRIGHTNESS% of max.
echo $(($max * $UNPLUG_BRIGHTNESS / 100)) > "$BACKLIGHT/brightness"
