#!/bin/bash
# Reads the audio settings from the Master device and displays
# either an 'audio off' or 'audio on' symbol depending on the state
# of the audio settings.
#
# Need to be used in conjunction with xmobar, with some alternative font.
#
# This script requires [WirePlumber](https://wiki.archlinux.org/title/WirePlumber) in order to work.
#
# See https://wiki.archlinux.org/title/Advanced_Linux_Sound_Architecture#top-page for more information
#
# TODO: Need to figure out if something else than amixer should be used. Bluetooth devices cannot be configured
# through amixer. Perhaps wireplumber?

require_wpctl() {
    if ! command -v wpctl >/dev/null; then
        printf "wpctl must be installed: pacman -S wireplumber" >&2
        exit 1
    fi
}

emit_audio_status() {
    audio_ratio="$(wpctl get-volume @DEFAULT_AUDIO_SINK@)"
    audio_percentage=$(echo "$audio_ratio" | grep -o "[0-1]\.[0-9][0-9]" | awk '{ print int($1 * 100) }')

    if ! echo "$audio_ratio" | grep -q "[M]UTED"; then
        audio_status="on"
    else
        audio_status="off"
    fi

    sound_on_emote="󰕾"
    sound_off_emote="󰖁"

    if [[ "$audio_status" = "on" ]]; then
        printf "<fn=1>%s</fn> (%s%%)" "$sound_on_emote" "$audio_percentage"
    else
        printf "<fn=1>%s</fn> " "$sound_off_emote"
    fi
}

require_wpctl
emit_audio_status
