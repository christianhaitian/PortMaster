## Notes

Thanks to the [Cataclysm DDA Team](https://github.com/CleverRaven/Cataclysm-DDA) for creating such an awesome game and making it available for free.

## Controls

| Button | Action |
|--|--| 
|Select|Inventory|
|Start|Horizotal menu navigation, attack|
|A|Enter|
|B|Escape / Back|
|X|Pickup Item|
|Y|Wait|
|Select + A |preview, confirm route / wield item|
|Select + B|1 # toggle safe mode|
|Select + X|Grab Item|
|Select + Y|Sleep|
|L1|Throw Item|
|L2|Smash|
|L3|Look Around|
|R1|Fire Item|
|R2|Reload Item|
|R3|Map|
|Select + L1|Drop Item |
|Select + R1|Toggle attack mode of wielded item|
|Select + L2|View / Activate bionics|
|Select + R2|View / Activate Mutations |
|Right Analogue Up|Zoom In|
|Right Analogue Down|Zoom Out|
|Right Analogue Left|Descent Stairs|
|Right Analogue Right|Ascend Stairs|


## Compile

```shell
git clone https://github.com/CleverRaven/Cataclysm-DDA.git
cd Cataclysm-DDA
make TILES=1 SOUND=1 RELEASE=1 LOCALIZE=1 LANGUAGES=all
```
