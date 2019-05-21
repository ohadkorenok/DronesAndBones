
all: ass3

ass3: ass3.o drone.o
	gcc -m32 -Wall ass3.o drone.o -o ass3 -g

ass3.o: ass3.s
	nasm -f elf ass3.s -o ass3.o -g

drone.o: drone.s
	nasm -f elf drone.s -o drone.o -g

.PHONY: clean

clean: 
	rm -f *.o ass3 *.o drone
