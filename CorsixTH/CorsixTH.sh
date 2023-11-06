#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt

get_controls

GAMEDIR="/$directory/ports/CorsixTH"

if   [[ $ANALOGSTICKS == '1' ]]; then
  GPTOKEYB_CONFIG="$GAMEDIR/corsixth.gptk.leftanalog"
else
  GPTOKEYB_CONFIG="$GAMEDIR/corsixth.gptk.rightanalog"
fi

export TEXTINPUTINTERACTIVE="Y"
export TEXTINPUTNOAUTOCAPITALS="Y"
cd $GAMEDIR

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "corsix-th" $HOTKEY textinput -c "$GPTOKEYB_CONFIG" &
LD_LIBRARY_PATH="$GAMEDIR/libs" SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./corsix-th --interpreter="$GAMEDIR/CorsixTH.lua" 2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1