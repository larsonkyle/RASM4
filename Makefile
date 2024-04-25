all: driver

driver: RASM4.o option1.o option2.o option3.o option4.o option5.o option6.o option7.o
	ld -o driver RASM4.o linklist/option1.o linklist/option2.o linklist/option3.o linklist/option4.o linklist/option5.o linklist/option6.o linklist/option7.o -lc objfiles/String1.o objfiles/String2.o objfiles/String_length.o objfiles/putch.o objfiles/int64asc.o objfiles/putstring.o objfiles/ascint64.o objfiles/getstring.o 

RASM4.o: RASM4.s
	as -g -o RASM4.o RASM4.s

option1.o: linklist/option1.s
	as -g -o linklist/option1.o linklist/option1.s

option2.o: linklist/option2.s
	as -g -o linklist/option2.o linklist/option2.s

option3.o: linklist/option3.s
	as -g -o linklist/option3.o linklist/option3.s

option4.o: linklist/option4.s
	as -g -o linklist/option4.o linklist/option4.s

option5.o: linklist/option5.s
	as -g -o linklist/option5.o linklist/option5.s

option6.o: linklist/option6.s
	as -g -o linklist/option6.o linklist/option6.s

option7.o: linklist/option7.s
	as -g -o linklist/option7.o linklist/option7.s

clean: 
	rm driver RASM4.o linklist/option1.o linklist/option2.o linklist/option3.o linklist/option4.o linklist/option5.o linklist/option6.o linklist/option7.o
