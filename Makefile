all: driver

driver: RASM4.o linklist.o linklist2.o findSubstring.o
	ld -o driver RASM4.o linklist/linklist.o linklist/linklist2.o findSubstring/findSubstring.o -lc objfiles/String1.o objfiles/String2.o objfiles/String_length.o objfiles/putch.o objfiles/int64asc.o objfiles/putstring.o objfiles/ascint64.o objfiles/getstring.o 

RASM4.o: RASM4.s
	as -g -o RASM4.o RASM4.s

linklist.o: linklist/linklist.s
	as -g -o linklist/linklist.o linklist/linklist.s

linklist2.o: linklist/linklist2.s
	as -g -o linklist/linklist2.o linklist/linklist2.s

findSubstring.o: findSubstring/findSubstring.s
	as -g -o findSubstring/findSubstring.o findSubstring/findSubstring.s

clean: 
	rm linklist/linklist.o linklist/linklist2.o findSubstring/findSubstring.o RASM4.o driver
