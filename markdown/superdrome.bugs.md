## Notes

Original version by:  
https://pistachoduck.itch.io/superdrome-bugs (tested with SuperDromerBugs_Linux64.zip)

One day, Simon Pray -- a pest extinguisher living in Mexico, where for some reason pests are nowhere to be found -- receives a call from a luxurious mansion offering him a job. Something doesn't seem right, but Simon doesn't have time to think about it, he needs the money!. Join S.Pray and help him get rid of the pests!


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

