## Notes

Original version by:  https://jontopielski.itch.io/feather-park (Sep 30, 2022 Windows release)

Explore an autumn park and play minigames. Make friends and enter the barn. Game files are already included and ready to go. Thanks to Jon Topielski for permission to distribute the files.

## Controls

| Button | Action |
|--|--| 
|DPAD|Directional movement|
|A|Interact/action|
|B|Back/escape|


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
