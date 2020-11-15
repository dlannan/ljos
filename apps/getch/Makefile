# the compiler: gcc for C program, define as g++ for C++
CC = gcc

# compiler flags:
#  -g    adds debugging information to the executable file
#  -Wall turns on most, but not all, compiler warnings
CFLAGS  = -fPIC -Wall -shared
CFLAGS 	+= -I../../packages/LuaJIT-2.1.0-beta3/src

LFLAGS  = -lm -lc -ldl 

# the build target executable:
TARGET = getch

all: $(TARGET)

$(TARGET): $(TARGET).c
	$(CC) $(CFLAGS) -o $(TARGET).so $(TARGET).c $(LFLAGS)

clean:
	$(RM) $(TARGET)
