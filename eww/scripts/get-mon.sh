#!/bin/sh
[ "$(cat /proc/sys/kernel/hostname)" = "archM" ] && {
    printf 3
    exit
}
printf 0
