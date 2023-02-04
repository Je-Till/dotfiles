#!/bin/sh

# todo_* data per line:       name;time_to_repeat/date_since_last;time_until_active;id
FILE_REPEATING="$HOME/.config/eww/scripts/todo_repeating"
FILE_ONETIME="$HOME/.config/eww/scripts/todo_onetime"
FILE_TIMESINCE="$HOME/.config/eww/scripts/todo_timesince"
FILE_REPEATING_BAK="$HOME/.config/eww/scripts/todo_repeating_bak"
FILE_ONETIME_BAK="$HOME/.config/eww/scripts/todo_onetime_bak"
FILE_TIMESINCE_BAK="$HOME/.config/eww/scripts/todo_timesince_bak"

case $1 in
"num")
    num=0
    while read -r line; do
        expire_date="$(echo "$line" | cut -d ";" -f3)"
        if [ "$expire_date" = "" ]; then
            num=$((num + 1))
            continue
        fi
        date="$(date +%s)"
        time_left="$((expire_date - date))"
        if [ "$time_left" -le "0" ]; then
            num=$((num + 1))
            continue
        fi
    done <<EOF
"$(cat "$FILE_REPEATING" "$FILE_ONETIME")"
EOF
    printf "%s" "$num"
    exit
    ;;

"get_repeating_time")
    entries=""
    while read -r line; do
        expire_date="$(echo "$line" | cut -d ";" -f3)"
        id="$(echo "$line" | cut -d ";" -f4)"
        date="$(date +%s)"
        time_left="$((expire_date - date))"
        if [ "$time_left" -le "10800" ]; then
            time_left="$(echo "$time_left/60" | bc)"
            time_left="${time_left}m"
        elif [ "$time_left" -le "86400" ]; then
            time_left="$(echo "$time_left/60/60" | bc)"
            time_left="${time_left}h"
        else
            time_left="$(echo "$time_left/60/60/24" | bc)"
            time_left="${time_left}d"
        fi
        entries="${entries}\"todo${id}\": \"${time_left}\","
    done <"$FILE_REPEATING"
    entries=${entries%?}
    printf "{%s}" "$entries"
    # format "{\"todo${id}\": \"${time_left}\"}"
    exit
    ;;

"get_timesince_time")
    entries=""
    while read -r line; do
        lasttime="$(echo "$line" | cut -d ";" -f3)"
        id="$(echo "$line" | cut -d ";" -f4)"
        date="$(date +%s)"
        timesince="$((date - lasttime))"
        if [ "$timesince" -le "10800" ]; then
            timesince="$(echo "$timesince/60" | bc)"
            timesince="${timesince}m"
        elif [ "$timesince" -le "86400" ]; then
            timesince="$(echo "$timesince/60/60" | bc)"
            timesince="${timesince}h"
        else
            timesince="$(echo "$timesince/60/60/24" | bc)"
            timesince="${timesince}d"
        fi
        entries="${entries}\"todo${id}\": \"${timesince}\","
    done <"$FILE_TIMESINCE"
    entries=${entries%?}
    printf "{%s}" "$entries"
    # format "{\"todo${id}\": \"${timesince}\"}"
    exit
    ;;

"get_repeating")
    FILE=$FILE_REPEATING
    entries=""
    while read -r line; do
        id="$(echo "$line" | cut -d ";" -f4)"
        name=$(echo "$line" | cut -d ";" -f1)
        if [ ! "$(echo "$line" | cut -d ";" -f3)" = "" ]; then
            class="todo_button_repeating_cd"
        else
            class="todo_button_repeating"
        fi
        entries=${entries}'
(box :orientation "h" :space-evenly true
(eventbox 
:halign "start"
:active true
:class "'"$class"'"
:onclick `./scripts/todo.sh remove '"$name"' <'"$FILE"'`
:onmiddleclick `./scripts/todo.sh remove '"$name"' -f <'"$FILE"'`
(label :text '"$name"'))
(label :halign "end" :text "${todo_repeating_time.todo'"$id"'}"))'
    done <"$FILE"
    printf '
(box :space-evenly false :spacing 3
:orientation "v"
; (label :text "debug")
%s
)' "$entries"
    exit
    ;;

"get_timesince")
    FILE=$FILE_TIMESINCE
    entries=""
    while read -r line; do
        id="$(echo "$line" | cut -d ";" -f4)"
        name=$(echo "$line" | cut -d ";" -f1)
        if [ ! "$(echo "$line" | cut -d ";" -f3)" = "" ]; then
            class="todo_button_timesince_cd"
        else
            class="todo_button_timesince"
        fi
        entries=${entries}'
(box :orientation "h" :space-evenly true
(eventbox 
:halign "start"
:active true
:class "'"$class"'"
:onclick `./scripts/todo.sh remove '"$name"' <'"$FILE"'`
:onmiddleclick `./scripts/todo.sh remove '"$name"' -f <'"$FILE"'`
(label :text '"$name"'))
(label :halign "end" :text "${todo_timesince_time.todo'"$id"'}"))'
    done <"$FILE"
    printf '
(box :space-evenly false :spacing 3
:orientation "v"
; (label :text "debug")
%s
)' "$entries"
    exit
    ;;

"get_onetime")
    FILE=$FILE_ONETIME
    entries=""
    while read -r line; do
        id="$(echo "$line" | cut -d ";" -f4)"
        name=$(echo "$line" | cut -d ";" -f1)
        if [ ! "$(echo "$line" | cut -d ";" -f3)" = "" ]; then
            class="todo_button_onetime_cd"
        else
            class="todo_button_onetime"
        fi
        entries=${entries}'
(eventbox 
:halign "center"
:active true
:class "'"$class"'"
:onclick `./scripts/todo.sh remove '"$name"' <'"$FILE"'`
:onmiddleclick `./scripts/todo.sh remove '"$name"' -f <'"$FILE"'`
(label :text '"$name"'))'
    done <"$FILE"
    printf '
(box :space-evenly false :spacing 3
:orientation "v"
; (label :text "debug")
%s
)' "$entries"
    exit
    ;;

"remove")
    lines=""
    while read -r line; do
        if echo "$line" | grep "$2" >/dev/null; then #
            name="$(echo "$line" | cut -d ";" -f1)"
            repeat="$(echo "$line" | cut -d ";" -f2)"
            timesince_or_repeat="$(echo "$line" | cut -d ";" -f3)"
            if [ ! "$repeat" = "" ]; then # this block is only for repeating
                CMD="repeating"
                FILE=$FILE_REPEATING
                FILE_BAK=$FILE_REPEATING_BAK
                if [ "$3" = "-f" ]; then
                    break
                fi
                timesince_or_repeat=$(date -d "+$repeat seconds" +%s)
                id="$(echo "$line" | cut -d ";" -f4)"
                line=$(printf "%s;%s;%s;%s" "$name" "$repeat" "$timesince_or_repeat" "$id") # we add a modified repeating line
                if [ "$lines" = "" ]; then
                    lines="${line}"
                else
                    lines="${lines}
${line}"
                fi
                break
            elif [ ! "$timesince_or_repeat" = "" ]; then # this block is only for timesince
                CMD="timesince"
                FILE=$FILE_TIMESINCE
                FILE_BAK=$FILE_TIMESINCE_BAK
                if [ "$3" = "-f" ]; then
                    break
                fi
                timesince_or_repeat=$(date +%s)
                id="$(echo "$line" | cut -d ";" -f4)"
                line=$(printf "%s;%s;%s;%s" "$name" "$repeat" "$timesince_or_repeat" "$id") # we add a modified timesince line
                if [ "$lines" = "" ]; then
                    lines="${line}"
                else
                    lines="${lines}
${line}"
                fi
                break
            else # this block is only for onetime;
                CMD="onetime"
                FILE=$FILE_ONETIME
                FILE_BAK=$FILE_ONETIME_BAK
                break # for onetime we dont add any lines to the var, we simply break so its not added
            fi
        fi
        if [ "$lines" = "" ]; then # keep adding lines to the lines var until we find the correct line to remove
            lines="${line}"
        else
            lines="${lines}
${line}"
        fi
    done
    while read -r line; do #iterate through the lines that are left after we found the line
        if [ "$lines" = "" ]; then
            lines="${line}"
        else
            lines="${lines}
${line}"
        fi
    done

    if [ ! -f "$FILE_BAK" ]; then
        cp "$FILE" "$FILE_BAK"
        eww update todo_undo_button="$(sh "$HOME"/.config/eww/scripts/spawn.sh todo_undo_button)"
    fi
    printf "%s" "$lines" >"$FILE"
    if [ ! "$(tail -c 1 "$FILE_ONETIME")" = "" ]; then printf "\n" >>"$FILE_ONETIME"; fi # make sure file ends in new line
    if [ ! "$(tail -c 1 "$FILE_TIMESINCE")" = "" ]; then printf "\n" >>"$FILE_TIMESINCE"; fi
    if [ ! "$(tail -c 1 "$FILE_REPEATING")" = "" ]; then printf "\n" >>"$FILE_REPEATING"; fi
    [ ! "$CMD" = "timesince" ] && eww update todo_num="$(sh "$HOME"/.config/eww/scripts/todo.sh num)"
    eww update todo_"$CMD"="$(sh "$HOME"/.config/eww/scripts/todo.sh get_"$CMD")"
    [ ! "$CMD" = "onetime" ] && eww update todo_"$CMD"_time="$(sh "$HOME"/.config/eww/scripts/todo.sh get_"$CMD"_time)"
    exit
    ;;
"add")
    htime_to_sec() {
        # converts human readable numbers to seconds (int) eg. 5.1h 2562.2212222d 102s 250m 1010101.5m
        # requirement = bc
        [ "$1" = "" ] && {
            read -r stdin
            set "$stdin"
        }
        tail="$(echo "$1" | grep -oE "[a-zA-Z]+$")"
        head="$(echo "$1" | sed 's/\(.*\).$/\1/')"
        case $tail in
        "s") ;;
        "m")
            head=$(echo "${head}*60" | bc | sed 's/\(.*\)\..*/\1/')
            ;;
        "h")
            head=$(echo "${head}*60*60" | bc | sed 's/\(.*\)\..*/\1/')
            ;;
        "d")
            head=$(echo "${head}*60*60*24" | bc | sed 's/\(.*\)\..*/\1/')
            ;;
        *)
            echo "invalid tail: \"$tail\" (s,m,h,d accepted)" >&2
            exit
            ;;
        esac
        printf "%s" "$head"
    }
    is_integer() {
        case "${1#[+-]}" in
        *[!0123456789]*)
            printf "1"
            ;;
        '')
            printf "1"
            ;;
        0)
            printf "0"
            ;;
        [0]*)
            printf "1"
            ;;
        *)
            printf "0"
            ;;
        esac
    }
    while :; do
        if [ "$(echo "$2" | grep -o ";" | wc -c)" -ne "2" ]; then
            notify-send -t 1000 "no semicolon found"
        else
            name="$(echo "$2" | cut -d ";" -f1)"
            #calculate field 2
            repeat="$(echo "$2" | cut -d ";" -f2)"
            if [ "$repeat" = "now" ]; then
                FILE=$FILE_TIMESINCE
                FILE_BAK=$FILE_TIMESINCE_BAK
                CMD="timesince"
                date_to_repeat="$(date +%s)"
                repeat=""
            elif [ "$repeat" = "" ] && [ ! "$name" = "" ]; then
                FILE=$FILE_ONETIME
                FILE_BAK=$FILE_ONETIME_BAK
                CMD="onetime"
                date_to_repeat=""
                repeat=""
            elif [ "$(is_integer "1${repeat%?}")" = "0" ]; then # we add one to the left and remove potential humantime letter from right. this is true if repeat="" so better run this after onetime
                repeat=$(echo "$repeat" | htime_to_sec || notify-send -t 1000 "conversion failure")
                FILE=$FILE_REPEATING
                FILE_BAK=$FILE_REPEATING_BAK
                CMD="repeating"
                date_to_repeat=$(date -d "+$repeat seconds" +%s)
            else
                notify-send "wrong format"
                exit
            fi
            [ ! -f "$FILE_ONETIME" ] && touch "$FILE_ONETIME"
            [ ! -f "$FILE_TIMESINCE" ] && touch "$FILE_TIMESINCE"
            [ ! -f "$FILE_REPEATING" ] && touch "$FILE_REPEATING"
            # calculate field 1
            if [ "$(printf %.1s "$name")" != "\"" ]; then
                name="\"${name}"
            fi
            if [ "$(printf %s "$name" | tail -c 1)" != "\"" ]; then
                name="${name}\""
            fi
            # calculate field 4
            ids=$(awk -F\; '{print $4}' "$FILE_REPEATING" "$FILE_ONETIME" "$FILE_TIMESINCE" | sort || {
                notify-send "FATAL: failed to get ids"
                exit
            })
            ids="${ids}$(printf "\nmax")" # add last entry incase for loop loops through all values
            echo "$ids"
            n=0
            for x in $ids; do
                n=$((n + 1))
                echo "$x"
                # echo "$n = $x"
                if [ ! "$n" = "$x" ]; then
                    echo "$n = $x"
                    id=$n
                    break
                fi
            done
            # create line and append to file
            if [ ! -f "$FILE_BAK" ]; then
                cp "$FILE" "$FILE_BAK"
                eww update todo_undo_button="$(sh "$HOME"/.config/eww/scripts/spawn.sh todo_undo_button)"
            fi
            line=$(printf "%s;%s;%s;%s;" "$name" "$repeat" "$date_to_repeat" "$id")
            printf "%s\n" "$line" >>"$FILE" || {
                notify-send "failed to append $FILE"
                exit
            }
            if [ ! "$(tail -c 1 "$FILE_ONETIME")" = "" ]; then printf "\n" >>"$FILE_ONETIME"; fi # make sure file ends in new line
            if [ ! "$(tail -c 1 "$FILE_TIMESINCE")" = "" ]; then printf "\n" >>"$FILE_TIMESINCE"; fi
            if [ ! "$(tail -c 1 "$FILE_REPEATING")" = "" ]; then printf "\n" >>"$FILE_REPEATING"; fi
            LOCK_FILE="$HOME/.cache/eww-todo-add.lock"
            eww close todo_add_win 2>/dev/null
            [ ! "$CMD" = "timesince" ] && eww update todo_num="$(sh "$HOME"/.config/eww/scripts/todo.sh num)"
            eww update todo_"$CMD"="$(sh "$HOME"/.config/eww/scripts/todo.sh get_"$CMD")"
            [ ! "$CMD" = "onetime" ] && eww update todo_"$CMD"_time="$(sh "$HOME"/.config/eww/scripts/todo.sh get_"$CMD"_time)"
            rm "$LOCK_FILE" 2>/dev/null
            exit
        fi
    done
    ;;

"undo")
    mv -f "$FILE_ONETIME_BAK" "$FILE_ONETIME"
    mv -f "$FILE_TIMESINCE_BAK" "$FILE_TIMESINCE"
    mv -f "$FILE_REPEATING_BAK" "$FILE_REPEATING"
    eww update todo_undo_button="$(sh "$HOME"/.config/eww/scripts/spawn.sh todo_undo_button)"
    eww update todo_repeating="$(sh "$HOME"/.config/eww/scripts/todo.sh get_repeating)"
    eww update todo_onetime="$(sh "$HOME"/.config/eww/scripts/todo.sh get_onetime)"
    eww update todo_timesince="$(sh "$HOME"/.config/eww/scripts/todo.sh get_timesince)"
    eww update todo_timesince_time="$(sh "$HOME"/.config/eww/scripts/todo.sh get_timesince_time)"
    eww update todo_repeating_time="$(sh "$HOME"/.config/eww/scripts/todo.sh get_repeating_time)"
    ;;
esac
