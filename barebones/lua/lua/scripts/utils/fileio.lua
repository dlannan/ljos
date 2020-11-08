--
-- Created by David Lannan
-- User: dlannan
-- Date: 23/02/13
-- Time: 9:04 PM
--

----------------------------------------------------------------

ffi.cdef [[
typedef struct __IO_FILE FILE;
FILE *stdout;

int printf(const char *fmt, ...);
void setbuf(FILE *stream, char *buf);
void *malloc(size_t size);
void *memset(void *s, int c, size_t n);

FILE *fopen(const char *filename, const char *mode);
int fclose(FILE *stream);
int fread(void *ptr, int size, int nmemb, FILE *stream);
int fwrite(const void *ptr, int size, int nmemb, FILE *stream);
]]

----------------------------------------------------------------
local stdio = ffi.C
local fileio = {}

----------------------------------------------------------------

function fileio:getffsize(fftype)
    local elementsize = 4 -- this size will fit mst types: float, int, unsigned int etc
    if fftype == "unsigned short" or fftype == "short" then elementsize = 2 end
    if fftype == "unsigned shar" or fftype == "char" then elementsize = 1 end
    return elementsize
end

----------------------------------------------------------------
-- Note: bdata must be a ffi cdata object

function fileio:savedata( binfilename, bsize, bdata)
    local bfile = stdio.fopen(binfilename, "wb")
    if bfile ~= nil then
        stdio.fwrite( bdata, 1, bsize, bfile )
        stdio.fclose(bfile)
        return 1
    else
        return nil
    end
end

----------------------------------------------------------------
-- Note: bdata returned is an ffi object!!
--          Make sure you malloc enough space!!

function fileio:readdata( binfilename, bsize, bdata)
    local bfile = stdio.fopen(binfilename, "rb")
    if bfile ~= nil then
        stdio.fread( bdata, 1, bsize, bfile )
        stdio.fclose(bfile)
        return 1
    else
        return nil
    end
end

----------------------------------------------------------------

function fileio:exists(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f); return true else return false end
end

----------------------------------------------------------------

return fileio

----------------------------------------------------------------

----------------------------------------------------------------