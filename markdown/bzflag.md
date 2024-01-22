
## Notes
<br/>

Thanks to [Joshua Bodine](https://github.com/macsforme/bzflag-embedded) for the embedded version of this game.
Aswell as the BZFlag Team [Github] (https://github.com/BZFlag-Dev/bzflag) 

Source: https://github.com/macsforme/bzflag-embedded
 
<br/>

## Controls
<br/>

| Button | Action |
|--|--|
| Start | Accept / Enter |
| Select | Back |
| A | Fire Shot |
| B | Jump |
| X | Drop Flag |
| Y | Start New Game |
| L1 | Radar Zoom |
| L2 | Radar Small |
| L3 | Binocular |
| R1 | Radar Zoom |
| R2 | Radar Medium |
| L3 | Toggle Score |


## Compile
<br/>

```shell 
git clone https://github.com/macsforme/glues.git
cd glues/
./autogen.sh
./configure
make -j12
make install

git clone https://github.com/macsforme/bzflag-embedded.git
cd bzflag-embedded/
./autogen.sh
./configure --with-SDL2 --with-gles
make
```
