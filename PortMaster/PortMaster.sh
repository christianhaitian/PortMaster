#!/bin/bash
#
# PortMaster
# https://github.com/christianhaitian/arkos/wiki/PortMaster
# Description : A simple tool that allows you to download
# various game ports that are available for RK3326 devices
# using 351Elec and Ubuntu based distros such as ArkOS, TheRA, and RetroOZ.
#

ESUDO="sudo"
GREP="grep"
WGET="wget"
if [ -f "/storage/.config/.OS_ARCH" ]; then
  ESUDO=""
  export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/storage/roms/ports/PortMaster/libs"
  GREP="/storage/roms/ports/PortMaster/grep"
  WGET="/storage/roms/ports/PortMaster/wget"
fi

$ESUDO chmod 666 /dev/tty0
export TERM=linux
export XDG_RUNTIME_DIR=/run/user/$UID/
printf "\033c" > /dev/tty0
dialog --clear

hotkey="Select"
height="15"
width="55"

if [[ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]]; then
  param_device="anbernic"
  if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ] || [ -f "/opt/system/Advanced/Switch to SD2 for Roms.sh" ] || [ -f "/boot/rk3326-rg351v-linux.dtb" ]; then
    $ESUDO setfont /usr/share/consolefonts/Lat7-Terminus20x10.psf.gz
    height="20"
    width="60"
  fi
elif [[ -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
    if [[ ! -z $(cat /etc/emulationstation/es_input.cfg | $GREP "190000004b4800000010000001010000") ]]; then
      param_device="oga"
	  hotkey="Minus"
	else
	  param_device="rk2020"
	fi
elif [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]]; then
  param_device="ogs"
  $ESUDO setfont /usr/share/consolefonts/Lat7-Terminus20x10.psf.gz
  height="20"
  width="60"
else
  param_device="chi"
  hotkey="1"
  $ESUDO setfont /usr/share/consolefonts/Lat7-Terminus20x10.psf.gz
  height="20"
  width="60"
fi

isitthera=$($GREP "title=" "/usr/share/plymouth/themes/text.plymouth")
if [[ $isitthera == *"TheRA"* ]]; then
  toolsfolderloc="/opt/tools"
elif [[ -e "/storage/.config/.OS_ARCH" ]]; then
  toolsfolderloc="/storage/roms/ports"
else
  toolsfolderloc="/opt/system/Tools"
fi

cd $toolsfolderloc
$ESUDO $toolsfolderloc/PortMaster/oga_controls PortMaster.sh $param_device > /dev/null 2>&1 &

curversion="$(curl file://$toolsfolderloc/PortMaster/version)"

GW=`ip route | awk '/default/ { print $3 }'`
if [ -z "$GW" ]; then
  dialog --clear --backtitle "PortMaster v$curversion" --title "$1" --clear \
  --msgbox "\n\nYour network connection doesn't seem to be working. \
  \nDid you make sure to configure your wifi connection?" $height $width 2>&1 > /dev/tty0
  $ESUDO kill -9 $(pidof oga_controls)
  $ESUDO systemctl restart oga_events &
  exit 0
fi

isitarkos=$($GREP "title=" /usr/share/plymouth/themes/text.plymouth)
if [[ $isitarkos == *"ArkOS"* ]]; then
  $ESUDO timedatectl set-ntp 1
fi

website="https://raw.githubusercontent.com/christianhaitian/PortMaster/main/"

ISITCHINA=$(curl -s --connect-timeout 30 -m 60 http://demo.ip-api.com/json | $GREP -Po '"country":.*?[^\\]"')

if [[ "$ISITCHINA" == "\"country\":\"China\"" ]]; then
  website="http://139.196.213.206/arkos/ports/"
fi

if [ ! -d "/dev/shm/portmaster" ]; then
  mkdir /dev/shm/portmaster
fi

dpkg -s "curl" &>/dev/null
if [ "$?" != "0" ]; then
  $ESUDO apt update && $ESUDO apt install -y curl --no-install-recommends
fi

dpkg -s "dialog" &>/dev/null
if [ "$?" != "0" ]; then
  $ESUDO apt update && $ESUDO apt install -y dialog --no-install-recommends
  temp=$($GREP "title=" /usr/share/plymouth/themes/text.plymouth)
  if [[ $temp == *"ArkOS 351P/M"* ]]; then
	#Make sure sdl2 wasn't impacted by the install of dialog for the 351P/M
    $ESUDO ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.14.1 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0
	$ESUDO ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0
  fi
fi

UpdateCheck() {

  gitversion=$(curl -s --connect-timeout 30 -m 60 ${website}version)

  if [[ "$gitversion" != "$curversion" ]]; then
    $WGET -t 3 -T 60 -q --show-progress "${website}PortMaster.zip" -O /dev/shm/portmaster/PortMaster.zip 2>&1 | stdbuf -oL sed -E 's/\.\.+/---/g'| dialog \
          --progressbox "Downloading and installing PortMaster update..." $height $width > /dev/tty0
	if [ ${PIPESTATUS[0]} -eq 0 ]; then
      unzip -X -o /dev/shm/portmaster/PortMaster.zip -d $toolsfolderloc/
	  if [[ $isitthera == *"TheRA"* ]]; then
		$ESUDO chmod -R 777 $toolsfolderloc/PortMaster
	  fi
	  dialog --clear --backtitle "PortMaster v$curversion" --title "$1" --clear --msgbox "\n\nPortMaster updated successfully." $height $width 2>&1 > /dev/tty0
	  $ESUDO kill -9 $(pidof oga_controls)
	  $ESUDO rm -f /dev/shm/portmaster/PortMaster.zip
	  $ESUDO systemctl restart oga_events &
	  exit 0
	else
	  dialog --clear --backtitle "PortMaster v$curversion" --title "$1" --clear --msgbox "\n\nPortMaster failed to update." $height $width 2>&1 > /dev/tty0
	  $ESUDO rm -f /dev/shm/portmaster/PortMaster.zip
	fi
  else
    dialog --clear --backtitle "PortMaster v$curversion" --title "$1" --clear --msgbox "\n\nNo update needed." $height $width 2>&1 > /dev/tty0
  fi
}

$WGET -t 3 -T 60 --no-check-certificate "$website"ports.md -O /dev/shm/portmaster/ports.md

PortInfoInstall() {

local setwebsiteback="N"
local unzipstatus

  if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
    whichsd="roms2"
  elif [ -f "/storage/.config/.OS_ARCH" ]; then
    whichsd="storage/roms"
  else
    whichsd="roms"
  fi
  
  msgtxt=$(cat /dev/shm/portmaster/ports.md | $GREP "$1" | $GREP -oP '(?<=Desc=").*?(?=")')
  installloc=$(cat /dev/shm/portmaster/ports.md | $GREP "$1" | $GREP -oP '(?<=locat=").*?(?=")')
  porter=$(cat /dev/shm/portmaster/ports.md | $GREP "$1" | $GREP -oP '(?<=porter=").*?(?=")')
  if [[ "$website" != "http://139.196.213.206/arkos/ports/" ]]; then
    if [[ "$installloc" == "SuperTux.zip" ]] || [[ "$installloc" == "UQM.zip" ]]; then
      website="http://139.196.213.206/arkos/ports/"
	  setwebsiteback="Y"
    fi
  fi
  dialog --clear --backtitle "PortMaster v$curversion" --title "$1" --clear \
  --yesno "\n$msgtxt \n\nPorted By: $porter\n\nWould you like to continue to install this port?" $height $width 2>&1 > /dev/tty0

  case $? in
     0) $WGET -t 3 -T 60 -q --show-progress "$website$installloc" -O \
	    /dev/shm/portmaster/$installloc 2>&1 | stdbuf -oL sed -E 's/\.\.+/---/g'| dialog --progressbox \
		"Downloading ${1} package..." $height $width > /dev/tty0
		if [ ${PIPESTATUS[0]} -eq 0 ] || [ -f "/storage/.config/.OS_ARCH" ] ; then
          unzip -o /dev/shm/portmaster/$installloc -d /$whichsd/ports/ > /dev/tty0
          unzipstatus=$?
		  if [[ "$setwebsiteback" == "Y" ]]; then
		    website="https://raw.githubusercontent.com/christianhaitian/PortMaster/main/"
		  fi
          if [ $unzipstatus -ne 50 ]; then
		    if [[ $isitthera == *"TheRA"* ]]; then
		      $ESUDO chmod -R 777 /roms/ports
		    fi
		    dialog --clear --backtitle "PortMaster v$curversion" --title "$1" --clear --msgbox "\n\n$1 installed successfully. \
		    \n\nMake sure to restart EmulationStation in order to see it in the ports menu." $height $width 2>&1 > /dev/tty0
		  else
		    dialog --clear --backtitle "PortMaster v$curversion" --title "$1" --clear --msgbox "\n\n$1 did NOT install. \
		    \n\nYour roms partition seems to be full." $height $width 2>&1 > /dev/tty0
		  fi
		else
		  if [[ "$setwebsiteback" == "Y" ]]; then
		    website="https://raw.githubusercontent.com/christianhaitian/PortMaster/main/"
		  fi
		  dialog --clear --backtitle "PortMaster v$curversion" --title "$1" --clear --msgbox "\n\n$1 failed to download successfully.  The PortMaster server maybe busy or check your internet connection." $height $width 2>&1 > /dev/tty0
		fi
        $ESUDO rm -f /dev/shm/portmaster/$installloc
	    ;;
	 *) if [[ "$setwebsiteback" == "Y" ]]; then
		  website="https://raw.githubusercontent.com/christianhaitian/PortMaster/main/"
		fi
		;;
  esac
}

userExit() {
  rm -f /dev/shm/portmaster/ports.md
  $ESUDO kill -9 $(pidof oga_controls)
  $ESUDO systemctl restart oga_events &
  exit 0
}

MainMenu() {
  local options=(
   $(cat /dev/shm/portmaster/ports.md | $GREP -oP '(?<=Title=").*?(?=")')
  )

  while true; do
    selection=(dialog \
   	--backtitle "PortMaster v$curversion" \
   	--title "[ Main Menu ]" \
   	--no-collapse \
   	--clear \
	--cancel-label "$hotkey + Start to Exit" \
    --menu "Available ports for install" $height $width 15)

    choices=$("${selection[@]}" "${options[@]}" 2>&1 > /dev/tty0) || userExit

    for choice in $choices; do
      case $choice in
        *) PortInfoInstall $choice ;;
      esac
    done
  done
}

dialog --clear --backtitle "PortMaster v$curversion" --title "$1" --clear \
--yesno "\nWould you like to check for an update to the PortMaster tool?" $height $width 2>&1 > /dev/tty0

  case $? in
     0) UpdateCheck;;
  esac

MainMenu
