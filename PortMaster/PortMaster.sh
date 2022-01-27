#!/bin/bash
#
# PortMaster
# https://github.com/christianhaitian/arkos/wiki/PortMaster
# Description : A simple tool that allows you to download
# various game ports that are available for RK3326 devices
# using 351Elec, ArkOS, EmuElec, RetroOZ, and TheRA.
#

ESUDO="sudo"
GREP="grep"
WGET="wget"
export DIALOGRC=/
app_colorscheme="Default"

sudo echo "Testing for sudo..."
if [ $? != 0 ]; then
  ESUDO=""
  export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/storage/roms/ports/PortMaster/libs"
  GREP="/storage/roms/ports/PortMaster/grep"
  WGET="/storage/roms/ports/PortMaster/wget"
  LANG=""
else
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

  isitarkos=$($GREP "title=" /usr/share/plymouth/themes/text.plymouth)
  if [[ $isitarkos == *"ArkOS"* ]]; then
    if [[ ! -z $( timedatectl | grep inactive ) ]]; then
      $ESUDO timedatectl set-ntp 1
	fi
  fi
fi

$ESUDO chmod 666 /dev/tty0
export TERM=linux
export XDG_RUNTIME_DIR=/run/user/$UID/
printf "\033c" > /dev/tty0
dialog --clear

hotkey="Select"
height="15"
width="55"
power=""

if [[ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]]; then
  param_device="anbernic"
  if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ $(cat "/storage/.config/.OS_ARCH") == "RG351V" ]; then
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
elif [[ -e "/dev/input/by-path/platform-singleadc-joypad-event-joystick" ]]; then
  param_device="rg552"
  $ESUDO setfont /usr/share/consolefonts/Lat7-Terminus20x10.psf.gz
  height="20"
  width="60"
  power='(?<=Title_P=\").*?(?=\")'
else
  param_device="chi"
  hotkey="1"
  $ESUDO setfont /usr/share/consolefonts/Lat7-Terminus20x10.psf.gz
  height="20"
  width="60"
fi

if [[ -e "/storage/.config/.OS_ARCH" ]]; then
  toolsfolderloc="/storage/roms/ports"
else
  isitthera=$($GREP "title=" "/usr/share/plymouth/themes/text.plymouth")
  if [[ $isitthera == *"TheRA"* ]]; then
    if [ -d "/opt/tools/PortMaster/" ]; then
      toolsfolderloc="/opt/tools"
    else
      toolsfolderloc="/roms/ports"
    fi
  else
    if [ -d "/opt/system/Tools/PortMaster/" ]; then
      toolsfolderloc="/opt/system/Tools"
    else
      toolsfolderloc="/roms/ports"
    fi
  fi
fi

isitext=$(df -PTh $toolsfolderloc | awk '{print $2}' | grep ext)

cd $toolsfolderloc/PortMaster

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

website="https://github.com/PortsMaster/PortMaster-Releases/releases/latest/download/"
isgithubrelease="true" #Github releases convert space " " ("%20") to "."

ISITCHINA=$(curl -s --connect-timeout 30 -m 60 http://demo.ip-api.com/json | $GREP -Po '"country":.*?[^\\]"')

if [[ "$ISITCHINA" == "\"country\":\"China\"" ]]; then
  website="http://139.196.213.206/arkos/ports/"
  isgithubrelease="false"
fi

if [ ! -d "/dev/shm/portmaster" ]; then
  mkdir /dev/shm/portmaster
fi

UpdateCheck() {

  gitversion=$(curl -L -s --connect-timeout 30 -m 60 ${website}version)

  if [[ "$gitversion" != "$curversion" ]]; then
    
	dialog --clear --backtitle "PortMaster v$curversion" --title "$1" --clear \
--yesno "\nThere's an update for PortMaster ($gitversion).  Would you like to download it now?" $height $width 2>&1 > /dev/tty0

    case $? in
	   0) 
		$WGET -t 3 -T 60 -q --show-progress "${website}PortMaster.zip" -O /dev/shm/portmaster/PortMaster.zip 2>&1 | stdbuf -oL sed -E 's/\.\.+/---/g'| dialog \
			  --progressbox "Downloading and installing PortMaster update..." $height $width > /dev/tty0
		if [ ${PIPESTATUS[0]} -eq 0 ]; then
		  unzip -X -o /dev/shm/portmaster/PortMaster.zip -d $toolsfolderloc/
		  mv -f $toolsfolderloc/PortMaster/PortMaster.sh $toolsfolderloc/.
		  if [ ! -z $isitext ]; then
			$ESUDO chmod -R 777 $toolsfolderloc/PortMaster
			$ESUDO chmod 777 $toolsfolderloc/PortMaster.sh
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
        ;;
    esac
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

  if [[ "$isgithubrelease" == "true" ]]; then
    #Github releases convert space " " ("%20") to "."
    # Examples:
    #  - "Bermuda%20Syndrome" -> "Bermuda.Syndrome"
    #  - "Bermuda Syndrome" -> "Bermuda.Syndrome"
    #  - "Mr. Boom" -> "Mr.Boom" (note how space is removed)
    installloc="$( echo "$installloc" | sed 's/%20/./g' | sed 's/ /./g' | sed 's/\.\././g' )"
  fi

  dialog --clear --backtitle "PortMaster v$curversion" --title "$1" --clear \
  --yesno "\n$msgtxt \n\nPorted By: $porter\n\nWould you like to continue to install this port?" $height $width 2>&1 > /dev/tty0

  case $? in
     0) $WGET -t 3 -T 60 -q --show-progress "$website$installloc" -O \
	    /dev/shm/portmaster/$installloc 2>&1 | stdbuf -oL sed -E 's/\.\.+/---/g'| dialog --progressbox \
		"Downloading ${1} package..." $height $width > /dev/tty0
        unzip -o /dev/shm/portmaster/$installloc -d /$whichsd/ports/ > /dev/tty0
        unzipstatus=$?
		if [ $unzipstatus -eq 0 ] || [ $unzipstatus -eq 1 ]; then
		  if [ ! -z $isitext ]; then
		    $ESUDO chmod -R 777 /$whichsd/ports
		  fi
		  if [[ -e "/storage/.config/.OS_ARCH" ]]; then
		    cd /$whichsd/ports/
		    for s in *.sh
			do
			  if [[ -z $(cat "$s" | $GREP "ESUDO") ]] || [[ -z $(cat "$s" | $GREP "controlfolder") ]]; then
			    sed -i 's/sudo //g' /storage/roms/ports/"$s"
			  fi
			done
		  fi
		  cd $toolsfolderloc
		  dialog --clear --backtitle "PortMaster v$curversion" --title "$1" --clear --msgbox "\n\n$1 installed successfully. \
		  \n\nMake sure to restart EmulationStation in order to see it in the ports menu." $height $width 2>&1 > /dev/tty0
		elif [ $unzipstatus -eq 2 ] || [ $unzipstatus -eq 3 ] || [ $unzipstatus -eq 9 ] || [ $unzipstatus -eq 51 ]; then
		  dialog --clear --backtitle "PortMaster v$curversion" --title "$1" --clear --msgbox "\n\n$1 did NOT install. \
		  \n\nIt did not download correctly.  Please check your internet connection and try again." $height $width 2>&1 > /dev/tty0
		elif [ $unzipstatus -eq 50 ]; then
		  dialog --clear --backtitle "PortMaster v$curversion" --title "$1" --clear --msgbox "\n\n$1 did NOT install. \
		  \n\nYour roms partition seems to be full." $height $width 2>&1 > /dev/tty0
		else
		  dialog --clear --backtitle "PortMaster v$curversion" --title "$1" --clear --msgbox "\n\n$1 did NOT install. \
		  \n\nUnzip error code:$unzipstatus " $height $width 2>&1 > /dev/tty0
		fi

	    $ESUDO rm -f /dev/shm/portmaster/$installloc
	    ;;
	 *) 
	    ;;
  esac
}

userExit() {
  rm -f /dev/shm/portmaster/ports.md
  $ESUDO kill -9 $(pidof oga_controls)
  $ESUDO systemctl restart oga_events &
  dialog --clear
  printf "\033c" > /dev/tty0
  exit 0
}
SetColorScheme() {
  if [ "$app_colorscheme" == "Default" ]; then
	export DIALOGRC=$toolsfolderloc/PortMaster/colorscheme/$app_colorscheme.dialogrc
    if [[ -e "$toolsfolderloc/PortMaster/PortMaster.sh" ]]; then
      sed -i "/export DIALOGRC\=\//c\export DIALOGRC\=\/" $toolsfolderloc/PortMaster/PortMaster.sh
    fi
    if [[ -e "$toolsfolderloc/PortMaster.sh" ]]; then
      sed -i "/export DIALOGRC\=\//c\export DIALOGRC\=\/" $toolsfolderloc/PortMaster.sh
    fi
  else
    export DIALOGRC=$toolsfolderloc/PortMaster/colorscheme/$app_colorscheme.dialogrc
    if [[ -e "$toolsfolderloc/PortMaster/PortMaster.sh" ]]; then
      sed -i "/export DIALOGRC\=\//c\export DIALOGRC\=$toolsfolderloc\/PortMaster\/colorscheme\/$app_colorscheme.dialogrc" $toolsfolderloc/PortMaster/PortMaster.sh
    fi
    if [[ -e "$toolsfolderloc/PortMaster.sh" ]]; then
      sed -i "/export DIALOGRC\=\//c\export DIALOGRC\=$toolsfolderloc\/PortMaster\/colorscheme\/$app_colorscheme.dialogrc" $toolsfolderloc/PortMaster.sh
    fi
  fi
}

ColorSchemeMenu() {
  local cmd
  local options
  local choice
  local retval
  local dialog_config
  local temp

  dialog_config=(${toolsfolderloc}/PortMaster/colorscheme/*.dialogrc) # This creates an array of the full paths to all .dialogrc files
  dialog_config=("${dialog_config[@]##*/}") #Remove path prefix
  dialog_config=("${dialog_config[@]%.*}") #Get filename without extension
  cmd=(dialog \
    --clear \
	--backtitle "PortMaster v$curversion" \
	--title " [ Color Scheme Selection ] " \
	--no-collapse \
	--cancel-label "Back" \
	--menu "Select the PortMaster UI color scheme :" $height $width "15")

  options+=(Default ".")

  for temp in "${dialog_config[@]}"; do
    if [ "$temp" == "Default" ]; then
      echo "Skip default"
    else
      options+=($temp ".")
    fi
  done

  choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty0)
  retval=$?

  case $retval in
  0)
    if [ "$choice" != "$app_colorscheme" ]; then
      app_colorscheme=$choice
      SetColorScheme
    fi
	ColorSchemeMenu
    ;;
  1)
    Settings
    ;;
  *)
    Settings
    ;;
  esac
}

Settings() {
  if [[ ! -z $(cat $toolsfolderloc/PortMaster/gamecontrollerdb.txt | $GREP x:b2) ]]; then
    local curctrlcfg="Switch to Xbox 360 Control Layout"
  else
    local curctrlcfg="Switch to Default Control Layout"
  fi
  
  local settingsoptions=( 1 "Restore Backup gamecontrollerdb.txt" 2 "$curctrlcfg" 3 "UI Color Scheme" 4 "Go Back" )

  while true; do
    settingsselection=(dialog \
   	--backtitle "PortMaster v$curversion" \
   	--title "[ Settings Menu ]" \
   	--no-collapse \
   	--clear \
	--cancel-label "$hotkey + Start to Exit" \
    --menu "What do you want to do?" $height $width 15)
	
	settingschoices=$("${settingsselection[@]}" "${settingsoptions[@]}" 2>&1 > /dev/tty0) || TopLevel

    for choice in $settingschoices; do
      case $choice in
        1) cp -f $toolsfolderloc/PortMaster/.Backup/donottouch.txt $toolsfolderloc/PortMaster/gamecontrollerdb.txt
		   if [ $? == 0 ]; then
		     dialog --clear --backtitle "PortMaster v$curversion" --title "$1" --clear --msgbox "\n\nThe default gamecontrollerdb.txt has been successfully restored." $height $width 2>&1 > /dev/tty0
		   else
		     dialog --clear --backtitle "PortMaster v$curversion" --title "$1" --clear --msgbox "\n\nThe default gamecontrollerdb.txt has failed to be restored.  Is the backup portmaster subfolder or it's contents missing?" $height $width 2>&1 > /dev/tty0
		   fi
		   Settings
        ;;
		2) if [[ $curctrlcfg == "Switch to Xbox 360 Control Layout" ]]; then
		     sed -i 's/x:b2/x:b3/g' $toolsfolderloc/PortMaster/gamecontrollerdb.txt
			 sed -i 's/y:b3/y:b2/g' $toolsfolderloc/PortMaster/gamecontrollerdb.txt
			 if [[ $param_device != "anbernic" ]]; then
			   sed -i 's/a:b0/a:b1/g' $toolsfolderloc/PortMaster/gamecontrollerdb.txt
			   sed -i 's/b:b1/b:b0/g' $toolsfolderloc/PortMaster/gamecontrollerdb.txt
			 else
			   sed -i 's/a:b1/a:b0/g' $toolsfolderloc/PortMaster/gamecontrollerdb.txt
			   sed -i 's/b:b0/b:b1/g' $toolsfolderloc/PortMaster/gamecontrollerdb.txt
			 fi
		   else
		     sed -i 's/x:b3/x:b2/g' $toolsfolderloc/PortMaster/gamecontrollerdb.txt
			 sed -i 's/y:b2/y:b3/g' $toolsfolderloc/PortMaster/gamecontrollerdb.txt
			 if [[ $param_device != "anbernic" ]]; then
			   sed -i 's/a:b1/a:b0/g' $toolsfolderloc/PortMaster/gamecontrollerdb.txt
			   sed -i 's/b:b0/b:b1/g' $toolsfolderloc/PortMaster/gamecontrollerdb.txt
			 else
			   sed -i 's/a:b0/a:b1/g' $toolsfolderloc/PortMaster/gamecontrollerdb.txt
			   sed -i 's/b:b1/b:b0/g' $toolsfolderloc/PortMaster/gamecontrollerdb.txt
			 fi
		   fi
		   Settings
		;;
		3) ColorSchemeMenu
		;;
		4) TopLevel
		;;
      esac
    done
  done
}

MainMenu() {
  local options=(
   $(cat /dev/shm/portmaster/ports.md | $GREP -oP "(?<=Title=\").*?(?=\")|$power")
  )

  while true; do
    selection=(dialog \
   	--backtitle "PortMaster v$curversion" \
   	--title "[ Main Menu of all ports]" \
   	--no-collapse \
   	--clear \
	--cancel-label "$hotkey + Start to Exit" \
    --menu "Available ports for install" $height $width 15)

    choices=$("${selection[@]}" "${options[@]}" 2>&1 > /dev/tty0) || TopLevel

    for choice in $choices; do
      case $choice in
        *) PortInfoInstall $choice ;;
      esac
    done
  done
}

MainMenuRTR() {
  local options=(
   $(cat /dev/shm/portmaster/ports.md | $GREP 'runtype="rtr"' | $GREP -oP "(?<=Title=\").*?(?=\")|$power")
  )

  while true; do
    selection=(dialog \
   	--backtitle "PortMaster v$curversion" \
   	--title "[ Main Menu for Ready to Run ports ]" \
   	--no-collapse \
   	--clear \
	--cancel-label "$hotkey + Start to Exit" \
    --menu "Available Ready to Run ports for install" $height $width 15)

    choices=$("${selection[@]}" "${options[@]}" 2>&1 > /dev/tty0) || TopLevel

    for choice in $choices; do
      case $choice in
        *) PortInfoInstall $choice ;;
      esac
    done
  done
}

TopLevel() {
  local topoptions=( 1 "All Available Ports" 2 "Ready to Run Ports" 3 "Settings" )

  while true; do
    topselection=(dialog \
   	--backtitle "PortMaster v$curversion" \
   	--title "[ Top Level Menu ]" \
   	--no-collapse \
   	--clear \
	--cancel-label "$hotkey + Start to Exit" \
    --menu "Please make your selection" $height $width 15)
	
	topchoices=$("${topselection[@]}" "${topoptions[@]}" 2>&1 > /dev/tty0) || userExit

    for choice in $topchoices; do
      case $choice in
        1) MainMenu ;;
		2) MainMenuRTR ;;
		3) Settings ;;
      esac
    done
  done
}

UpdateCheck
TopLevel
