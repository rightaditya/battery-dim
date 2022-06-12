#!/usr/bin/env bash
# NOTE: this script needs root
# NOTE: required commands: acpi, acpi_listen (for user to set vars in config)

# adjust vars in config.sh (more instructions therein)
. ./config.sh
set -e

install -d "$BATTERYDIM"

cat > "$BATTERYDIM"/set-brightness.sh << EOF
#!/usr/bin/env bash

. "$BATTERYDIM"/config.sh
read max < "\$BACKLIGHT/max_brightness"

echo Setting brightness to \$1% of max.
echo "(100*\$MIN_BRIGHTNESS+(100-\$MIN_BRIGHTNESS)*\$1)*\$max/10000" | bc \\
  > "\$BACKLIGHT/brightness"
EOF

cat > "$BATTERYDIM"/plug-brightness.sh << EOF
#!/usr/bin/env bash

. "$BATTERYDIM"/config.sh
\$BATTERYDIM/set-brightness.sh "\$PLUG_BRIGHTNESS"
EOF

cat > "$BATTERYDIM"/unplug-brightness.sh << EOF
#!/usr/bin/env bash

. "$BATTERYDIM"/config.sh
\$BATTERYDIM/set-brightness.sh "\$UNPLUG_BRIGHTNESS"
EOF

cat > "$BATTERYDIM"/backlight.sh << EOF
#!/usr/bin/env bash

. "$BATTERYDIM"/config.sh

case \$1/\$2 in
  pre/*)
    # FIXME: UNIMPLEMENTED
    #if [[ \$REMEMBER_STATE ]]
    #then
    #  acpi -a | head -n 1 | cut -d ' ' -f 3 > \$STATEFILE
    #fi
  ;;
  post/*)
    # something used to override the setting if we didn't wait, but this
    # is no longer true, so this isn't necessary
    #if [[ "\$2" == "suspend" ]]
    #then
    #    sleep 0.5
    #fi

    state=\$(acpi -a | head -n 1 | cut -d ' ' -f 3)
    if [[ "\$state" == "on-line" ]]
    then
      echo AC adapter plugged after \$2...
      "$BATTERYDIM"/plug-brightness.sh
    elif [[ "\$state" == "off-line" ]]
    then
      echo AC adapter unplugged after \$2...
      "$BATTERYDIM"/unplug-brightness.sh
    fi
  ;;
esac
EOF

cat > "$BATTERYDIM"/uninstall.sh << EOF
#!/usr/bin/env bash
# NOTE: this script needs root
# NOTE: this script assumes no changes have been made to relevant files beyond
#   what the installation did, and so just deletes them all

. "$BATTERYDIM"/config.sh

systemctl unmask systemd-backlight@backlight:intel_backlight.service
systemctl disable boot_backlight.service sleep-backlight.service
# For unclear reasons (bug?), the sysinit.target.wants/boot-backlight.service
# link isn't removed like sleep.target.wants/sleep-backlight.service, so remove
# it manually
rm /usr/local/lib/systemd/system/sleep-backlight.service \\
  /usr/local/lib/systemd/system/boot-backlight.service \\
  /etc/systemd/system/sysinit.target.wants/boot-backlight.service
systemctl daemon-reload

rm /etc/acpi/events/ac_{,un}plugged

rm -rf "\$BATTERYDIM"
EOF

chmod 775 "$BATTERYDIM"/*.sh

install -m 644 -t "$BATTERYDIM" config.sh 

echo "event=$ACPI_UNPLUG" > /etc/acpi/events/ac_unplugged
echo "action=$BATTERYDIM/unplug-brightness.sh" >> /etc/acpi/events/ac_unplugged
echo "event=$ACPI_PLUG" > /etc/acpi/events/ac_plugged
echo "action=$BATTERYDIM/plug-brightness.sh" >> /etc/acpi/events/ac_plugged

install -d /usr/local/lib/systemd/system

cat > /usr/local/lib/systemd/system/boot-backlight.service << EOF
[Unit]
Description=Set Screen Backlight Brightness Based on AC Plug Status After Boot
DefaultDependencies=no
RequiresMountsFor=$BATTERYDIM
Conflicts=shutdown.target
After=systemd-remount-fs.service
Before=sysinit.target shutdown.target
Wants=acpid.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=$BATTERYDIM/backlight.sh post boot
ExecStop=$BATTERYDIM/backlight.sh pre boot
TimeoutSec=90s

[Install]
WantedBy=sysinit.target
EOF

cat > /usr/local/lib/systemd/system/sleep-backlight.service << EOF
[Unit]
Description=Set Screen Backlight Brightness Based on AC Plug Status After Sleep
DefaultDependencies=no
RequiresMountsFor=$BATTERYDIM
Before=sleep.target
StopWhenUnneeded=yes

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=$BATTERYDIM/backlight.sh pre suspend
ExecStop=$BATTERYDIM/backlight.sh post suspend
TimeoutSec=90s

[Install]
WantedBy=sleep.target
EOF

systemctl daemon-reload
systemctl enable boot-backlight.service sleep-backlight.service
systemctl restart acpid.service

# NOTE: this service may be different on different machines
systemctl mask --now systemd-backlight@backlight\:intel_backlight.service
