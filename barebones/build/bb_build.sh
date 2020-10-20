#Clear any previous build
rm -rf ./initfs/*

#gcc -static -o init init.c
cp ../../luajit/src/luajit ./initfs/init
#cp ../libc/init ./initfs/init
#cp ../libc/libc-2.28.so ./initfs/libc-2.28.so

#cp ../../saldo/luastatic/hello ./init
#echo ./init | cpio -o --format=newc > initramfs
cp -r ./lua/* ./initfs/
cp -r ./bootfiles/* ./initfs/
cd initfs/ && find . | cpio -o --format=newc > ../initramfs
cd ..

# Build the iso
mkdir -p ../iso/boot/grub
cp grub.cfg ../iso/boot/grub/
cp vmlinuz initramfs ../iso/boot/
grub-mkrescue -o bb.iso ../iso
