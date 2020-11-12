#include <stdio.h>
#include <string.h>

struct MySound {
   unsigned char* data;
   unsigned int length;
   unsigned int pos;
};

void audiocallback(void *userdata, unsigned char *stream, int len)
{
  struct MySound *sound = userdata;
  printf("playing len=%d pos=%d\n", sound->length, sound->pos);
  int tocopy = (sound->length - sound->pos > len ? len : sound->length - sound->pos);
  memcpy(stream, sound->data + sound->pos, tocopy);
  sound->pos = sound->pos + tocopy;
}
