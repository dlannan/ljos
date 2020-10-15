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

## Prerequisities
If you want to build your own linux kernel there are some prerequisities you need to have setup. 

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


## Future
The aim is to build this into a nice little toolkit for various use cases.
I hope to build an ARM version that will be used on IoT and mobile.
