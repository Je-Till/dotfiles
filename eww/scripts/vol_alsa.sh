#!/bin/sh

status=$(amixer get Master | grep 'Front Left: Playback' | awk -F'[][]' '{ print $4 }')

case $1 in
"toggle")
    case $status in
    "off")
        amixer sset Master unmute >/dev/null
        status="on"
        ;;
    "on")
        amixer sset Master mute >/dev/null
        status="off"
        ;;
    esac
    ;;
"up") amixer sset Master 2%+ >/dev/null ;;
"down") amixer sset Master 2%- >/dev/null ;;
esac

vol=$(amixer sget Master | sed '$!d' | grep -o '[0-9]*%')
volt=$(echo "$vol" | sed 's/%//')
if [ "$status" = "off" ]; then
    icon=""
elif [ "$volt" -gt 40 ]; then
    icon=""
elif [ "$volt" -gt 0 ]; then
    icon=""
elif [ "$volt" = 0 ]; then
    icon=""
fi
echo "{\"icon\": \"$icon\",\"vol\": \"$vol\"}"
exit
