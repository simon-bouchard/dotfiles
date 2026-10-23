#!/bin/bash

# Types the VIN stored in ~/.vin into the focused window (bound to Ctrl+Alt+V by setup.sh).
# The VIN lives outside the repo so it never gets committed. Requires X11 and xdotool.

vin_file="${VIN_FILE:-$HOME/.vin}"

if [ ! -s "$vin_file" ]; then
    notify-send "type_vin" "No VIN found in $vin_file"
    exit 1
fi

vin=$(tr -d '[:space:]' < "$vin_file")

# Release the shortcut's Ctrl+Alt ourselves: --clearmodifiers re-presses them afterwards and
# leaves them stuck if the user has already let go of the keys
sleep 0.02
xdotool keyup Control_L Control_R Alt_L Alt_R Shift_L Shift_R Super_L Super_R
xdotool type --delay 0 "$vin"
