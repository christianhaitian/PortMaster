#!/bin/bash
#
# PortMaster
# https://github.com/christianhaitian/arkos/wiki/PortMaster
# Description : A simple tool that allows you to download
# various game ports that are available for RK3326 devices
# using 351Elec, ArkOS, EmuElec, RetroOZ, and TheRA.
#

if [ -f "/etc/profile" ]; then
  source /etc/profile
fi

ESUDO="sudo"
GREP="grep"
WGET="wget"
export DIALOGRC=/
app_colorscheme="Default"
mono_version="mono-6.12.0.122-aarch64.squashfs"

sudo echo "Testing for sudo..." > /dev/null
if [ $? != 0 ]; then
  ESUDO=""
  export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/storage/roms/ports/PortMaster/libs"
  GREP="/storage/roms/ports/PortMaster/grep"
  #WGET="/storage/roms/ports/PortMaster/wget"
  LANG=""
else
  dpkg -s "curl" &>/dev/null
  if [ "$?" != "0" ]; then
    $ESUDO apt update && $ESUDO apt install -y curl --no-install-recommends
  fi

  dpkg -s "dialog" &>/dev/null
  if [ "$?" != "0" ]; then
    $ESUDO apt update && $ESUDO apt install -y dialog --no-install-recommends
  fi

  isitarkos=$($GREP "title=" /usr/share/plymouth/themes/text.plymouth)
  if [[ $isitarkos == *"ArkOS"* ]]; then
    if [[ ! -z $( timedatectl | grep inactive ) ]]; then
      $ESUDO timedatectl set-ntp 1
  fi
  fi
fi

if [ -f "/etc/os-release" ]; then
  source /etc/os-release
fi

if [[ "${UI_SERVICE}" =~ weston.service ]]; then
  CUR_TTY="/dev/tty"
else
  CUR_TTY="/dev/tty0"
fi

$ESUDO chmod 666 $CUR_TTY
export TERM=linux
export XDG_RUNTIME_DIR=/run/user/$UID/
printf "\033c" > $CUR_TTY
# hide cursor
printf "\e[?25h" > $CUR_TTY
dialog --clear

hotkey="Select"
height="15"
width="55"
power="None"
opengl="None"

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
  if [[ -e "/opt/.retrooz/device" ]]; then
    param_device="$(cat /opt/.retrooz/device)"
    if [[ "$param_device" == *"rgb10max2native"* ]]; then
      param_device="rgb10maxnative"
    elif [[ "$param_device" == *"rgb10max2top"* ]]; then
      param_device="rgb10maxtop"
    fi
  fi
  $ESUDO setfont /usr/share/consolefonts/Lat7-Terminus20x10.psf.gz
  height="20"
  width="60"
  if [ $(cat "/storage/.config/.OS_ARCH") == "RG552" ]; then
    power='(?<=Title_P=\").*?(?=\")'
  fi
elif [[ -e "/dev/input/by-path/platform-singleadc-joypad-event-joystick" ]]; then
  param_device="rg552"
  $ESUDO setfont /usr/share/consolefonts/Lat7-Terminus20x10.psf.gz
  height="20"
  width="60"
  power='(?<=Title_P=\").*?(?=\")'
  hotkey="L3"
else
  param_device="chi"
  hotkey="1"
  $ESUDO setfont /usr/share/consolefonts/Lat7-Terminus20x10.psf.gz
  height="20"
  width="60"
fi

if [[ "${UI_SERVICE}" =~ weston.service ]]; then
  opengl='(?<=Title_F=\").*?(?=\")'
fi

if [[ -e "/storage/.config/.OS_ARCH" ]] || [ "${OS_NAME}" == "JELOS" ] || [ "${OS_NAME}" == "UnofficialOS" ]; then
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

$ESUDO chmod -R +x .

if [ "${OS_NAME}" == "JELOS" ]; then
  # Copy over the JELOS control.txt
  if [ -f /storage/.config/PortMaster/control.txt ]; then
    cp -f /storage/.config/PortMaster/control.txt $toolsfolderloc/PortMaster/control.txt
  fi

  $toolsfolderloc/PortMaster/gptokeyb PortMaster.sh -c "$toolsfolderloc/PortMaster/oga_controls_settings.txt" > /dev/null 2>&1 &
  CONTROLS="gptokeyb"
else
  $ESUDO $toolsfolderloc/PortMaster/oga_controls PortMaster.sh $param_device > /dev/null 2>&1 &
  CONTROLS="oga_controls"
fi

curversion="$(curl file://$toolsfolderloc/PortMaster/version)"

GW=`ip route | awk '/default/ { print $3 }'`
if [ -z "$GW" ]; then
  dialog --clear --backtitle "PortMaster v$curversion" --title "$1" --clear \
  --msgbox "\n\nYour network connection doesn't seem to be working. \
  \nDid you make sure to configure your wifi connection?" $height $width 2>&1 > ${CUR_TTY}

  $ESUDO kill -9 $(pidof "$CONTROLS")
  if [ ! -z "$ESUDO" ]; then
    $ESUDO systemctl restart oga_events &
  fi
  exit 0
fi

website="https://github.com/PortsMaster/PortMaster-Releases/releases/latest/download/"
isgithubrelease="true" #Github releases convert space " " ("%20") to "."

# ISITCHINA=$(curl -s --connect-timeout 30 -m 60 http://demo.ip-api.com/json | $GREP -Po '"country":.*?[^\\]"')

#if [[ "$ISITCHINA" == "\"country\":\"China\"" ]]; then
#  website="http://139.196.213.206/arkos/ports/"
#  isgithubrelease="false"
#fi

if [ ! -d "/dev/shm/portmaster" ]; then
  mkdir /dev/shm/portmaster
fi

UpdateCheck() {

  gitversion=$(curl -L -s --connect-timeout 30 -m 60 ${website}version)

  if [[ "$gitversion" != "$curversion" ]]; then
    
  dialog --clear --backtitle "PortMaster v$curversion" --title "$1" --clear \
--yesno "\nThere's an update for PortMaster ($gitversion).  Would you like to download it now?" $height $width 2>&1 > ${CUR_TTY}

    case $? in
     0) 
    $WGET -t 3 -T 60 -q --show-progress "${website}PortMaster.zip" -O /dev/shm/portmaster/PortMaster.zip 2>&1 | stdbuf -oL sed -E 's/\.\.+/---/g'| dialog \
        --progressbox "Downloading and installing PortMaster update..." $height $width > ${CUR_TTY}
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
      if [[ ! -z $(cat $toolsfolderloc/PortMaster/gamecontrollerdb.txt | $GREP 'Xbox 360 Layout') ]]; then
       local x360="Yes"
      fi
      unzip -X -o /dev/shm/portmaster/PortMaster.zip -d $toolsfolderloc/
      if [ "${OS_NAME}" != "JELOS" ] && [ "${OS_NAME}" != "UnofficialOS" ]; then
        mv -f $toolsfolderloc/PortMaster/PortMaster.sh $toolsfolderloc/.
        if [ -f "$toolsfolderloc/PortMaster/tasksetter.sh" ]; then
          rm -f "$toolsfolderloc/PortMaster/tasksetter.sh"
        fi
      fi

      if [ "${OS_NAME}" == "JELOS" ] && [ -f /storage/.config/PortMaster/control.txt ]; then
        # Copy over the JELOS control.txt
        cp /storage/.config/PortMaster/control.txt $toolsfolderloc/PortMaster/control.txt
      fi

      if [[ "${x360}" == "Yes" ]]; then
       cp -f $toolsfolderloc/PortMaster/.Backup/donottouch_x.txt $toolsfolderloc/PortMaster/gamecontrollerdb.txt
      fi

      if [ ! -z $isitext ]; then
        $ESUDO chmod -R 777 $toolsfolderloc/PortMaster
        $ESUDO chmod 777 $toolsfolderloc/PortMaster.sh
      fi

      dialog --clear --backtitle "PortMaster v$curversion" --title "$1" --clear --msgbox "\n\nPortMaster updated successfully." $height $width 2>&1 > ${CUR_TTY}
      $ESUDO kill -9 $(pidof "$CONTROLS")
      $ESUDO rm -f /dev/shm/portmaster/PortMaster.zip
      if [ ! -z "$ESUDO" ]; then
        $ESUDO systemctl restart oga_events &
      fi
      exit 0
    else
      dialog --clear --backtitle "PortMaster v$curversion" --title "$1" --clear --msgbox "\n\nPortMaster failed to update." $height $width 2>&1 > ${CUR_TTY}
      $ESUDO rm -f /dev/shm/portmaster/PortMaster.zip
    fi
        ;;
    esac
  fi
}

UpdateCheck

# HarbourMaster pipe commands
HM_PIPE="/dev/shm/portmaster/hm_input"
HM_DONE="/dev/shm/portmaster/hm_done"

HarbourCommand() {
  # Send a command to harbourmaster
  local command="$1"
  local wait=0

  if [ ! -e "$HM_PIPE" ]; then
    $ESUDO $toolsfolderloc/PortMaster/harbourmaster --quiet --no-check --no-colour fifo_control "$HM_PIPE" "$HM_DONE" &

    while true; do
      if [ -e "$HM_PIPE" ]; then
        break
      fi

      if [ $wait -gt 15 ]; then
        break
      fi

      wait=$(expr $wait + 1)
      sleep 1
    done
  fi

  if [ -e "$HM_PIPE" ]; then
    if [ -f "$HM_DONE" ]; then
      rm -f "$HM_DONE" > /dev/null
    fi

    echo "$1" | $ESUDO tee $HM_PIPE > /dev/null

    wait=0
    # We wait for a maximum of 15 seconds to say it is done.
    while true; do
      if [ -f "$HM_DONE" ]; then
        break
      fi

      if [ "$wait" -gt 15 ]; then
        break
      fi

      wait=$(expr $wait + 1)
      sleep 1
    done
  fi
}

FilterKey() {
  echo "$1" | sha1sum | cut -b -12
}

HarbourQuit() {
  if [ -e "$HM_PIPE" ]; then
    echo "exit" | $ESUDO tee $HM_PIPE > /dev/null
    rm -f /dev/shm/portmaster/*.md > /dev/null
    rm -f $HM_PIPE > /dev/null
    rm -f $HM_DONE > /dev/null
  fi
}

HarbourUpdate() {
  printf "\033c" > ${CUR_TTY}

  HarbourCommand "update:${CUR_TTY}"

  echo "Reloading Portmaster Info." > ${CUR_TTY}

  rm -f /dev/shm/portmaster/*.md

  PortsMD "" > /dev/null
  PortsMD "rtr" > /dev/null
  PortsMD "installed" > /dev/null
}

HarbourUpgrade() {
  printf "\033c" > ${CUR_TTY}

  HarbourQuit

  $ESUDO $toolsfolderloc/PortMaster/harbourmaster --quiet upgrade harbourmaster > ${CUR_TTY}

  echo "Restarting HarbourMaster." > ${CUR_TTY}

  PortsMD "" > /dev/null
  PortsMD "rtr" > /dev/null
  PortsMD "installed" > /dev/null
}

HarbourReload() {
  printf "\033c" > ${CUR_TTY}

  echo "Reloading PortMaster Info." > ${CUR_TTY}

  HarbourCommand "reload:${CUR_TTY}"

  rm -f /dev/shm/portmaster/*.md

  PortsMD "" > /dev/null
  PortsMD "rtr" > /dev/null
  PortsMD "installed" > /dev/null
}

PortsMD() {
  local filters="$1"
  local portsmd="/dev/shm/portmaster/ports.$(FilterKey "$filters").md"

  if [ ! -f "$portsmd" ]; then
    HarbourCommand "portsmd:$portsmd:$filters"
  fi

  echo "$portsmd"
}

printf "\033c" > ${CUR_TTY}

echo "Starting PortMaster." > ${CUR_TTY}

# Check for an update lazily.
HarbourCommand "auto_update:${CUR_TTY}"

## Cache these.
PortsMD "" > /dev/null
PortsMD "rtr" > /dev/null
PortsMD "installed" > /dev/null

PortInfoInstall() {

  local setwebsiteback="N"
  local installstatus
  local portsmd=$(PortsMD "")

  if [ ! -z "$(cat /etc/fstab | $GREP "roms2" | tr -d '\0')" ]; then
    whichsd="roms2"
  elif [ -f "/storage/.config/.OS_ARCH" ] || [ "${OS_NAME}" == "JELOS" ] || [ "${OS_NAME}" == "UnofficialOS" ]; then
    whichsd="storage/roms"
  else
    whichsd="roms"
  fi
  
  msgtxt=$(cat "$portsmd" | $GREP "$1" | $GREP -oP '(?<=Desc=").*?(?=")')
  installloc=$(cat "$portsmd" | $GREP "$1" | $GREP -oP '(?<=locat=").*?(?=")')
  porter=$(cat "$portsmd" | $GREP "$1" | $GREP -oP '(?<=porter=").*?(?=")')
  needmono=$(cat "$portsmd" | $GREP "$1" | $GREP -oP '(?<=mono=").*?(?=")')

  if [[ -f "$toolsfolderloc/PortMaster/libs/$mono_version" ]]; then
    ismonothere="y"
  else
    ismonothere="n"
  fi

  if [[ "$isgithubrelease" == "true" ]]; then
    #Github releases convert space " " ("%20") to "."
    # Examples:
    #  - "Bermuda%20Syndrome" -> "Bermuda.Syndrome"
    #  - "Bermuda Syndrome" -> "Bermuda.Syndrome"
    #  - "Mr. Boom" -> "Mr.Boom" (note how space is removed)
    installloc="$( echo "$installloc" | sed 's/%20/./g' | sed 's/ /./g' | sed 's/\.\././g' )"
  fi

  if [[ "${needmono,,}" == "y" ]] && [[ "$ismonothere" == "n" ]]; then
    dialog --clear --backtitle "PortMaster v$curversion" --title "$1" --clear \
    --yesno "\n$msgtxt \n\nPorted By: $porter\n\nThis port also requires the download and install 
  of the mono library which is over 200MBs in size.  This download may take a while.
  \n\nWould you like to continue to install this port?" $height $width 2>&1 > ${CUR_TTY}
  else
    dialog --clear --backtitle "PortMaster v$curversion" --title "$1" --clear \
    --yesno "\n$msgtxt \n\nPorted By: $porter\n\nWould you like to continue to install this port?" $height $width 2>&1 > ${CUR_TTY}
  fi

  case $? in
     0)
      printf "\033c" > ${CUR_TTY}

      echo "Downloading $1." > ${CUR_TTY}

      $ESUDO $toolsfolderloc/PortMaster/harbourmaster --quiet --no-check install "$installloc" > ${CUR_TTY}
      installstatus=$?
      if [ $installstatus -eq 0 ]; then
        if [ ! -z $isitext ]; then
          $ESUDO chmod -R 777 /$whichsd/ports
        fi
        dialog --clear --backtitle "PortMaster v$curversion" --title "$1" --clear --msgbox "\n\n$1 installed successfully. \
        \n\nMake sure to restart EmulationStation in order to see it in the ports menu." $height $width 2>&1 > ${CUR_TTY}

        HarbourReload
      else
        dialog --clear --backtitle "PortMaster v$curversion" --title "$1" --clear --msgbox "\n\n$1 did NOT install." \
        $height $width 2>&1 > ${CUR_TTY}
      fi
      ;;
   *) 
      ;;
  esac
}

PortUninstall() {

  local portsmd=$(PortsMD "")
  
  installloc=$(cat "$portsmd" | $GREP "$1" | $GREP -oP '(?<=locat=").*?(?=")')

  dialog --clear --backtitle "PortMaster v$curversion" --title "$1" --clear \
  --yesno "\n\n****WARNING****\n\nWould you like to uninstall $1?\n\n****WARNING****" $height $width 2>&1 > ${CUR_TTY}

  case $? in
     0)
      printf "\033c" > ${CUR_TTY}

      echo "Uninstalling $1." > ${CUR_TTY}

      $ESUDO $toolsfolderloc/PortMaster/harbourmaster --quiet --no-check uninstall "$installloc" > ${CUR_TTY}
      installstatus=$?
      if [ $installstatus -eq 0 ]; then
        if [ ! -z $isitext ]; then
          $ESUDO chmod -R 777 /$whichsd/ports
        fi
        dialog --clear --backtitle "PortMaster v$curversion" --title "$1" --clear --msgbox "\n\n$1 uninstalled successfully. \
        \n\nMake sure to restart EmulationStation in order to remove it from the ports menu." $height $width 2>&1 > ${CUR_TTY}

        HarbourReload
      else
        dialog --clear --backtitle "PortMaster v$curversion" --title "$1" --clear --msgbox "\n\n$1 did NOT uninstall." \
        $height $width 2>&1 > ${CUR_TTY}
      fi
      ;;
   *) 
      ;;
  esac
}

userExit() {
  HarbourQuit

  $ESUDO kill -9 $(pidof "$CONTROLS")
  if [ ! -z "$ESUDO" ]; then
    $ESUDO systemctl restart oga_events &
  fi
  dialog --clear
  printf "\033c" > ${CUR_TTY}
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

  choice=$("${cmd[@]}" "${options[@]}" 2>&1 >${CUR_TTY})
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
  if [[ ! -z $(cat $toolsfolderloc/PortMaster/gamecontrollerdb.txt | $GREP 'Default Layout') ]]; then
    local curctrlcfg="Switch to Xbox 360 Control Layout"
  else
    local curctrlcfg="Switch to Default Control Layout"
  fi
  
  local settingsoptions=( 1 "Restore Backup gamecontrollerdb.txt" 2 "$curctrlcfg" 3 "UI Color Scheme" 4 "Update Ports List" 5 "Upgrade HarbourMaster" 6 "Go Back" )

  while true; do
    settingsselection=(dialog \
    --backtitle "PortMaster v$curversion" \
    --title "[ Settings Menu ]" \
    --no-collapse \
    --clear \
    --cancel-label "$hotkey + Start to Exit" \
    --menu "What do you want to do?" $height $width 15)
  
  settingschoices=$("${settingsselection[@]}" "${settingsoptions[@]}" 2>&1 > ${CUR_TTY}) || TopLevel

    for choice in $settingschoices; do
      case $choice in
        1) cp -f $toolsfolderloc/PortMaster/.Backup/donottouch.txt $toolsfolderloc/PortMaster/gamecontrollerdb.txt
       if [ $? == 0 ]; then
         dialog --clear --backtitle "PortMaster v$curversion" --title "$1" --clear --msgbox "\n\nThe default gamecontrollerdb.txt has been successfully restored." $height $width 2>&1 > ${CUR_TTY}
       else
         dialog --clear --backtitle "PortMaster v$curversion" --title "$1" --clear --msgbox "\n\nThe default gamecontrollerdb.txt has failed to be restored.  Is the backup portmaster subfolder or it's contents missing?" $height $width 2>&1 > ${CUR_TTY}
       fi
       Settings
        ;;
    2) if [[ $curctrlcfg == "Switch to Xbox 360 Control Layout" ]]; then
       cp -f $toolsfolderloc/PortMaster/.Backup/donottouch_x.txt $toolsfolderloc/PortMaster/gamecontrollerdb.txt
       else
       cp -f $toolsfolderloc/PortMaster/.Backup/donottouch.txt $toolsfolderloc/PortMaster/gamecontrollerdb.txt
       fi
       Settings
    ;;
    3) ColorSchemeMenu
    ;;
    4) HarbourUpdate
    ;;
    5) HarbourUpgrade
    ;;
    6) TopLevel
    ;;
      esac
    done
  done
}

PortsMenu() {
  local filters="$1"
  local original_filters="$filters"
  local portsmd=""

  while true; do
    portsmd=$(PortsMD "$filters")

    local options=(
     $(cat "$portsmd" | $GREP -oP "(?<=Title=\").*?(?=\")|$power|$opengl")
    )

    local filters_available=$(cat "$portsmd" | $GREP -oP "(?<=Filters=\").*?(?=\")")

    if [[ "$filters_available" == "" ]]; then
      filter_option=()
    else
      filter_option=("Filter Games" ".")
    fi

    if [[ "$original_filters" == "rtr" ]]; then
      menu_title="Main Menu for Ready to Run ports"
    else
      menu_title="Main Menu of all ports"
    fi

    if [[ "$filters" != "$original_filters" ]]; then
      menu_title="$menu_title\nFiltered by: ${filters}"
    fi

    if [[ "$filters" != "$original_filters" ]]; then
      options+=("Clear Filters" ".")
    fi

    selection=(dialog \
      --backtitle "PortMaster v$curversion" \
      --title "[ Main Menu of all ports]" \
      --no-collapse \
      --clear \
      --cancel-label "$hotkey + Start to Exit" \
      --menu "$menu_title" $height $width 15)

    choice=$("${selection[@]}" "${filter_option[@]}" "${options[@]}" 2>&1 > ${CUR_TTY}) || TopLevel

    case $choice in
      "Filter Games")
        filters=$(FiltersMenu "$filters")
        ;;
      "Clear Filters")
        filters="$original_filters"
        ;;
      *)
        PortInfoInstall "$choice"
        ;;
    esac
  done
}

UninstallMenu() {
  local portsmd=""

  while true; do
    portsmd=$(PortsMD "installed")

    local options=(
      $(cat "$portsmd" | $GREP -oP "(?<=Title=\").*?(?=\")|$power|$opengl")
    )

    echo "(?<=Title=\").*?(?=\")|$power|$opengl" "${options[@]}" > output.txt
    menu_title="Ports Installed"

    selection=(dialog \
      --backtitle "PortMaster v$curversion" \
      --title "[ Main Menu of Installed Ports ]" \
      --no-collapse \
      --clear \
      --cancel-label "$hotkey + Start to Exit" \
      --menu "$menu_title" $height $width 15)

    choice=$("${selection[@]}" "${options[@]}" 2>&1 > ${CUR_TTY}) || TopLevel

    case $choice in
      *)
        PortUninstall "$choice"
        ;;
    esac
  done
}

FiltersMenu() {
  # Get the list of options as a comma-separated value
  local filters="$1"
  local wait=0
  local portsmd=$(PortsMD "$filters")

  local filters_available=$(cat "$portsmd" | $GREP -oP "(?<=Filters=\").*?(?=\")")

  if [[ "$filters_available" == "" ]]; then
    echo "$filters"
    return 0
  fi

  # Set the IFS variable to comma
  IFS=','

  # Read the options into an array
  read -ra filters_array <<< "$filters_available"

  local options=()

  # Loop through the array and add each option as a pair
  for filter_value in "${filters_array[@]}"; do
    options+=("${filter_value}" ".")
  done

  selection=(dialog \
      --backtitle "PortMaster v$curversion" \
      --title "[ Select Filter ]" \
      --no-collapse \
      --clear \
      --cancel-label "$hotkey + Start to Exit" \
      --menu "Available Filters" $height $width 15)

  # Display the menu using the dialog command
  choice=$("${selection[@]}" "${options[@]}" 2>&1 > ${CUR_TTY})

  # Check if the user pressed the cancel button or closed the dialog window
  if [[ $? -ne 0 ]]; then
    echo "$filters"
    return 0
  fi

  if [[ $filters == "" ]]; then
    echo "$choice"
  else
    echo "$filters,$choice"
  fi

  return 0
}

TopLevel() {
  local topoptions=( 1 "All Available Ports" 2 "Ready to Run Ports" 3 "Uninstall Ports" 4 "Settings" )

  while true; do
    topselection=(dialog \
    --backtitle "PortMaster v$curversion" \
    --title "[ Top Level Menu ]" \
    --no-collapse \
    --clear \
    --cancel-label "$hotkey + Start to Exit" \
    --menu "Please make your selection" $height $width 15)
  
  topchoices=$("${topselection[@]}" "${topoptions[@]}" 2>&1 > ${CUR_TTY}) || userExit

    for choice in $topchoices; do
      case $choice in
        1) PortsMenu "" ;;
        2) PortsMenu "rtr" ;;
        3) UninstallMenu ;;
        4) Settings ;;
      esac
    done
  done
}

## DISABLE for now.
# UpdateCheck

if [ -e $HM_PIPE ]; then
  TopLevel
else
  echo "Unable to initialise HarbourMaster." > ${CUR_TTY}
  sleep 5
  userExit
fi
