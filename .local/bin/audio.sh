#!/bin/bash
# Reads the audio settings from the Master device and displays
# either a 'audio off' or 'audio on' symbol depending on the state
# of the audio settings.
#
# In order for this to work 'amixer' has to be installed.
# Install it with pacman:
# 	sudo pacman -S alsa-utils

audio_percentage=$(awk -F"[][]" '/Mono:/ { print $2 }' <(amixer get Master))
audio_status=$(awk -F"[][]" '/Mono:/ { print $6 }' <(amixer get Master))

sound_on_emote="󰕾"
sound_off_emote="󰖁"

if [[ "$audio_status" = "on" ]]; then
    printf "%s (%s)" "$sound_on_emote" "$audio_percentage"
else
    printf "%s" "$sound_off_emote"
fi
