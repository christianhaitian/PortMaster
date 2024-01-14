## Notes

Your landlord is knocking on your door. You have one coin left to your name. You insert the coin into your slot machine ... and ... JACKPOT! Luck be a Landlord, tonight! Luck be a Landlord is a roguelike deck-builder about using a slot machine to earn rent money and defeat capitalism. This game does not contain any real-world currency gambling or microtransactions.

You'll need to purchase the game from https://trampolinetales.itch.io/luck-be-a-landlord, then download the Linux version. Extract this .zip file and place the *Luck be a Landlord.pck* file in the gamedata folder. This works with the Version 1.2.5, Linux release.

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
