#!/bin/bash
set -e

# Current directory of the script
DIR="$(realpath $( dirname "${BASH_SOURCE[0]}" ))"
source "${DIR}/global-functions"

CONSOLE="$(get_console)"
ESUDO="$(get_sudo)"
$ESUDO chmod 666 ${CONSOLE}

sdl_controllerconfig=$(get_sdl_controller_config)
param_device=$(get_oga_device)

pushd "${DIR}"
$ESUDO ./oga_controls hcl $param_device &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./hcl
$ESUDO kill -9 $(pidof oga_controls)
$ESUDO systemctl restart oga_events &

printf "\033c" >> "$CONSOLE"