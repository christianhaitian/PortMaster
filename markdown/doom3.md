## Notes

This port is based on the work of [Emile Belanger](https://github.com/emileb/d3es-multithread), which is in turn based on the work of [Gabriel Cuvillier](https://github.com/gabrielcuvillier/d3wasm) and [Daniel Gibson](https://github.com/dhewm/dhewm3) for the dhewm3 port. Many thanks!
 
Also thanks to brooksytech for the porting and packaging for portmaster.

## Controls

See the file `doom3/default_controls_doom3.png` in doom3.zip. For some reason the back button binding to open the menu does not work, so use the shortcut `back button + B button` instead.

## Build Instructions

[d3es](https://github.com/emileb/d3es-multithread) for this port was compiled using an aarch64 Ubuntu Focal Docker container running on an amd64 Debian Bookworm host.

If you would like to compile an updated version, here are the steps.

### Clone the source repsitory
Use git to clone the [d3es repository](https://github.com/emileb/d3es-multithread):
```
git clone https://github.com/emileb/d3es-multithread.git
cd d3es-multithread
```

### Install Docker
Follow the steps to [Install Docker Engine on Debian using the apt repository](https://docs.docker.com/engine/install/debian/#install-using-the-repository) 
 
### Docker post-install steps
Follow the steps at [Configure Docker on your Linux host](https://docs.docker.com/engine/install/linux-postinstall/) to manage Docker as a non-root user.
 
### Install multiarch/qemu-user-static
This will enable execution of different multi-architecture containers by QEMU and binfmt_misc:
```
sudo apt install binfmt-support qemu-user-static
```

### aarch64 Ubuntu Focal Docker container
Use multiarch/qemu-user-static to run an aarch64 Ubuntu Focal Docker container. Mount the d3es-multithread directory as a volume to `/data` - assumed to be `$(pwd)`.
```
docker run --rm --privileged multiarch/qemu-user-static:register
docker run -v /usr/bin/qemu-aarch64-static:/usr/bin/qemu-aarch64-static -it --platform linux/arm64 -v $(pwd):/data ubuntu:focal
```

### Compile d3es-multithread
Install the d3es-multithread build dependencies and compile following the instructions at [Compiling](https://github.com/emileb/d3es-multithread#compiling):

```
// Install build dependencies
apt install git cmake build-essential libsdl2-dev libopenal-dev zlib1g-dev libcurl4-openssl-dev

// Create build directory
mkdir build && cd build

// Have a look at supported cmake options
cmake -LH ../neo/

// Create a makefile with cmake - pass arguments for cmake options as desired
cmake ../neo/ -DONATIVE=ON

// Compile - choose how many threads you want it to use
make -j12
```
