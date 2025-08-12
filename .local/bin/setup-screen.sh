#!/usr/bin/bash

main_screen="eDP-1"
offscreen="DP-1"
offscreen_device="card1-$offscreen"

current_state="$(cat /sys/class/drm/$offscreen_device/status)"

user_id="$(id -u)"

export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$user_id/bus"

if [ "$current_state" = "connected" ]; then
    echo "setting up dual-screen"
    xrandr --output "$main_screen" --auto --output "$offscreen" --auto --right-of "$main_screen"
    sleep 0.5
else
    echo "setting up single screen"
    xrandr --output "$main_screen" --auto
    xrandr --output "$offscreen" --off
fi

# Draw background
nitrogen --restore

# Restart xmonad, or else we may miss the status bar and
# other commands being run for the second screen.
xmonad --restart
