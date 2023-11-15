## Notes

Thanks to [Gerhard Stein](https://github.com/gerstrong/Commander-Genius) and others related for the development of this port that makes this possible. Thanks to [Christian Haitian](https://github.com/christianhaitian) for his work on [PortMaster](https://github.com/christianhaitian/PortMaster), the previous versions of this port, and for passing the torch to a newbie.

## Controls

| Button | Action |
|--|--|
| Start | Exit to main menu |
| Select | Display status |
| D-pad | Move character |
| A | Jump |
| B | Shoot blaster |
| Y | Toggle pogo stick on/off |

Note: Default controls are shown, however, port supports remapping of the controls to your preference. Needs to be done in-game but, once complete, the custom control mappings apply globally.

## Compile

```shell
# binary will be located 'CGeniusBuild/src/CGeniusExe' when complete
git clone https://gitlab.com/Dringgstein/Commander-Genius.git
mkdir CGeniusBuild && cd CGeniusBuild
cmake ../Commander-Genius/
make
```