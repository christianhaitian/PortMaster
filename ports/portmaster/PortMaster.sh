#!/bin/bash
#
# PortMaster
# https://github.com/christianhaitian/arkOS/wiki/PortMaster
# Description : A simple tool that allows you to download
# various game ports that are available for RK3326 DEVICEs
# using 351Elec and Ubuntu based distrOS such as ArkOS, TheRA, and RetroOZ.
#
set -e
set -o pipefail
set -u

 # Help out Mac users testing portmaster - no reason for most ports to do this
if [[ $OSTYPE == 'darwin'* ]]; then
  if ! which brew &> /dev/null; then
   echo "ERROR: brew can be used to install packages needed to test portmaster on a Mac, but is not found.  Install from: https://brew.sh/"
   exit 1
  elif ! which realpath &> /dev/null; then
    brew install coreutils
  fi
fi

DIR="$(realpath $( dirname "${BASH_SOURCE[0]}" ))"
TITLE="PortMaster"

if [ -f "${DIR}/global-functions" ]; then
  source "${DIR}/global-functions"
elif [ -f "${DIR}/../global/global-functions" ]; then
  # This just allows testing directly from the ports/portmaster directory in git - not needed for most ports
  source "${DIR}/../global/global-functions"
fi

OS=$(get_os)
ROMS_DIR=$(get_roms_dir)
TOOLS_DIR=$(get_tools_dir)
HOTKEY=$(get_hotkey)
CONSOLE=$(get_console)
GITHUB_ORG=$(get_github_org)
ESUDO="$(get_sudo)"
WGET="$(get_wget)"
GREP="$(get_grep)"
PORTMASTER_TMP="/dev/shm"

install_package wget
if [[ "$OS" == "mac" ]]; then
  PORTMASTER_TMP="/var/tmp"
  if ! check_package "ggrep"; then
    brew install "grep"
  fi
fi
echo_err "OS: ${OS} ROMS_DIR: ${ROMS_DIR} TOOLS_DIR: ${TOOLS_DIR} CONSOLE: ${CONSOLE} HOTKEY: ${HOTKEY} SUDO: ${ESUDO} GREP: ${GREP}" 

# If you set an environment variable LEGACY=true we will download from zips in the repo as before instead from releases
# This is mostly for testing to ensure things are working as expected and maybe as a 'bridge' before we get to releases
if [[ -z "${LEGACY:-}" ]]; then
  LEGACY="false"
fi

WEBSITE="https://github.com/${GITHUB_ORG}/PortMaster/releases/latest/download/"

if [[ "${LEGACY}" == "true" ]]; then
  WEBSITE="https://raw.githubusercontent.com/${GITHUB_ORG}/PortMaster/main/"
  WEBSITE_IN_CHINA="http://139.196.213.206/arkos/ports/"
else
  WEBSITE_IN_CHINA="${WEBSITE}"
fi

if [ "${OS}" == "351ELEC" ]; then
  export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${DIR}/libs"
fi

initialize_permissions

if [ ! -d "${PORTMASTER_TMP}/portmaster" ]; then
  $ESUDO mkdir ${PORTMASTER_TMP}/portmaster
fi

CURRENT_VERSION="$(curl "file://$(realpath "${DIR}")/version")"
echo_err "version: ${CURRENT_VERSION}"

dialog_initialize "PortMaster v$CURRENT_VERSION"

launch_with_oga_controls "Portmaster.sh"

if ! is_network_connected; then
  dialog_msg "$TITLE" "\nYour network connection doesn't seem to be working. \
              \nDid you make sure to configure your wifi connection?"

  exit 0
fi

if [[ "$(in_china)" == "true" ]]; then
  WEBSITE="${WEBSITE_IN_CHINA}"
fi

dialog_clear


function UpdateCheck() {

  local version_url="${WEBSITE}version"
  local portmaster_download_zip=${PORTMASTER_TMP}/portmaster/PortMaster.zip
  local gitversion
  gitversion=$(curl -L -s --connect-timeout 30 -m 60 "${version_url}")

  if [[ "$gitversion" != "$CURRENT_VERSION" ]]; then
	  if dialog_yes_no "$TITLE" "\nThere's an update for PortMaster ($gitversion).  Would you like to download it now?"; then
      if dialog_download "${WEBSITE}PortMaster.zip" "${portmaster_download_zip}" "Downloading and installing PortMaster update..."; then
        $ESUDO unzip -X -o ${portmaster_download_zip} -d "${TOOLS_DIR}/"
        if [[ "TheRA" == "${OS}" ]]; then
     		  $ESUDO chmod -R 777 "${DIR}"
     	  fi
        dialog_msg "$TITLE" "PortMaster updated successfully."
     	  $ESUDO rm -f ${portmaster_download_zip} 
     	  exit 0
      else
        dialog_msg "$TITLE" "PortMaster failed to update." 
     	  $ESUDO rm -f ${portmaster_download_zip}
        exit 1
     	fi
    fi
  fi
}

PortInfoInstall() {
  local choice="$1"

  local portmaster_tmp=${PORTMASTER_TMP}/portmaster
  local ports_file=${PORTMASTER_TMP}/portmaster/ports.md
  
  local msgtxt
  msgtxt=$(cat "$ports_file" | grep "$choice" | ${GREP} -oP '(?<=Desc=").*?(?=")')
  local installloc
 
  installloc=$(cat "$ports_file" | grep "$choice" | ${GREP}  -oP '(?<=locat=").*?(?=")')
  if [[ "${LEGACY}" != "true" ]]; then
   installloc="$( echo "$installloc" | sed 's/%20/./g' | sed 's/ /./g' )"  #Github releases convert space " " ("%20") to "."
  fi
  local porter
  porter=$(cat "$ports_file" | grep "$choice" | ${GREP} -oP '(?<=porter=").*?(?=")')
  local port_url="${WEBSITE}${installloc}"

  # LEGACY: Due to size limitation of github files (which don't apply to github releases) files above 100MB are downloaded from another server
  if [[ "${LEGACY}" == "true" ]] && [[ "$installloc" == "SuperTux.zip" || "$installloc" == "UQM.zip" ]]; then
     port_url="${WEBSITE_IN_CHINA}${installloc}"
  fi

  if dialog_yes_no "$choice" "$msgtxt \n\nPorted By: $porter\n\nWould you like to continue to install this port?"; then
    if dialog_download "${port_url}" "$portmaster_tmp/$installloc" "Downloading ${1} package..."; then
      
      local unzipstatus="0"
      $ESUDO unzip -o $portmaster_tmp/$installloc -d ${ROMS_DIR}/ports/ || unzipstatus="$?"
      
      if [ $unzipstatus -eq 0 ] || [ $unzipstatus -eq 1 ]; then
  		  if [[ "$OS" == "TheRA" ]]; then
  		    $ESUDO chmod -R 777 ${ROMS_DIR}/ports
  		  fi
  			if [[ "${OS}" == "351ELEC" ]]; then
  			  sed -i 's/sudo //g' ${ROMS_DIR}/ports/*.sh
  			fi
        dialog_msg "$choice" "\n$choice installed successfully. \
  		    \n\nMake sure to restart EmulationStation in order to see it in the ports menu."
  		elif [ $unzipstatus -eq 2 ] || [ $unzipstatus -eq 3 ] || [ $unzipstatus -eq 9 ] || [ $unzipstatus -eq 51 ]; then
		    dialog_msg "$choice" "\n$choice did NOT install. \
		        \n\nIt did not download correctly and the zip appeared corrupt.  Please check your internet connection and try again."
	  	elif [ $unzipstatus -eq 50 ]; then
		    dialog_msg "$choice"  "\n$choice did NOT install. \
		        \n\nYour roms partition seems to be full."
		  else
		    dialog_msg "$choice" "\n$choice did NOT install. \
		        \n\nUnzip error code: $unzipstatus "
      fi
    else
      dialog_msg "$choice" "$choice failed to install successfully."
    fi
  else
    dialog_msg "$choice" "$choice failed to download successfully.  \n\nThe PortMaster server maybe busy or check your internet connection."
  fi
  $ESUDO rm -f "$portmaster_tmp/$installloc"

}

Cleanup() {
  set +e

  echo_err "removing ports.md"
  $ESUDO rm -f ${PORTMASTER_TMP}/portmaster/ports.md

  echo_err "done"
  dialog_clear
}

MainMenu() {

  local options=(
   $($ESUDO cat ${PORTMASTER_TMP}/portmaster/ports.md | $(get_grep) -oP '(?<=Title=").*?(?=")')
  )
                                                                                                         
  while true; do
    selection=$(dialog_menu "[ Main Menu ]" "Available ports for install" "$HOTKEY + Start to Exit" ${options[@]})                                                                                                                                                                                                                             
                                                                                                                                                                                                                
    if [[ -n "$selection" ]]; then                                                                                                                                                                                                                       
       PortInfoInstall "$selection"                                                                                                                                                                                                                      
    else                                                                                                                                                                                                                                                 
       exit 0                                                                                                                                                                                                                                          
    fi                                                                                                                                                                                                                                                   
  done              
}

if [[ "${IS_TEST_MODE:-}" == "true" ]]; then
  echo "done - test mode active"
  exit 0
fi

$ESUDO wget -t 3 -T 60 --no-check-certificate "$WEBSITE"ports.md -O ${PORTMASTER_TMP}/portmaster/ports.md
echo_err "downloaded ports.md"

run_at_exit Cleanup

UpdateCheck

MainMenu

