#!/bin/sh
[ "$(cat /proc/sys/kernel/hostname)" = "archM" ] && exit
left=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 |grep time\ to |awk '{print $4" "$5}')
[ -z "$left" ] && exit
battery=$(cat /sys/class/power_supply/BAT0/capacity)
state=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 |grep state |awk '{print $2}')
[ "$state" != "discharging" ] && echo " <fc=#ffff3b,#bdb3ff><fn=4></fn> $battery% ($left)</fc>      "

if [ "$battery" -gt 85 ]; then
    vicon="<fn=4></fn>"
elif [ "$battery" -gt 65 ]; then
    vicon="<fn=4></fn>"
elif [ "$battery" -gt 40  ]; then
    vicon="<fn=4></fn>"
elif [ "$battery" -gt 20  ]; then
    echo " <fc=#edf057,#bdb3ff><fn=4></fn> $battery% ($left)</fc>      "
    exit
else
    echo " <box type=Bottom width=7 color=#ff3b3b><fc=#ff3b3b,#bdb3ff>!!!   <fn=4></fn> $battery% ($left)  !!!</fc></box>    "
    exit
fi

echo " $vicon $battery ($left)     "
