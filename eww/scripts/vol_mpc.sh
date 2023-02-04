#!/bin/sh

case $1 in
"up") mpc volume +2 >/dev/null ;;
"down") mpc volume -2 >/dev/null ;;
esac

icon=""
vol=$(mpc status '%volume%' | sed 's/^\s*//')
echo "{\"icon\": \"$icon\",\"vol\": \"$vol\"}"
exit
