#!/bin/bash
# Centers the cursor for the current focused window, using `xdotool`.
#
# This is only compatible for X11 based window systems.

resolution="$(xdpyinfo | awk '/dimensions/{print $2}')"
width="$(echo "$resolution" | cut -d 'x' -f 1)"
height="$(echo "$resolution" | cut -d 'x' -f 2)"

xdotool mousemove $((width / 2)) $((height / 2))
