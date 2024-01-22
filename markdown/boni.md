## Notes

Original version by:  
https://pistachoduck.itch.io/boniboni (tested with Boni_Linux64.zip)

Boni the skeleton is traveling across the Mexican "Dia de Muertos", however, he needs to go across the spooky Iztepetl Cemetery. Help him get his skeletal body to the other side!


## Controls

| Button | Action               |
| ------ | -------------------- |
| DPAD   | Directional movement |
| B      | Jump                 |
| A/Y    | Shoot                |


## Compile

```shell
wget https://downloads.tuxfamily.org/godotengine/3.3.4/godot-3.3.4-stable.tar.xz  
tar xf godot-3.3.4-stable.tar.xz  
cd godot-3.3.4-stable/platform  
git clone https://github.com/Cebion/frt.git  
cd ../  
scons platform=frt tools=no target=release use_llvm=yes module_webm_enabled=no -j12  
strip bin/godot.frt.opt.llvm
```

