#!/bin/sh
process_count=$(ps aux | grep "\-sshargs=" |wc -l)
process_count=$((process_count - 1))
process_max=$(sed -n '/#DIRS/,/#DIRSEND/p' ~/scripts/unison.sh |wc -l)
process_max=$((process_max - 3))
echo " $process_count / $process_max     "
