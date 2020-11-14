# the compiler: gcc for C program, define as g++ for C++
CC = gcc

# compiler flags:
CFLAGS  = -O2 -fomit-frame-pointer -Wall -static 
CFLAGS 	+= -I../../packages/LuaJIT-2.1.0-beta3/src

LFLAGS  = -L. -l:libluajit.a -lm -lc -ldl 
LOBJS 	= 

# the build target executable:
TARGET = init

all: $(TARGET)

$(TARGET): $(TARGET).c
	$(CC) $(CFLAGS) -o $(TARGET) $(TARGET).c $(LFLAGS)

clean:
	$(RM) $(TARGET)