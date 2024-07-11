#!/usr/bin/bash

# Draw background
nitrogen --restore &

main_screen="eDP-1"
offscreen="DP-1"
xrandr --output "$main_screen" --auto --output "$offscreen" --auto --right-of "$main_screen"
