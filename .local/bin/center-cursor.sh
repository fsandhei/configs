#!/bin/bash
# Centers the cursor for the current focused window, using `xdotool`.
#
# This is only compatible for X11 based window systems.

set -x
set -o errexit

sel_screen_geometry=

eval "$(xdotool getmouselocation --shell)"

# Names provided by xdotool are not that good,
# so we give some better names.
cursor_x="$X"
cursor_y="$Y"

determine_monitor_geometry() {
    local curr_geometry
    local screen_info

    while IFS= read -r line; do
        curr_geometry="$(echo $line | grep --only-matching '[0-9]*/[0-9]*x[0-9]*/[0-9]*+[0-9]*+[0-9]*')"

        if [ -z "$curr_geometry" ]; then
            continue
        fi

        # Width and height format is <width_pixels/physical_width>
        curr_width=$(echo "$curr_geometry" | cut -d 'x' -f 1 | cut -d '/' -f 1)
        curr_height=$(echo "$curr_geometry" | cut -d 'x' -f 2 | cut -d '/' -f 1)
        x_offset=$(echo "$curr_geometry" | cut -d '+' -f 2)
        y_offset=$(echo "$curr_geometry" | cut -d '+' -f 3)

        if [ $cursor_x -ge $x_offset ] && [ $cursor_x -lt $((x_offset + curr_width)) ] && \
           [ $cursor_y -ge $y_offset ] && [ $cursor_y -lt $((y_offset + curr_height)) ]; then
            sel_screen_geometry="${curr_width} ${curr_height} ${x_offset} ${y_offset}"
            break
        fi
    done < <(xrandr --listmonitors | grep -v '^Monitors:')
}

main() {
    determine_monitor_geometry

    if [ ! -z "$sel_screen_geometry" ]; then
        echo "found screen geometry: $sel_screen_geometry"
        read -r width height x_offset y_offset <<< "$sel_screen_geometry"

        center_x=$(((width / 2) + x_offset))
        center_y=$(((height / 2) + y_offset))

        xdotool mousemove --sync "$center_x" "$center_y"
    else
        echo "Could not determine screen geometry; will not attempt centering cursor."
        exit 0
    fi
}

main
