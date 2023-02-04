#!/bin/sh

case $1 in
"toggle") mpc toggle >/dev/null ;;
esac

if [ "$(mpc status '%state%')" = "playing" ]; then
    {
        icon=""
    }
else
    {
        icon=""
    }
fi
time=$(mpc status '%currenttime% / %totaltime%')
title=$(mpc status -f '%artist% - %title%' | head -n 1)

echo "{\"icon\": \"$icon\", \"title\": \"$title\", \"time\": \"$time\"}"
exit
