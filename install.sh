#!/usr/bin/env bash
# NOTE: this script needs root
# NOTE: required commands: acpi, acpi_listen (for user to set vars in config)

# adjust vars in config.sh (more instructions therein)
. ./config.sh

install -d "$BATTERYDIM"
install -m 644 -t "$BATTERYDIM" config.sh 

install -m 755 -t "$BATTERYDIM" plug-brightness.sh unplug-brightness.sh \
    uninstall.sh

cat > "$BATTERYDIM"/backlight.sh << EOF
#!/usr/bin/env bash

. "$BATTERYDIM"/config.sh

case \$1/\$2 in
    pre/*)
        # FIXME: UNIMPLEMENTED
        #if [[ \$REMEMBER_STATE ]]
        #then
        #    acpi -a | head -n 1 | cut -d ' ' -f 3 > \$STATEFILE
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
chmod 775 "$BATTERYDIM"/backlight.sh

echo "event=$ACPI_UNPLUG" > /etc/acpi/events/ac_unplugged
echo "action=$BATTERYDIM/unplug-brightness.sh" >> /etc/acpi/events/ac_unplugged
echo "event=$ACPI_PLUG" > /etc/acpi/events/ac_plugged
echo "action=$BATTERYDIM/plug-brightness.sh" >> /etc/acpi/events/ac_plugged

cat > /etc/systemd/system/boot-backlight.service << EOF
[Unit]
Description=Set Screen Backlight Brightness Based on AC Plug Status After Boot
DefaultDependencies=no
RequiresMountsFor=$BATTERYDIM
Conflicts=shutdown.target
After=systemd-remount-fs.service
Before=sysinit.target shutdown.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=$BATTERYDIM/backlight.sh post boot
ExecStop=$BATTERYDIM/backlight.sh pre boot
TimeoutSec=90s

[Install]
WantedBy=graphical.target
EOF

cat > /etc/systemd/system/sleep-backlight.service << EOF
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
systemctl mask systemd-backlight@backlight\:intel_backlight.service
