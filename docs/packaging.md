# Packaging ports for PortMaster
## Be aware that as of 11/7/2021, the packaging requirements list below are now met by just sourcing controls.txt from the PortMaster folder.  At the start of your port script just include the following:
```
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
```
and the $ESUDO, $directory, $param_device and necessary sdl configuration controller configurations will be sourced from the control.txt file shown [here](https://github.com/christianhaitian/PortMaster/blob/main/PortMaster/control.txt). \
Thanks to JohnnyonFlame, dhwz, romadu, and shantigilbert for this easier to manage solution for common variables and future expansion needs if and when applicable.

For an example of how a shell script can be setup to pull this info, see Blobby Volley 2's script below. \
**Note**:  This Blobby Volley 2 package allows for mouse conrol using the right analog stick on dual analog stick devices (such as the OGS or RG351MP) or on the singular analog stick device such as the OGA or RGB10.
Hence the reason the package provies 2 configuration files for gptokeyb and is selected based on the $ANALOGSTICKS variable.

```
#!/bin/bash

# Below we assign the source of the control folder (which is the PortMaster folder) based on the distro:
if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster" # Location for ArkOS which is mapped from /roms/tools or /roms2/tools for devices that support 2 sd cards and have them in use.
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster" # Location for TheRA
else
  controlfolder="/roms/ports/PortMaster" # Location for 351Elec and RetroOZ
fi

source $controlfolder/control.txt # We source the control.txt file contens here

get_controls # We pull the controller configs from the get_controls function from the control.txt file here

# We switch to the port's directory location below
cd /$directory/ports/blobbyvolley2

# Some ports like to create save files or settings files in the user's home folder or other locations.  Let's use symlinks reroute that to a location
# within the ports folder so the data stays with the port installation for easy backup and portability.
$ESUDO rm -rf ~/.blobby
ln -sfv /$directory/ports/blobbyvolley2/conf/.blobby ~/

# Make sure uinput is accessible so we can make use of the gptokeyb controls.  351Elec always runs in root, naughty naughty.  The other distros don't so the $ESUDO
# variable provides the sudo or not dependant on the OS this script is run from.
$ESUDO chmod 666 /dev/uinput

# We launch gptokeyb using this $GPTOKEYB variable as it will take care of sourcing the executable from the central location,
# assign the appropriate exit hotkey dependent on the device (ex. select + start for rg351 devices and minus + start for the rgb10),
#and assign the appropriate method for killing an executable dependent on the OS the port is run from.
$GPTOKEYB "blobby" -c "./blobby.gptk.$ANALOGSTICKS" &

# Now we launch the port's executable and provide the location of specific libraries in may need along with the appropriate
# controller configuration if it recognizes SDL controller input
LD_LIBRARY_PATH="$PWD/libs" SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./blobby 2>&1 | tee -a ./log.txt

# Although you can kill most of the ports (if not all of the ports) via a hotkey, the user may choose to exit gracefully.
# That's fine but let's make sure gptokeyb is killed so we don't get ghost inputs or worse yet, launch it again and have 2 or more of them running.
$ESUDO kill -9 $(pidof gptokeyb)

# The line below is helpful for ArkOS, RetroOZ, and TheRA as some of these ports tend to cause the global hotkeys (like brightness and volume control)
# to stop working after exiting the port for some reason.
$ESUDO systemctl restart oga_events &

# Finally we clean up the terminal screen just for neatness sake as some people care about this.
printf "\033c" >> /dev/tty1
```

### (Historical information below.  No longer needed or should be included in port scripts!)

Because the intention of the ports in PortMaster is to be as broadly compatible as possible with 351Elec and Ubuntu based custom firmwares for the RK3326 devices, there are some prerequisites the packages ports have to meet which are as follows

### 351Elec runs everything as root.  sudo is not needed nor does it work on 351Elec.  Ubuntu based distros like ArkOS, TheRA and RetroOZ does support sudo though.~~

So it's important to accomodate these differences as certain commands, as you'll read below, need sudo on Ubuntu based distros and some don't.  We need to make sudo available as an updatable variable instead.  A good solution for this is to check if the distro has a .OS_ARCH file located in a /storage/.config location.  Only 351Elec has such a file and such a location for that matter between among these defined distros.
```
ESUDO="sudo"
if [ -f "/storage/.config/.OS_ARCH" ]; then
  ESUDO=""
  export LD_LIBRARY_PATH="/storage/roms/ports/shadow-warrior/libs"
fi
```
As a side note, you can also `cat` that .OS_ARCH file to find out which unit 351Elec is running on such as RG351V or RG351MP.  
```
if [ $(cat "/storage/.config/.OS_ARCH") == "RG351V" ]; then
  echo "Do something"
fi
```

### Identifying which rk3326 device it's being run from in order to set various parameters like gamepad controls and screen resolution.

The best solution I've seen so far is to look at the device's gamecontroller existence in /dev/input/by-path/.  In some cases, you can also look in emulationstation's es_systems.cfg file to differentiate between a OGA 1.0(RK2020) and OGA 1.1(RGB10) unit.
  As an example, here's how I typically do this for the Chi, Anbernic, OGA, OGS and the RK2020,
```  
if [[ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]]; then
  echo "anbernic"
elif [[ -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
  if [[ ! -z $(cat /etc/emulationstation/es_input.cfg | grep "190000004b4800000010000001010000") ]]; then
    echo "oga"
  else
    echo "rk2020"
  fi
elif [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]]; then
  echo "ogs"
else
  echo "chi"
fi
```
### Provide the ability to force quit a port where possible.

You can use [oga_controls](https://github.com/christianhaitian/oga_controls.git) to do this.  Just have it launched before the actual port is launched and provide the name of the port's executable and fork it to the background.

ex. `$ESUDO ./oga_controls opentyrian rk2020 &`
Note: if the port is using it's own builtin gamepad control, be sure to disable oga_controls' button definitions so they don't potentially interfere with controls.  You do this by providing a oga_controls_settings.txt file in the same directory as oga_controls with all inputs disabled using `\"` so it just serves as an exit daemon.

ex.

oga_controls_settings.txt with all input buttons disabled

```
back = \"
start = \"
a = \"
b = \"
x = \"
y = \"
l1 = \"
l2 = \"
l3 = \"
r1 = \"
r2 = \"
r3 = \"
up = \"
down = \" 
left = \"
right = \"
left_analog_up = \"
left_analog_down = \"
left_analog_left = \"
left_analog_right = \"
right_analog_up = \"
right_analog_down = \" 
right_analog_left = \"
right_analog_right = \"
```

you can also use [gptokeyb](https://github.com/christianhaitian/gptokeyb) which works similarly to oga_controls but has much better mouse based controls.  

## If the port needs keyboard controls, you can use [oga_controls](https://github.com/christianhaitian/oga_controls.git) to emulate keyboard presses.  Reassignment of keyboard keys can be done via oga_controls_settings.txt.  The default assigned keys can be reviewed [here](https://github.com/christianhaitian/oga_controls/blob/17325791c46c1ee4ec2ad68d44b4ebb2fb305433/main.c#L69)

It's important to note that when running oga_controls, you need to provide a name of the executable so it can kill the application using the device's hotkey combo as well as the device (anbernic, chi, oga, ogs, rk2020) so the keys can be assigned properly.  

`$ESUDO ./oga_controls opentyrian chi &`

As an aside, the reason for the rk2020 be assigned separate from the oga is because the rk2020 is missing one of the keys that is used by the oga for using hotkeys to kill applications.

you can also use [gptokeyb](https://github.com/christianhaitian/gptokeyb) which works similarly to oga_controls but has much better mouse based controls.  

### If the port uses SDL gamecontroller controls.  Assign them to a gamecontrollerdb.txt file or provide the controls to the port via SDL_GAMECONTROLLERCONFIG= during execution or as an export.

You can have these preassigned per supported device so depending on which device is identified during execution, it will have the proper SDL_GAMECONTROLLERCONFIG info.

ex.

```
if [[ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]]; then
  sdl_controllerconfig="03000000091200000031000011010000,OpenSimHardware OSH PB Controller,a:b1,b:b0,x:b3,y:b2,leftshoulder:b4,rightshoulder:b5,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,dpup:h0.1,leftx:a0~,lefty:a1~,leftstick:b8,lefttrigger:b10,rightstick:b9,back:b7,start:b6,rightx:a2,righty:a3,righttrigger:b11,platform:Linux,"
elif [[ -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
  if [[ ! -z $(cat /etc/emulationstation/es_input.cfg | grep "190000004b4800000010000001010000") ]]; then
    sdl_controllerconfig="190000004b4800000010000001010000,GO-Advance Gamepad (rev 1.1),a:b1,b:b0,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,dpdown:b9,dpleft:b10,dpright:b11,dpup:b8,leftx:a0,lefty:a1,back:b12,leftstick:b13,lefttrigger:b6,rightstick:b16,righttrigger:b7,start:b17,platform:Linux,"
  else
    sdl_controllerconfig="190000004b4800000010000000010000,GO-Advance Gamepad,a:b1,b:b0,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,dpdown:b7,dpleft:b8,dpright:b9,dpup:b6,leftx:a0,lefty:a1,back:b10,lefttrigger:b12,righttrigger:b13,start:b15,platform:Linux,"
  fi
elif [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]]; then
  sdl_controllerconfig="190000004b4800000011000000010000,GO-Super Gamepad,platform:Linux,x:b2,a:b1,b:b0,y:b3,back:b12,guide:b14,start:b13,dpleft:b10,dpdown:b9,dpright:b11,dpup:b8,leftshoulder:b4,lefttrigger:b6,rightshoulder:b5,righttrigger:b7,leftstick:b15,rightstick:b16,leftx:a0,lefty:a1,rightx:a2,righty:a3,platform:Linux,"
else
  sdl_controllerconfig="19000000030000000300000002030000,gameforce_gamepad,leftstick:b14,rightx:a3,leftshoulder:b4,start:b9,lefty:a0,dpup:b10,righty:a2,a:b1,b:b0,guide:b16,dpdown:b11,rightshoulder:b5,righttrigger:b7,rightstick:b15,dpright:b13,x:b2,back:b8,leftx:a1,y:b3,dpleft:b12,lefttrigger:b6,platform:Linux,"
fi


SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./gmloader gamedata/am2r.apk

```

### At least one RK3326 device (Anbernic RG351V) supports 2 sd card slots.  ArkOS is one that specifically distinguishes when the second sd card is being use or not for games and ports.  If a singular sd card is being used, then there's just a roms partition used for games and ports.  When the second sd card slow is being used, then there's a roms2 partition for games nad ports. That needs to be accounted for:

ex. 
```
if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
  directory="roms2"
else
  directory="roms"
fi
```

### Port specific additional libraries should be included within the port's directory in a separate subfolder named libs.
They can be loaded at runtime using `export LD_LIBRARY_PATH` or using `LD_LIBRARY_PATH=` on the same line as the executable as long as it's before it. \
`LD_LIBRARY_PATH=./libs:$LD_LIBRARY_PATH ./executable`

### Port specific config files that are normally created and stored in the home folder or anywhere outside the port's directory should be symlinked
This allows the port's configuration information to stay within the port's folder.  This is important in order to maintain the portability and ease backup capability for ports for the user.

ex.
```
$ESUDO rm -rf ~/.config/opentyrian
ln -sfv /$directory/ports/opentyrian/ ~/.config/
```

### Now let's put it all together.  Below is an example script for AM2R that incorporates everything mentioned above
```
#!/bin/bash

ESUDO="sudo"
if [ -f "/storage/.config/.OS_ARCH" ]; then
  ESUDO=""
  export LD_LIBRARY_PATH="/storage/roms/ports/shadow-warrior/libs"
fi

if [[ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]]; then
  sdl_controllerconfig="03000000091200000031000011010000,OpenSimHardware OSH PB Controller,a:b1,b:b0,x:b3,y:b2,leftshoulder:b4,rightshoulder:b5,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,dpup:h0.1,leftx:a0~,lefty:a1~,leftstick:b8,lefttrigger:b10,rightstick:b9,back:b7,start:b6,rightx:a2,righty:a3,righttrigger:b11,platform:Linux,"
  param_device="anbernic"
elif [[ -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
  if [[ ! -z $(cat /etc/emulationstation/es_input.cfg | grep "190000004b4800000010000001010000") ]]; then
    sdl_controllerconfig="190000004b4800000010000001010000,GO-Advance Gamepad (rev 1.1),a:b1,b:b0,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,dpdown:b9,dpleft:b10,dpright:b11,dpup:b8,leftx:a0,lefty:a1,back:b12,leftstick:b13,lefttrigger:b6,rightstick:b16,righttrigger:b7,start:b17,platform:Linux,"
    param_device="oga"
  else
    sdl_controllerconfig="190000004b4800000010000000010000,GO-Advance Gamepad,a:b1,b:b0,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,dpdown:b7,dpleft:b8,dpright:b9,dpup:b6,leftx:a0,lefty:a1,back:b10,lefttrigger:b12,righttrigger:b13,start:b15,platform:Linux,"
    param_device="rk2020"
  fi
elif [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]]; then
  sdl_controllerconfig="190000004b4800000011000000010000,GO-Super Gamepad,platform:Linux,x:b2,a:b1,b:b0,y:b3,back:b12,guide:b14,start:b13,dpleft:b10,dpdown:b9,dpright:b11,dpup:b8,leftshoulder:b4,lefttrigger:b6,rightshoulder:b5,righttrigger:b7,leftstick:b15,rightstick:b16,leftx:a0,lefty:a1,rightx:a2,righty:a3,platform:Linux,"
  param_device="ogs"
else
  sdl_controllerconfig="19000000030000000300000002030000,gameforce_gamepad,leftstick:b14,rightx:a3,leftshoulder:b4,start:b9,lefty:a0,dpup:b10,righty:a2,a:b1,b:b0,guide:b16,dpdown:b11,rightshoulder:b5,righttrigger:b7,rightstick:b15,dpright:b13,x:b2,back:b8,leftx:a1,y:b3,dpleft:b12,lefttrigger:b6,platform:Linux,"
  param_device="chi"
fi

$ESUDO chmod 666 /dev/tty1

if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
  directory="roms2"
else
  directory="roms"
fi

export LD_LIBRARY_PATH=/$directory/ports/am2r/libs:/usr/lib:/storage/.config/emuelec/lib32
$ESUDO rm -rf ~/.config/am2r
ln -sfv /$directory/ports/am2r/conf/am2r/ ~/.config/
cd /$directory/ports/am2r
$ESUDO ./oga_controls gmloader $param_device &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./gmloader gamedata/am2r.apk
$ESUDO kill -9 $(pidof oga_controls)
unset LD_LIBRARY_PATH
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty1
```

Notes:  
-  Note that in order to properly assign keys during execution for oga_controls, we have it assigned as a variable depending on what rk3326 device is detected during execution.  
-  We also add an additional kill process for oga_controls because the user may decide to exit a port properly through the port's exit menu.  If that happens, we still need to kill oga_controls or it may cause double key press issues in various menus or if another port is run, double up on the number of oga_controls are still running in memory.
- We're restarting oga_events because for some reason in ArkOS, the use of oga_controls can impact the oga_events which is responsible for system global hotkeys like volume and brightness controls.  This is at least the case for ArkOS.
- The printf command at the bottom is to clean up the terminal tty1 screen so potential key press screen junk doesn't remain and make the screen look messy between other various system functions.  Many people care about this.  ¯\_(ツ)_/¯
