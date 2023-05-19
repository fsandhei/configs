#!/usr/bin/bash
main_screen="eDP1"
offscreen="DP1"
xrandr --output "$main_screen" --auto --output "$offscreen" --auto --right-of "$main_screen"
