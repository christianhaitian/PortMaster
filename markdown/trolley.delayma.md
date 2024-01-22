## Notes

Original version by:  
https://albertnez.itch.io/trolley-delayma (linux_v1_0_1.zip release)

Trolley Delayma is a tiny puzzle game where you move around manipulating the tracks to save the victims and delay the inevitable fate forever. A combination of puzzle solving and fast reaction to save everyone, including you! 


## Controls

| Button | Action               |
| ------ | -------------------- |
| DPAD   | Directional movement |
| A/B    | Toggle track         |
| R1     | Fast-forward         |
| SELECT | Pause/option menu    |


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

