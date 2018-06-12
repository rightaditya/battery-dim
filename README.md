# battery-dim
Automatic screen backlight dimming in Linux when AC adapter is unplugged

This collection of scripts is used to provide some functionality in Linux to
automatically dim the screen brightness when the AC adapter is unplugged (and
to increase the brightness when it's plugged back in).
This is done by listening to acpi events.
Functionality to check the AC adapter status at boot or resume from suspend is
done with systemd services.

## Necessary programs
acpid is required for listening for the AC adapter events (`acpid` package in
Ubuntu, but it should be installed by default).
acpid should also come with `acpi_listen`, which will be used for determining
the AC adapter plug and unplug events for configuration.

## Installation
1. Set the various variables in `config.sh` as desired:
  * `BATTERYDIM` is the location where the scripts will be installed. This is
    only used during installation
  * `ACPI_UNPLUG` and `ACPI_PLUG` are the ACPI events for unplugging the AC
    adapter and plugging it in, respectively.
    To determine the unplug event, plug in the adapter if it isn't already
    plugged in, run acpi_listen, and then unplug the adapter.
    Look for the event starting with ac_adapter and set `ACPI_UNPLUG` to that
    whole line.
    Plug the adapter back in to generate the plug event, and similarly set
    `ACPI_PLUG` to the line for the plug event.
  * `UNPLUG_BRIGHTNESS` and `PLUG_BRIGHTNESS` indicate the brightness for the
    unplugged and plugged states, respectively.
    These are specified as percentages of the maximum value, so 25 means 25% of
    the max and 100 is 100% of the max (i.e. the brightest possible).
  * `BACKLIGHT` specifies the backlight device in the filesystem.
    My laptop, for example, has two backlight devices (one for the keyboard
    backlight, and one for the screen), so the correct device needs to be
    specified.
    Mine is `/sys/class/backlight/intel_backlight`.
    Take a look in `/sys/class/backlight` to see the different backlight options
    you have.
    To test one out, manually decrease the brightness to, say 50% of the max,
    and then use the `brightness` and `max_brightness` files to set the
    brightness to the max value; if you've got the right device, you should see
    your brightness go up to max.

    For example, if I hypothesized that `/sys/class/backlight/intel_backlight`
    was the right device, I'd decrease my screen brightness so that it's
    signifiantly dimmer, and then run (as root):

    ```
    # cat /sys/class/backlight/intel_backlight/max_brightness >
    /sys/class/backlight/intel_backlight/brightness
    ```

    Or if you want to do it via sudo:

    ```
    $ cat /sys/class/backlight/intel_backlight/max_brightness | sudo tee
    /sys/class/backlight/intel_backlight/brightness
    ```

    And I should see my screen brightness go up to the max value to confirm that
    I've got the right device.
2. Run `install.sh` as root:

   ```
   $ sudo ./install.sh
   ```
3. Enjoy the functionality that Windows and OSX have out of the box!
   (A reboot may be necessary, but I think you should be okay manually starting
   the relevant systemd services too.)

Once you have it installed, if you decide you want to change the brightness in
the unplug or plug states, just set the appropriate values in `config.sh` in the
installation directory; the scripts will read from that file automatically.

## Uninstallation
1. Run `uninstall.sh` as root. Note that this wipes out the installation
   directory as well as stopping and removing the systemd services and acpid
   event listeners, so if you've put anything in that folder or made any changes
   you want to keep, get them to a safe place first.

## Notes
I've only tested this on Ubuntu 15.04–18.04, but it should work on
any other system that uses systemd and acpid.

Also, the config and installation are not particularly user-friendly.
The ideal would be to get this functionality into GNOME, KDE, etc. so that it is
there by default and is configurable via GUI.
Alas delving into those DEs is a bit more than I want to do. ;)
