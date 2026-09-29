#!/bin/bash

# Wifi symbols. All are fetched as hex values
# from the nerd font "cheat sheet".
WIFI_SYMBOL_OFF=$'\U0000f092d'
WIFI_SYMBOL_STRENGTH_1=$'\Uf091f'
WIFI_SYMBOL_STRENGTH_2=$'\Uf0922'
WIFI_SYMBOL_STRENGTH_3=$'\Uf0925'
WIFI_SYMBOL_STRENGTH_4=$'\Uf0928'

essid=$(nmcli -t -f active,ssid dev wifi | grep -E '^yes' | cut -d":" -f2)

if [[ -z "$essid" ]]; then
    echo "${WIFI_SYMBOL_OFF}"
    exit 0
fi

strength=$(nmcli -t -f active,ssid,signal device wifi | grep -E "^yes" | cut -d":" -f3)
bars=$(expr "$strength" / 10)

symbol_to_print=

if [[ "$bars" -lt 3 ]]; then
    symbol_to_print="${WIFI_SYMBOL_STRENGTH_1}"
elif [[ "$bars" -ge 3 ]] && [[ "$bars" -lt 6 ]]; then
    symbol_to_print="${WIFI_SYMBOL_STRENGTH_2}"
elif [[ "$bars" -ge 6 ]] && [[ "$bars" -lt 8 ]]; then
    symbol_to_print="${WIFI_SYMBOL_STRENGTH_3}"
else
    symbol_to_print="${WIFI_SYMBOL_STRENGTH_4}"
fi

echo "$essid" "<fn=1>$symbol_to_print</fn>"
