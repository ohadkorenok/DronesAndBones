
all: ass3

ass3: ass3.o drone.o target.o scheduler.o printer.o
	gcc -m32 -Wall ass3.o drone.o target.o scheduler.o printer.o -o ass3 -g

ass3.o: ass3.s
	nasm -f elf ass3.s -o ass3.o -g

drone.o: drone.s
	nasm -f elf drone.s -o drone.o -g

target.o: target.s
	nasm -f elf target.s -o target.o -g

scheduler.o: scheduler.s
	nasm -f elf scheduler.s -o scheduler.o -g

printer.o: printer.s
	nasm -f elf printer.s -o printer.o -g

.PHONY: clean

clean: 
	rm -f *.o ass3 *.o drone
