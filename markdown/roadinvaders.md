Road Invaders (https://blasin.itch.io/road-invaders)
===========

Original version by:  
https://blasin.itch.io/road-invaders

Description 
===========

An action game that's part vertical-scrolling racer, part match-2 game. Move your car and punch cubes, matching cubes to shift gear on your way to achieving the highest score! Game files are already included and ready to go. Thanks to Blasin for permission to distribute the files.

To compile:
===========

wget https://github.com/love2d/love/releases/download/11.4/love-11.4-linux-src.tar.gz  
tar xf love-11.4-linux-src.tar.gz  
cd love-11.4/  
./configure  
LOVE_GRAPHICS_USE_OPENGLES=1 make -j12  
strip src/.libs/liblove-11.4.so  
scp src/.libs/liblove-11.4.so device/libs  
scp src/.libs/love device/

Controls:
===========

LEFT/RIGHT  = Horizontal movement  
START       = Pause game  
SELECT      = Exit game

