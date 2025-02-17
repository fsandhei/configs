#!/bin/bash
# Reads the audio settings from the Master device and displays
# either a 'audio off' or 'audio on' symbol depending on the state
# of the audio settings.
#
# Need to be used in conjunction with xmobar, with some alternative font.
#
# In order for this to work 'amixer' has to be installed.
# Install it with pacman:
# 	sudo pacman -S alsa-utils
# See https://wiki.archlinux.org/title/Advanced_Linux_Sound_Architecture#top-page for more information
#
# TODO: Need to figure out if something else than amixer should be used. Bluetooth devices cannot be configured
# through amixer. Perhaps wireplumber?

audio_percentage=$(awk -F"[][]" '/Mono:/ { print $2 }' <(amixer get Master))
audio_status=$(awk -F"[][]" '/Mono:/ { print $6 }' <(amixer get Master))

sound_on_emote="󰕾"
sound_off_emote="󰖁"

if [[ "$audio_status" = "on" ]]; then
    printf "<fn=1>%s</fn> (%s)" "$sound_on_emote" "$audio_percentage"
else
    printf "<fn=1>%s</fn>" "$sound_off_emote"
fi
