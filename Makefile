
# Build paths for copying files
BUILD_PATH  = 	 ./barebones
LUAJIT_PATH = 	 ./luajit
LUASTATIC_PATH = ./luastatic
LINUX_SRC = 	 ./linux-src

# USB Device settings
#   ************* WARNING: use lsblk to check what you are writing to!! *****************
USB_DEVICE = /dev/sdc

# Linux kernel source
KERNEL_VERSION=4.9.239
KERNEL_DIRECTORY=$(LINUX_SRC)/linux-$(KERNEL_VERSION)
KERNEL_ARCHIVE=$(KERNEL_DIRECTORY).tar.xz
KERNEL_URL=https://cdn.kernel.org/pub/linux/kernel/v4.x/$(KERNEL_ARCHIVE)

all: initramfs

# Kernel build targets
vmlinuz: $(KERNEL_DIRECTORY)
	cd $(KERNEL_DIRECTORY) && make defconfig && make -j`nproc`
	cp $(KERNEL_DIRECTORY)/arch/x86_64/boot/bzImage $(LINUX_SRC)/vmlinuz

$(KERNEL_DIRECTORY):
	wget $(KERNEL_URL)
	tar xf $(KERNEL_ARCHIVE)

# Initramfs build targets
initramfs: initfs initfs/init 
	cd $(BUILD_PATH)/initfs/ && find . | cpio -o --format=newc > ../initramfs

# Prepare folders for initramfs
initfs/init: initfs
	cp luajit/src/luajit $(BUILD_PATH)/bootfiles/init

# Prepare folders for initramfs - force a folder delete, or it ends up messy.
initfs:
	mkdir -p $(BUILD_PATH)/initfs/bin $(BUILD_PATH)/initfs/proc $(BUILD_PATH)/initfs/dev $(BUILD_PATH)/initfs/sys
	rm -rf $(BUILD_PATH)/initfs/*
	cp -r $(BUILD_PATH)/lua/* $(BUILD_PATH)/initfs/
	cp -r $(BUILD_PATH)/bootfiles/* $(BUILD_PATH)/initfs/

# Build the iso
bb.iso: initramfs
	mkdir -p $(BUILD_PATH)/iso/boot/grub
	cp $(BUILD_PATH)/grub.cfg $(BUILD_PATH)/iso/boot/grub/
	cp $(LINUX_SRC)/vmlinuz $(BUILD_PATH)/initramfs $(BUILD_PATH)/iso/boot/
	grub-mkrescue -o $(BUILD_PATH)/bb.iso $(BUILD_PATH)/iso

# Utility targets
runvm: vmlinuz initramfs
	qemu-system-x86_64 -m 2048 -kernel $(LINUX_PATH)/vmlinuz -initrd $(BUILD_PATH)/initramfs -append console=ttyS0 -nographic

runiso: bb.iso
	qemu-system-x86_64 -m 2048 -cdrom $(BUILD_PATH)/bb.iso -boot d

usbiso: bb.iso
	dd if=$(BUILD_PATH)/bb.iso of=$(USB_DEVICE) status="progress"

clean:
	rm -rf vmlinuz initramfs $(KERNEL_DIRECTORY) $(KERNEL_ARCHIVE) \
	rm -rf $(BUILD_PATH)/initfs/*
	iso/boot/vmlinuz \
	iso/boot/initramfs $(BUILD_PATH)bb.iso