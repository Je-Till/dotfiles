#!/bin/sh
bat=$(upower --dump | grep percentage | head -n 1 | awk '{print $2}')
status=$(upower --dump | grep state | awk '{print $2}')

[ "$status" = "charging" ]  && {
echo " <fc=#ffff3b,#00668F><fn=3></fn> $bat</fc>   "
exit
}
echo " <fn=3></fn> $bat   "
