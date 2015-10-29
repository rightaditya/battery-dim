#!/usr/bin/env bash
# NOTE: this script needs root

# Read config
. /opt/battery-dim/config.sh

max=$(cat "$BACKLIGHT/max_brightness")

echo Setting brightness to $PLUG_BRIGHTNESS% of max.
echo $(($max * $PLUG_BRIGHTNESS / 100)) > "$BACKLIGHT/brightness"
