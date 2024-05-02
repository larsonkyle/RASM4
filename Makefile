all: RASM4

RASM4: RASM4.o option1.o option2.o option3.o option4.o option5.o option6.o option7.o
	ld -o RASM4 -lc objfiles/*.o src/RASM4.o src/MenuOptions/*.o

RASM4.o: src/RASM4.s 
	as -g -o src/RASM4.o src/RASM4.s

option1.o: src/MenuOptions/option1.s
	as -g -o src/MenuOptions/option1.o src/MenuOptions/option1.s

option2.o: src/MenuOptions/option2.s
	as -g -o src/MenuOptions/option2.o src/MenuOptions/option2.s

option3.o: src/MenuOptions/option3.s
	as -g -o src/MenuOptions/option3.o src/MenuOptions/option3.s

option4.o: src/MenuOptions/option4.s
	as -g -o src/MenuOptions/option4.o src/MenuOptions/option4.s

option5.o: src/MenuOptions/option5.s
	as -g -o src/MenuOptions/option5.o src/MenuOptions/option5.s

option6.o: src/MenuOptions/option6.s
	as -g -o src/MenuOptions/option6.o src/MenuOptions/option6.s

option7.o: src/MenuOptions/option7.s
	as -g -o src/MenuOptions/option7.o src/MenuOptions/option7.s

clean: 
	rm RASM4 src/*.o src/MenuOptions/*.o output.txt	
