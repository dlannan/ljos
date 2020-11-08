


all:
	gcc -shared -fPIC -o libc.so obj/*.o
	gcc -static -rdynamic -o init main.c -I../../luajit/src/ -L../../luajit/src -l:libluajit.a -lm -ldl

clean:
	rm *.o
	rm *.so
