#!/bin/bash
[ "$(cat /proc/sys/kernel/hostname)" = "arch" ] && {
ping -q -c 1 -w 1 www.google.com > /dev/null || { echo "DOWN" && exit; }; }

output=$({ echo "mlvd-se13: "; awk '/mlvd-se13/ {i++; rx[i]=$2; tx[i]=$10}; END{print rx[2]-rx[1] " " tx[2]-tx[1]}' <(cat /proc/net/dev; sleep 1; cat /proc/net/dev) | tr ' ' '\n'; } | sed 's|[0-9][0-9][0-9]$||;2s|$| <fn=3></fn> |;1s|^.*$||' | tr -d '\n' | sed 's|$||')

[ "$(echo "$output" | grep -o '[0-9]*' | tr -d '\n')" -lt "300" ] && \
	{ echo "<fn=4></fn>  minimal"; exit; }
[ -z "$(echo "$output" | grep -o '[0-9]*' | tr -d '\n')" ] && \
	{ echo "<fn=4></fn><fn=4></fn>  none"; exit; }
echo "  <fn=4></fn>  $output <fn=3></fn>"
