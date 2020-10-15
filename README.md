# ljos

Firstly, but thanks to Kenneth Wilke whos excellent blogs on making a bootable linux lead me to make this setup.
> https://suchprogramming.com/barebones-linux-system/

> https://suchprogramming.com/barebones-linux-iso/

> https://github.com/KennethWilke/my-barebones-linux

Thanks very much Kenneth, I appreciate the time and effort you went to in providing such a good guide for this process.

<b>What is ljos</b>

A 4.9.x (latest) x86_64 linux kernel with a grub2 efi boot that launches luajit 2.0.5

Once booted, the luajit runtime is started and you have a simple luajit commandline interface.

An iso is included in the repo - bb.iso

![ljos boot](/screenshots/2020-10-15_14-44.png "ljos boot in qemu")

## Build Problems
Here is a list of common problems I have come across when building (on linux and windows).
1. When building luajit, make sure the init executable has execution permissions on it in linux. 

Filepath: ```/barebones/build/initfs/init```

Fix execution permissions: ```chmod +x /barebones/build/initfs/init```

2. Check the execution permissions for the build and run shell scripts. 

Files: ```/barebones/build/bb_build.sh /barebones/build/bb_console.sh /barebones/build/bb_iso.sh /barebones/build/bb_run.sh ```

Fix execution permissions: ```chmod +x /barebones/build/*.sh```

3. Do not use a normal Luajit build - this will not work. It must be statically _built_. This is why luajit is included.
4. Be careful with grub.cfg. Some settings can stop the linux boot from working. For example setting gfxpayload=1280x1024 will result in a black screen.
5. bb_run.sh should not be used. This is for dev purposes. 
If you have problems. Raise an issue. 

## Pre-requisities
If you want to build your own linux kernel there are some dependencies you need to have setup. 

This page is not intended for learning how to build a kernel, please visit the linux build documents for fine detail on this. 

You will need (on a linux or osx platform, and possibly on windows):

- gcc build tools
- kernel build headers
- make and autoconf tools
- various miscellaneous tools.
- alot of patience ....

https://www.kernel.org/doc/html/latest/process/changes.html

If you are having problems, please post an issue, and I'll try to help.

## Building
Dont use the Makefile, yet. This is from Kenneths repo and its going to be 'remodelled' :)

Follow these steps:

**Note:** *Skip to step 3 if you dont want to build the linux kernel.  The provided linux kernel 4.9.239 can be used.*

1. Download the kernel as described in Kenneths blog page. You can use _any_ linux kernel you want. 
Example: 
```
cd barebones/build
wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.15.tar.xz
tar xf linux-4.15.tar.xz
```
2. Build and copy the linux default kernel
```
cd linux && make defconfig && make -j`nproc`
cp linux/arch/x86_64/boot/bzImage vmlinuz
```
3. Build luajit
```
cd luajit
make clean
make
```
4. Build initramfs with luajit as init and other included lua files.
You can add other lua files if you want to try them out after booting. 
```
./bb_build.sh
```
An iso file will be created called bb.iso, that you can boot in a virtual machine or even from a USB.
5. Run as a virtual machine.
```
./bb_iso.sh
```

## Running Scripts
Once booted you should be greeted with the usual luajit command prompt.
To run the sample boot script type:
```
dofile("boot.lua")
```
You should see:

![ljos boot](/screenshots/2020-10-15_14-44.png "ljos boot in qemu")

## Luastatic
Why is luastatic in here?
One of the tests I have been running is packaging luajit + various lua files into a single file used at init. 
The benefits of this are: 
- You can hide away complex boot behaviour that doesnt really need to be edited (setup file systems etc)
- External libs can be brought into to be statically built more easily (depending on complexity and issues with building). 
- No need for shared libraries - this is good and bad. Bigger code, but no dependency madness.

There will be some examples added to show how this works. Hello.c already works fine, if you are interested. 
I expect that this will be used for some of the complex behavior for IoT and mobile, so its related to the futures below.

## Future
The aim is to build this into a nice little toolkit for various use cases.
I hope to build an ARM version that will be used on IoT and mobile.
