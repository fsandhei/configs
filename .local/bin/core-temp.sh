#!/bin/bash

SENSORS=$(sensors)
CORE_TEMPS_INFO=$(echo "$SENSORS" | grep "Core")
CORE_TEMPS=$(echo "$CORE_TEMPS_INFO" | awk '{ print $3 }')
TOP_TEMP=$(echo "$CORE_TEMPS" | sort -r | head -n 1)

echo "$TOP_TEMP" | sed "s/\+//g"
