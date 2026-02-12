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

main_screen="eDP-1"
offscreen="DP-1"
offscreen_device="card1-$offscreen"

current_state="$(cat /sys/class/drm/$offscreen_device/status)"

if [ "$current_state" = "connected" ]; then
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
