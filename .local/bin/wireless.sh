#!/bin/bash

essid=$(nmcli -t -f active,ssid dev wifi | grep -E '^yes' | cut -d":" -f2)
strength=$(nmcli -t -f active,ssid,signal device wifi | grep -E "^yes" | cut -d":" -f3)
bars=$(expr "$strength" / 10)

case $bars in
  0)  bar='[----------]' ;;
  1)  bar='[/---------]' ;;
  2)  bar='[//--------]' ;;
  3)  bar='[///-------]' ;;
  4)  bar='[////------]' ;;
  5)  bar='[/////-----]' ;;
  6)  bar='[//////----]' ;;
  7)  bar='[///////---]' ;;
  8)  bar='[////////--]' ;;
  9)  bar='[/////////-]' ;;
  10) bar='[//////////]' ;;
  *)  bar='[----!!----]' ;;
esac

echo "$essid" "$bar"
