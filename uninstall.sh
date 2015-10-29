#!/usr/bin/env bash
# NOTE: this script needs root
# NOTE: this script assumes no changes have been made to relevant files beyond
#   what the installation did, and so just deletes them all

. ./config.sh

systemctl unmask systemd-backlight@backlight\:intel_backlight.service
systemctl disable boot_backlight.service sleep-backlight.service
rm /etc/systemd/system/sleep-backlight.service \
  /etc/systemd/system/boot-backlight.service
systemctl daemon-reload

rm /etc/acpi/events/ac*plugged

rm -rf "$BATTERYDIM"
