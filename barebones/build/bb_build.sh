#gcc -static -o init init.c
cp ../../luajit/src/luajit ./initfs/init
#cp ../../saldo/luastatic/hello ./init
#echo ./init | cpio -o --format=newc > initramfs
cp -r ./lua/* ./initfs/
cd initfs/ && find . | cpio -o --format=newc > ../initramfs
cd ..

# Build the iso
mkdir -p ../iso/boot/grub
cp grub.cfg ../iso/boot/grub/
cp vmlinuz initramfs ../iso/boot/
grub-mkrescue -o bb.iso ../iso
