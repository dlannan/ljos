# ljos
---
## Warning: Everything is about to change. 
Will probably migrate this to mitree repo before it changes too much. 

LJOS will become a fully fledged FBP OS over the next few months. The initial investigations using this repo have gone very well (mostly). Thanks to the assistance of @technomancy for thoughful discussions and ideas. 

The overall structure of LJOS will not be like a traditional linux kernel OS. There will be no default console terminal (framebuffer render only). There will be a base FBP master module (router) that will be call Zeus, and it will manage and allow debugging of applicaton and service modules. 

I expect some of this to be working over the next few weeks. I will add a link here. There may not be much further work on this repo. You are welcome to add PR's and suggestions, but it will not be my main focus from here on. 

Thanks again to the people who make the awesome packages that allowed this reasearch into this little system.

---
This doesnt exist without Lua and Luajit. Lua was introduced to me at Pandemic Studios in 2001 by a brilliant coder also named David. Thanks, it really struck a cord with me because of its simplicity. And then Mike Pauls Luajit made something that was annoying (binding with Lua) into something beautiful - ffi. FFI and luajit are an impressive combination. So thankyou to these people, I really appreciate the work they have done.

> https://www.lua.org/

> https://luajit.org/

Firstly, big thanks to Kenneth Wilke whos excellent blogs on making a bootable linux lead me to make this setup.
> https://suchprogramming.com/barebones-linux-system/

> https://suchprogramming.com/barebones-linux-iso/

> https://github.com/KennethWilke/my-barebones-linux

Thanks very much Kenneth, I appreciate the time and effort you went to in providing such a good guide for this process.

<b>What is ljos</b>

A 4.9.x (latest) x86_64 linux kernel with a grub2 efi boot that launches luajit 2.0.5

Once booted, the luajit runtime is started and you have a simple luajit commandline interface.

An iso is included in the repo - bb.iso

![ljos boot](/screenshots/2020-10-23_23-52.png "ljos boot in qemu")

![ljos demo](/screenshots/2020-11-11_15-33.png "ljos running FBGraphics flags demo")

## Additional Thanks
I am slowly adding packages to ljos so that more and more capabilities are available. 

Thanks to Justin Cormack for: https://github.com/justincormack/ljsyscall

This is an amazing large amount of work. It is highly appreciated. I will be looking to help on this as this progresses.

Thanks to Desvelao for a fantastic commandline toolkit: https://github.com/Desvelao/lummander

Thanks to grz0zrg for a brilliant little fb gfx library: https://github.com/grz0zrg/fbg

Thanks to Antirez for an amazing little editor kilo: https://github.com/antirez/kilo

## Build Problems
Here is a list of common problems I have come across when building (on linux and windows).
1. When building luajit, make sure the init executable has execution permissions on it in linux. 

Filepath: ```/barebones/initfs/init```

Fix execution permissions: ```chmod +x /barebones/initfs/init```

2. Do not use a normal Luajit build - this will not work. It must be statically _built_. This is why luajit is included.
3. Be careful with grub.cfg. Some settings can stop the linux boot from working. For example setting gfxpayload=1280x1024 will result in a black screen.
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
Thanks to Kenneth Wilke's Makefile, I have reworked it to suit the building of this system.

To build a full kernel image (one x86_64 default linux kernel is included), from the top level directory, type:
```
make vmlinux
```

To build only luajit - this is called at startup of the OS:
```
make luajit
```

To create the initramfs (the bootable portion of the system) type:
```
make
```

To build an iso for use in qemu, in a vm or as a bare metal bootable:
```
make bb.iso
```

To test the iso using quemu:
```
make runiso
```

To test the vmlinuz kernel and the initramfs packages using quemu:
```
make runvm
```

## Usage
A number of commands have been added to the command line. The Luajit command line is currently not available, all commands are parsed. However, thanks to the awesome lummander package, it is trivial to add more commands to the system. 

A generic pcall or dofile can be added as needed. This method has been chosen because:
- It limits the need for checking calls to dangerous methods like os.execute.
- It allows the implementation of bash like commands more easily.
- All execution is contained within the VM - eventually _all_ execution will be within single instances like this (even larger processes).

To see the available commands (again, thanks to lummander) type:
```
help
```

Example use below:

![ljos help](/screenshots/2020-10-24_11-30.png "ljos help")

As shown above, individual help for each command can be used as well. 

## Booting 
You should see:

![ljos boot](/screenshots/2020-10-23_23-51.png "ljos grub bootmenu in qemu")

followed by:

![ljos boot](/screenshots/2020-10-23_23-52.png "ljos in qemu")

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

## License
All source code that is not covered by a license (from other packages) is MIT license. The linux kernel is GPL license, please refer to the license within the linux repository for more information.

Please refer to included source package licenses for their licensing agreement.

The MIT License (MIT)
Copyright © 2020 <copyright holders>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

