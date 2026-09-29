#!/usr/bin/bash
# Sets up two screens, allowing them to be used together.
# When connecting a second screen to a single screen setup, it most likely
# will not work out of the box without some udev rule setting up the screen when a
# display cable is connected, making interaction between those screens weird.
#
# This script sets up those two screens through `xrandr`. The second screen is assumed
# to be placed to the right of the primary screen.
# The script will also restart the `nitrogen` compositor and `xmonad`.
#
# Note that this script is not intended to be invoked manually, but by an udev rule.
#
# The script is executed as a oneshot systemd rule, triggered by a udev rule.
# See the systemd unit hotplug-monitor.service in /etc/systemd/system/hotplug-monitor.service.

main() {
    main_screen="eDP-1"
    offscreen="DP-1"
    offscreen_device="card1-$offscreen"

    current_state="$(cat /sys/class/drm/$offscreen_device/status)"
    offscreen_enabled="$(cat /sys/class/drm/${offscreen_device}/enabled)"

    if [ "$current_state" = "connected" ]; then
        attempt=1
        max_attempts=3
        enabled_check_sleep=1.0
        while [[ "${offscreen_enabled}" == "disabled" ]] && [[ ${attempt} -le ${max_attempts} ]] ; do
            echo "${offscreen_device} connected but not active, waiting ${enabled_check_sleep}s, status = ${offscreen_enabled}"
            sleep "${enabled_check_sleep}"
            attempt=$((attempt+1))
            offscreen_enabled="$(cat /sys/class/drm/${offscreen_device}/enabled)"
        done

        if [[ "${offscreen_enabled}" -ne "enabled" ]]; then
            echo "failed waiting for second screen" >&2
            exit 1
        fi

        echo "setting up dual-screen"
        xrandr --output "$main_screen" --auto --output "$offscreen" --auto --right-of "$main_screen"
        # Empirically selected, not sure on what this value should be.
        # Notice that the window setup requires more time during cold startup of the display.
        sleep 1.0
    else
        echo "setting up single screen"
        xrandr --output "$main_screen" --auto
        xrandr --output "$offscreen" --off
    fi

    # Draw background
    nitrogen --restore

    XMOBAR_PS="$(ps -eF | grep "[m]obar" | grep -v grep | awk '{ print $2 }')"

    if [[ ! -z "$XMOBAR_PS" ]]; then
        echo "Killing existing processes of xmobar, before restarting xmobar."
        echo "${XMOBAR_PS}" | xargs kill
    fi

    # Restart xmonad, or else we may miss the status bar and
    # other commands being run for the second screen.
    xmonad --restart
}

echo "=== $(date '+%Y-%m-%d %H:%M:%S') triggered ==="
main
