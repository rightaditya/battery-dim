#!/usr/bin/env bash
# NOTE: this script needs root

# Read config
. /opt/battery-dim/config.sh

read max < "$BACKLIGHT/max_brightness"
tgt="$UNPLUG_BRIGHTNESS"

echo Setting brightness to $tgt% of max.
echo "(100*$MIN_BRIGHTNESS)+(100-$MIN_BRIGHTNESS)*$tgt)*$max/10000" | bc \
  > "$BACKLIGHT/brightness"
exit
max=$(cat "$BACKLIGHT/max_brightness")

echo Setting brightness to $UNPLUG_BRIGHTNESS% of max.
echo $(($max * $UNPLUG_BRIGHTNESS / 100)) > "$BACKLIGHT/brightness"
