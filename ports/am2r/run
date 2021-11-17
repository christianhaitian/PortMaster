#!/bin/bash

DIR="$(realpath $( dirname "${BASH_SOURCE[0]}" ))"
source "${DIR}/global-functions"

ESUDO="$(get_sudo)"
sdl_controllerconfig="$(get_sdl_controller_config)"
param_device="$(get_oga_device)"
console="$(get_console)"

$ESUDO chmod 666 "${console}"

export LD_LIBRARY_PATH=${DIR}/libs:/usr/lib:/usr/lib32
$ESUDO rm -rf ~/.config/am2r
ln -sfv ${DIR}/conf/am2r/ ~/.config/
cd "${DIR}"
$ESUDO ./oga_controls gmloader $param_device &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./gmloader gamedata/am2r.apk
$ESUDO kill -9 $(pidof oga_controls)
unset LD_LIBRARY_PATH
$ESUDO systemctl restart oga_events &
printf "\033c" > "${console}"