## What is PortMaster?

PortMaster is a simple tool that is designed similarly to JohnIrvine's [ThemeMaster](https://github.com/JohnIrvine1433/ThemeMaster) themes management tool that allows you to download various game ports that are available for 351Elec, ArkOS, JelOS, RetroOZ, and TheRA for RK3326 based devices.  Support for the RG552 has been added as well.  A number of ports have been tested and confirmed working with TheRA and RetroOZ.  Ports such as Freedom Planet and Maldita Castilla will be working for TheRA soon.  

One of the goals of PortMaster is to not install or upgrade any existing OS libraries for any ports.  Any of the ports that need a particular non standard library are maintained within the ports' folder and made available specifically to that port during execution.

Most of the the ports available through PortMaster have been configured to launch with proper controls for the Gameforce Chi, Powkiddy RGB10, Anbernic RG351P/M/V/MP, RK2020 and the Odroid Go Advance units.  Controls for the Anbernic RG552, Odroid Go Super and the Powkiddy RGB10 Max are also included and have been tested but not as much as the 3.5" RK3326 devices. 

## Install info

For ArkOS on supported devices, PortMaster was included with a recent online update.  You can locate it in the Options > Tools menu. \
For 351Elec/AmberElec, just unzip the contents of PortMaster.zip to your storage/roms/ports folder then run PortMaster.sh from the Ports menu in 351Elec. \
For JelOS, it's been intergrated into their most recent releases.  Just launch from tools and enjoy! \
If you don't have PortMaster there or need to install it manually, you can do the following:
* Place the PortMaster folder in /roms/tools.  The .sh file **must** remain in the PortMaster folder!
   * For ArkOS on the RG351V, RG351MP, RG353M, RG353V/VS, or RG503,  if SD2 is being used for roms, installation must be in /roms2/tools/. The .sh file **must** remain in the PortMaster folder!
* Run PortMaster from ArkOS, TheRA or RetroOZ through Options > Tools > PortMaster menu, 351Elec/AmberElec from Ports > PortMaster menu

## Do I have to use PortMaster to install ports?

No.  You can simply go to the PortMaster repo (https://github.com/christianhaitian/PortMaster), find the .zip of the port you want, download it and unzip the contents of it to the /roms/ports folder.  You'll also need to copy the PortMaster folder to your /roms/ports folder.  If you don't want the PortMaster folder to show up in your Ports menu in Emulationstation, just delete the PortMaster.sh file as it won't be needed if you don't plan to install or update your ports online via this tool. \

**Note**: For ArkOS on the RG351V or RG351MP, if SD2 is being used for roms, unzip the port to the /roms2/ports folder instead and copy the PortMaster folder to the /roms2/tools location.  A few additional ports are available on the large releases repo (https://github.com/PortsMaster/PortMaster-Releases/releases) due to their size (ex. SuperTux, Ur Quan Masters, and FreedroidRPG).

## How do I get more info about the ports in this repo like the sources used and additional asset needs if applicable?

You can find that information via the ArkOS Emulators and Ports information wiki link [here](https://github.com/christianhaitian/arkos/wiki/ArkOS-Emulators-and-Ports-information#ports).

## If there are updates to Ports, how will that work?

Just run PortMaster and reinstall the port.  You can also unzip the associated .zip for the port you want and unzip the contents of it to the ports folder.  This should install the latest port related files if they've been updated in PortMaster.  In most cases, it should not impact any existing game data you had to provide or existing saves unless the updated port made changes to the port backend that impacts previous saves.

## How can I help add ports to PortMaster?

See the packaging documentation [here](https://github.com/christianhaitian/PortMaster/blob/main/docs/packaging.md) for more info on this.  Once you're port packaging has met these minimum requirements, you can either submit a Pull Request of this port package with details about the port such as a description of it and how to add any gamefiles or assets if needed or contact us at the [PortMaster](https://discord.gg/DT5jwbtm](https://discord.com/channels/1122861252088172575/1122883317809823814/1152463259165794394)https://discord.com/channels/1122861252088172575/1122883317809823814/1152463259165794394) Discord for further review and advisement.
