## Notes

Your landlord is knocking on your door. You have one coin left to your name. You insert the coin into your slot machine ... and ... JACKPOT! Luck be a Landlord, tonight! Luck be a Landlord is a roguelike deck-builder about using a slot machine to earn rent money and defeat capitalism. This game does not contain any real-world currency gambling or microtransactions.

You'll need to purchase the game from https://store.steampowered.com/app/1404850/Luck_be_a_Landlord. You'll need a specific release, which you can obtain using a tool like DepotDownloader (https://github.com/SteamRE/DepotDownloader). There are also GUIs for DepotDownloader, like https://depotdownloader.00pium.net. The command may vary depending on your system, but the `-app`, `-depot`, and `manifest` digits must match those below:

`./DepotDownloader -app 1404850 -depot 1404853 -manifest 5385995170406685945 -username <STEAM_USERNAME> -password <STEAM_PASSWORD>`

Once you've grabbed this, locate the *Luck be a Landlord.pck* file and place this in the port's *gamedata* folder.

## Controls

| Button | Action |
|--|--| 
|D-PAD|Directional navigation|

A|Confirm/select|
B|Deny/cancel|
X|Inspect|
Y|Spin|
SELECT|Options|
START|Inventory|
L1|Use green|
L2|Skip|
R1|Use grey|
R2|Fast-forward|
L3|Enable/disable item|
L/R STICK|Scroll up/down|


## Compile

```shell
wget https://downloads.tuxfamily.org/godotengine/3.5.2/godot-3.5.2-stable.tar.xz  
tar xf godot-3.5.2-stable.tar.xz  
cd godot-3.5.2-stable/platform  
git clone https://github.com/Cebion/frt.git  
cd ../  
scons platform=frt tools=no target=release use_llvm=yes module_webm_enabled=no -j12  
strip bin/godot.frt.opt.llvm
```
