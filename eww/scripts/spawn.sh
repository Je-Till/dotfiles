#!/bin/sh

case $1 in
"calendar")
    eww update calendar_year="$(date '+%Y')"
    eww update calendar_day="$(date '+%d')"
    LOCK_FILE="$HOME/.cache/eww-calendar.lock"
    if [ ! -f "$LOCK_FILE" ]; then
        eww open calendar
        touch "$LOCK_FILE"
    else
        eww close calendar
        rm "$LOCK_FILE"
    fi
    ;;

"todo")
    FILE_REPEATING="$HOME/.config/eww/scripts/todo_repeating"
    FILE_ONETIME="$HOME/.config/eww/scripts/todo_onetime"
    FILE_TIMESINCE="$HOME/.config/eww/scripts/todo_timesince"
    FILE_REPEATING_BAK="$HOME/.config/eww/scripts/todo_repeating_bak"
    FILE_ONETIME_BAK="$HOME/.config/eww/scripts/todo_onetime_bak"
    FILE_TIMESINCE_BAK="$HOME/.config/eww/scripts/todo_timesince_bak"
    LOCK_FILE="$HOME/.cache/eww-todo.lock"
    if [ ! -f "$LOCK_FILE" ]; then
        eww open todo_win
        touch "$LOCK_FILE"
        eww update todo_num="$(sh "$HOME"/.config/eww/scripts/todo.sh num)"
        eww update todo_repeating="$(sh "$HOME"/.config/eww/scripts/todo.sh get_repeating)"
        eww update todo_onetime="$(sh "$HOME"/.config/eww/scripts/todo.sh get_onetime)"
        eww update todo_timesince="$(sh "$HOME"/.config/eww/scripts/todo.sh get_timesince)"
        eww update todo_timesince_time="$(sh "$HOME"/.config/eww/scripts/todo.sh get_timesince_time)"
        eww update todo_repeating_time="$(sh "$HOME"/.config/eww/scripts/todo.sh get_repeating_time)"
    else
        eww close todo_win
        {
            rm "$FILE_ONETIME_BAK"
            rm "$FILE_TIMESINCE_BAK"
            rm "$FILE_REPEATING_BAK"
        } 2>/dev/null
        rm "$LOCK_FILE"
    fi
    ;;

"todo_add")
    LOCK_FILE="$HOME/.cache/eww-todo-add.lock"
    if [ ! -f "$LOCK_FILE" ]; then
        eww open todo_add_win
        touch "$LOCK_FILE"
    else
        eww close todo_add_win
        rm "$LOCK_FILE"
    fi
    ;;

"todo_undo_button")
    FILE_REPEATING_BAK="$HOME/.config/eww/scripts/todo_repeating_bak"
    FILE_ONETIME_BAK="$HOME/.config/eww/scripts/todo_onetime_bak"
    FILE_TIMESINCE_BAK="$HOME/.config/eww/scripts/todo_timesince_bak"
    if [ -f "$FILE_ONETIME_BAK" ] || [ -f "$FILE_TIMESINCE_BAK" ] || [ -f "$FILE_REPEATING_BAK" ]; then
        printf '
(box
(eventbox 
:active true
:class "todo_win_undo_icon"
:onclick `./scripts/todo.sh undo`
(label :text "UNDO")))'
    else
        printf '
(label :text "")'
    fi
    ;;
esac
