## Notes

On Displays lower than 640x480 you have to drag around the main menu windows by pressing and holding the A button.

Ingame you can also drag the map via holding the A button.

Thanks to the [Widelands ](https://www.widelands.org/) team for creating this gem and making it available for free!



## Controls

| Button | Action |
|--|--| 
|A|Mouse Left|
|B|Mouse Right (Close Window)|
|X|Slow Mouse|
|Y|Show / Hide Building Spots|
|L1 / R1|Zoom|
|L2 / R2|Fast Forward|
|DPAD|Move Map around|


## Compile

```shell
git clone https://github.com/widelands/widelands.git
cd widelands
mkdir build && cd build
cmake .. -DOPTION_USE_GLBINDING=ON -DUSEXDG=ON
make

```
