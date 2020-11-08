#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <linux/fb.h>
#include <sys/mman.h>
#include <sys/ioctl.h>
#include "cairo.h"

typedef struct _cairo_linuxfb_device {
	int fb_fd;
	char *fb_data;
	long fb_screensize;
	struct fb_var_screeninfo fb_vinfo;
	struct fb_fix_screeninfo fb_finfo;
} cairo_linuxfb_device_t;

static
void cairo_linuxfb_surface_destroy(void *device)
{
	cairo_linuxfb_device_t *dev = (cairo_linuxfb_device_t *)device;

	if (dev == NULL) {
		return;
	}
	munmap(dev->fb_data, dev->fb_screensize);
	close(dev->fb_fd);
	free(dev);
}

cairo_surface_t *cairo_linuxfb_surface_create(const char *fb_name)
{
	cairo_linuxfb_device_t *device;
	cairo_surface_t *surface;

	if (fb_name == NULL) {
		fb_name = "/dev/fb0";
	}

	device = malloc(sizeof(*device));

	// Open the file for reading and writing
	device->fb_fd = open(fb_name, O_RDWR);
	if (device->fb_fd == -1) {
		perror("Error: cannot open framebuffer device");
		exit(1);
	}

	// Get variable screen information
	if (ioctl(device->fb_fd, FBIOGET_VSCREENINFO, &device->fb_vinfo) == -1) {
		perror("Error reading variable information");
		exit(3);
	}

	// Figure out the size of the screen in bytes
	device->fb_screensize = device->fb_vinfo.xres * device->fb_vinfo.yres
	                        * device->fb_vinfo.bits_per_pixel / 8;

	// Map the device to memory
	device->fb_data = (char *)mmap(0, device->fb_screensize,
	                               PROT_READ | PROT_WRITE, MAP_SHARED,
	                               device->fb_fd, 0);
	if ((int)device->fb_data == -1) {
		perror("Error: failed to map framebuffer device to memory");
		exit(4);
	}

	// Get fixed screen information
	if (ioctl(device->fb_fd, FBIOGET_FSCREENINFO, &device->fb_finfo) == -1) {
		perror("Error reading fixed information");
		exit(2);
	}

	surface = cairo_image_surface_create_for_data(device->fb_data,
	            CAIRO_FORMAT_ARGB32,
	            device->fb_vinfo.xres,
	            device->fb_vinfo.yres,
	            cairo_format_stride_for_width(CAIRO_FORMAT_ARGB32, device->fb_vinfo.xres));
	            cairo_surface_set_user_data(surface, NULL, device,
                &cairo_linuxfb_surface_destroy);

	return surface;
}

int main (int argc, char *argv[])
{
	cairo_surface_t *surface;
	cairo_t *cr;

	surface = cairo_linuxfb_surface_create(NULL);
	cr = cairo_create(surface);

	cairo_select_font_face(cr, "serif", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD);
	cairo_set_font_size(cr, 32.0);
	cairo_set_source_rgb(cr, 0.0, 0.0, 1.0);
	cairo_move_to(cr, 100.0, 100.0);
	cairo_show_text(cr, "Hello, CairoGraphics!");

	cairo_destroy(cr);
	cairo_surface_destroy(surface);

	return 0;
}
