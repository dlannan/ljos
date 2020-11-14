-- mostly inspired by:
-- http://www.gnurou.org/book/export/html/35

local sdl = require 'sdl2'
local ffi = require 'ffi'

ffi.cdef[[
void *malloc(size_t size);
void free(void *ptr);

struct MySound {
   Uint8* data;
   Uint32 length;
   Uint32 pos;
};
]]

local function mixaudio(userdata, stream, len)
   local sound = ffi.cast('struct MySound*', userdata)
   print(string.format("playing len=%d pos=%d\n", sound.length, sound.pos))
   local tocopy = sound.length - sound.pos > len and len or sound.length - sound.pos
   ffi.copy(stream, sound.data + sound.pos, tocopy)
   sound.pos = sound.pos + tocopy
end

if sdl.init(sdl.INIT_AUDIO) == -1 then
   error('could not initialize SDL')
end

for i=0,sdl.getNumAudioDrivers()-1 do
   print('driver:', ffi.string(sdl.getAudioDriver(i)))
end

local desired = ffi.new('SDL_AudioSpec')
local obtained = ffi.new('SDL_AudioSpec')
local soundfile = ffi.new('SDL_AudioSpec')

local cb = ffi.load('audiocallback')
ffi.cdef[[
void audiocallback(void *userdata, unsigned char *stream, int len);
]]

local sound = ffi.new('struct MySound')

desired.freq = 44100
desired.format = sdl.AUDIO_U16
desired.channels = 2
desired.samples = 512
desired.callback = cb.audiocallback --mixaudio
desired.userdata = sound

if sdl.openAudio(desired, obtained) ~= 0 then
   error(string.format('could not open audio device: %s', ffi.string(sdl.getError())))
end

print(string.format('obtained parameters: format=%s, channels=%s freq=%s size=%s bytes',
                    bit.band(obtained.format, 0xff), obtained.channels, obtained.freq, obtained.samples))

do
   local sounddata = ffi.new('Uint8*[1]')
   local soundlength = ffi.new('Uint32[1]')
   if sdl.loadWAV("arugh.wav", soundfile, sounddata, soundlength) == 0 then
      error(string.format('could not read audio file: %s', ffi.string(sdl.getError())))
   end
   sound.data = sounddata[0]
   sound.length = soundlength[0]
end

local cvt = ffi.new('SDL_AudioCVT')
if sdl.buildAudioCVT(cvt, soundfile.format, soundfile.channels, soundfile.freq,
                     obtained.format, obtained.channels, obtained.freq) < 0 then
   error('could not build audio converter')
end

cvt.buf = ffi.C.malloc(sound.length * cvt.len_mult)
cvt.len = sound.length
ffi.copy(cvt.buf, sound.data, sound.length)

if sdl.convertAudio(cvt) ~= 0 then
   error(string.format('problem during audio conversion: %s', sdl.getError()))
end

sdl.freeWAV(sound.data)
sound.data = ffi.C.malloc(cvt.len_cvt)
ffi.copy(sound.data, cvt.buf, cvt.len_cvt)
ffi.C.free(cvt.buf)

sound.length = cvt.len_cvt
print(string.format('converted audio size: %s bytes', sound.length))

sdl.pauseAudio(0)

jit.off()

while sound.pos < sound.length do
end

jit.on()

sdl.pauseAudio(1)

sdl.closeAudio()

sdl.quit()
