
all: ass3

ass3: ass3.o
	gcc -m32 -Wall ass3.o -o ass3 -g

ass3.o: ass3.s
	nasm -f elf ass3.s -o ass3.o -g

.PHONY: clean

clean: 
	rm -f *.o ass3
