    .global insert_into_kbd
    .global insert_into_file
    .global insert_into
    .global append_line_feed
    .global buf_clear

.equ        addStrBufSize,    100

    .data

strPrompt:     .asciz      "Enter String: "
addStrBuf:     .skip       100

    .text

/*
insert_into_kbd - get string input from the user and push it to the list

must have access to:
addStrBuf
addStrBufSize
headPtr
tailPtr

Only AAPCS registers x19 - x29 are preserved
*/

insert_into_kbd:
    str     LR,[SP,#-16]!       // push LR to the stack
    
    str     X19,[SP, #-16]! 	// preserved required AAPCS registers
    str     X20,[SP, #-16]! 	// preserved required AAPCS registers
    str     X21,[SP, #-16]! 	// preserved required AAPCS registers
    str     X22,[SP, #-16]! 	// preserved required AAPCS registers
    str     X23,[SP, #-16]! 	// preserved required AAPCS registers
    str     X24,[SP, #-16]! 	// preserved required AAPCS registers
    str     X25,[SP, #-16]! 	// preserved required AAPCS registers
    str     X26,[SP, #-16]!	    // preserved required AAPCS registers
    str     X27,[SP, #-16]! 	// preserved required AAPCS registers
    str     X28,[SP, #-16]! 	// preserved required AAPCS registers
    str     X29,[SP, #-16]! 	// preserved required AAPCS registers

    ldr     x0,=addStrBuf      		// load string buffer into x0
    ldr     x1,=addStrBufSize  		// load addStrBufSize into x1
    bl      buf_clear          		// clear the string buffer

    ldr     x0,=strPrompt   	// load user prompt
    bl      putstring      	// output user prompt

    ldr     x0,=addStrBuf     	// load buffer into x0
    ldr     x1,=addStrBufSize 	// load the buffer size into x1
    bl      getstring        	// get string from user and put in buffer

    ldr     x0,=addStrBuf   	// load buffer into x0
    bl      append_line_feed	// append a line feed to it

    bl      insert_into     	// insert the string into the list

    ldr     X29,[SP],#16  	// preserved required AAPCS registers
    ldr     X28,[SP],#16   	// preserved required AAPCS registers
    ldr     X27,[SP],#16   	// preserved required AAPCS registers
    ldr     X26,[SP],#16   	// preserved required AAPCS registers
    ldr     X25,[SP],#16  	// preserved required AAPCS registers
    ldr     X24,[SP],#16  	// preserved required AAPCS registers
    ldr     X23,[SP],#16  	// preserved required AAPCS registers
    ldr     X22,[SP],#16  	// preserved required AAPCS registers
    ldr     X21,[SP],#16  	// preserved required AAPCS registers
    ldr     X20,[SP],#16  	// preserved required AAPCS registers
    ldr     X19,[SP],#16  	// preserved required AAPCS registers

    ldr     LR,[SP],#16   	// pop LR off the stack
    ret                    	// return to caller
	
/*
insert_into_file - read all lines from file and insert them individual into the linked list

must have access to:
FD
addStrBuf
addStrBufSize
headPtr
tailPtr

Only AAPCS registers x19 - x29 are preserved
*/

insert_into_file:
    str     LR,[SP,#-16]!   // push LR to the stack

    str     X19,[SP, #-16]! // preserved required AAPCS registers
    str     X20,[SP, #-16]! // preserved required AAPCS registers
    str     X21,[SP, #-16]! // preserved required AAPCS registers
    str     X22,[SP, #-16]! // preserved required AAPCS registers
    str     X23,[SP, #-16]! // preserved required AAPCS registers
    str     X24,[SP, #-16]! // preserved required AAPCS registers
    str     X25,[SP, #-16]! // preserved required AAPCS registers
    str     X26,[SP, #-16]! // preserved required AAPCS registers
    str     X27,[SP, #-16]! // preserved required AAPCS registers
    str     X28,[SP, #-16]! // preserved required AAPCS registers
    str     X29,[SP, #-16]! // preserved required AAPCS registers

insert_into_file_loop:
    ldr     x0,=addStrBuf      		// load string buffer into x0
    ldr     x1,=addStrBufSize  		// load addStrBufSize into x1
    bl      buf_clear          		// clear the string buffer

    bl      getline           		// get a line from the file and put it into string buffer

    ldr     x0,=addStrBuf       	// load string buffer into x0
    ldrb    w1,[x0]             	// load first byte from string buffer into x1
    cmp     w1,#0               	// if byte from string buffer == 0,
    beq     insert_into_file_return     // string is empty at the end of the file, so don't append and insert the string into the list

    bl      append_line_feed       	// append carriage return and line feed to the string buffer

    bl      insert_into            	// insert the string into the list

    b       insert_into_file_loop  	// continue reading lines from the file

insert_into_file_return:
    ldr     X29,[SP],#16    		// preserved required AAPCS registers
    ldr     X28,[SP],#16    		// preserved required AAPCS registers
    ldr     X27,[SP],#16    		// preserved required AAPCS registers
    ldr     X26,[SP],#16    		// preserved required AAPCS registers
    ldr     X25,[SP],#16    		// preserved required AAPCS registers
    ldr     X24,[SP],#16    		// preserved required AAPCS registers
    ldr     X23,[SP],#16    		// preserved required AAPCS registers
    ldr     X22,[SP],#16    		// preserved required AAPCS registers
    ldr     X21,[SP],#16    		// preserved required AAPCS registers
    ldr     X20,[SP],#16    		// preserved required AAPCS registers
    ldr     X19,[SP],#16    		// preserved required AAPCS registers

    
    ldr     LR,[SP],#16     		// pop LR off the stack
    ret                    		// return to caller

/*
getline()
input the next line from file into the string buffer

must have access to:
FD
addStrBuf

not preserved:
nothing guaranteed to be preserved due to svc call
*/

getline:
    str     LR,[SP,#-16]!   		// push LR to the stack

    ldr     x0,=iFD           		// load file descriptor into x0
    ldrb    w0,[x0]            		// load value of file descriptor into x0
    ldr     x1,=addStrBuf      		// load string buffer into x1

getline_loop:
    bl      getchar       		// get a single character
    mov     x2,x0          		// move svc control to x2 (if #0, then the end of the file has been reached)

    ldrb    w0,[x1],#1     		// load next char from file addStrBuf to test and increment address

    cmp     w0,#10                      // compare char to line feed
    beq     getline_return              // if char == line feed, then we have reached end of line, so go to return statement

    cmp     x2,#0                       // compare svc control to #0
    beq     getline_return              // if svc control == #0, then we have reached the end of the file, so return

    b       getline_loop                // else, continue reading in characters

getline_return:
    ldr     LR,[SP],#16    		// pop LR off the stack
    ret                    		// return to caller

/*
getchar()
input the next character from file into x1 and return svc control

parameters:
x1 - file addStrBuf

must have access to:
FD

return:
x0 - svc control (if #0, then the end of the file has been reached)

not preserved:
nothing guaranteed to be preserved due to svc call
*/

getchar:
    str     LR,[SP,#-16]!   // push LR to the stack

    ldr     x0,=iFD         // load file descriptor into x0
    ldrb    w0,[x0]         // load value of file descriptor into w0

    mov     x2,#1           // load the # of characters to read in
    mov     x8,#63          // read
    svc     0               // system call to read

    ldr     LR,[SP],#16     // pop LR off the stack
    ret                     // return to caller

/*
buf_clear()
clear all bytes the string bffer

parameters:
x0 - buffer
x1 - buffer size

not preserved:
x0, x1, x2, x3
*/

buf_clear:
    str     LR,[SP,#-16]!       // push LR to the stack
    mov     x2,#0               // initialize counter into #2

buf_clear_loop:
    cmp     x1,x2               // if counter == addStrBufSize,
    beq     buf_clear_return    // we are done clearing, so go to return statement

    mov     w3,#0               // load #0 into w3
    strb    w3,[x0],#1          // stoer #0 into the next byte of the string buffer

    add     x2,x2,#1            // increment counter

    b       buf_clear_loop      // continue loop

buf_clear_return:
    ldr     LR,[SP],#16         // pop LR off the stack
    ret
 
/*
insert_into - insert string into linked list

parameters:
x0 - address of dyn alloc string

must have access to:
headPtr
tailPtr

Only AAPCS registers x19 - x29 are preserved
*/

insert_into:
    str     LR,[SP,#-16]!   // push LR to the stack

    str     X19,[SP, #-16]! // preserved required AAPCS registers
    str     X20,[SP, #-16]! // preserved required AAPCS registers
    str     X21,[SP, #-16]! // preserved required AAPCS registers
    str     X22,[SP, #-16]! // preserved required AAPCS registers
    str     X23,[SP, #-16]! // preserved required AAPCS registers
    str     X24,[SP, #-16]! // preserved required AAPCS registers
    str     X25,[SP, #-16]! // preserved required AAPCS registers
    str     X26,[SP, #-16]! // preserved required AAPCS registers
    str     X27,[SP, #-16]! // preserved required AAPCS registers
    str     X28,[SP, #-16]! // preserved required AAPCS registers
    str     X29,[SP, #-16]! // preserved required AAPCS registers
    
    // Step 1a. Get the length of the string (+1 to account for the null at the end)
    // Step 1b. Pass the length to malloc, and copy the string into the new malloc'd string. You have to remember where this is
    //          is so its probably best to store in a label or temp register.
    bl      String_copy     // copy string and return new string address
    str     x0,[SP,#-16]!   // push the new string address to the stack

    // Step 2a. Malloc 16 bytes (8 bytes for the &data element and 8 bytes for the &next element) for the newNode.
    mov     x0,#16          // load 16 bytes into x0 - bytes needed for one node (two pointers)
    bl      malloc          // address of dyn alloc mem for the node in x0

    // Step 2b. Store the address of previously malloc'd string in the newNode along with setting the next element to null.
    ldr     x1,[SP],#16    	    // pop copied string address off the stack into x1
    mov     x2,x0          	    // move new node address into x2
	
    str     x1,[x0],#8    	    // store copied string address to the new node and increment #8 so we can move on to handling the nex pointer

    mov     x1,#0           	    // move null #0 into x1
    str     x1,[x0]         	    // store null #0 into the pointer space in the node

    mov     x0,x2          	    // load unchanged new node address into x0

    // Step 2c. Insert the newNode into the linked list.
    ldr     x1,=tailPtr    	    // load tail into x1
    ldr     x2,[x1]        	    // load tail node address into x2

    str     x0,[x1]         	    // store new node address in tail pointer
    mov     x4,x1           	    // move updated tail pointer to x4 so we can save it

    ldr     x1,=headPtr    	    // load head into x1
    ldr     x3,[x1]         	    // load head in x3

    cmp     x3,#0                   // if head == null,
    beq     insert_into_init_head   // make new node head

    str     x0,[x2,#8]              // store the address of the current node in the next pointer of the previous node
                                    // previous node came from tail pointer

    b       insert_into_return      // go to return statement

insert_into_init_head:
    str     x0,[x1]         // store new node address in head pointer

insert_into_return:
    ldr     X29,[SP],#16    // preserved required AAPCS registers
    ldr     X28,[SP],#16    // preserved required AAPCS registers
    ldr     X27,[SP],#16    // preserved required AAPCS registers
    ldr     X26,[SP],#16    // preserved required AAPCS registers
    ldr     X25,[SP],#16    // preserved required AAPCS registers
    ldr     X24,[SP],#16    // preserved required AAPCS registers
    ldr     X23,[SP],#16    // preserved required AAPCS registers
    ldr     X22,[SP],#16    // preserved required AAPCS registers
    ldr     X21,[SP],#16    // preserved required AAPCS registers
    ldr     X20,[SP],#16    // preserved required AAPCS registers
    ldr     X19,[SP],#16    // preserved required AAPCS registers

    ldr     LR,[SP],#16     // pop LR off the stack
    ret                     // return to caller

/*
append_line_feed() - append carriage return and line feed into string buffer
we are working with windows input (\r\n), so to make all line ends constant, append \r\n

parameters:
x0 - string buffer

return:
x0 - string buffer with line feed

not preserved:
x0, x1, x2, x3, x4
*/

append_line_feed:
    str     LR,[SP,#-16]!   	    // push LR to the stack

    mov     x1,x0           	    // move the string into x1
    add     x1,x1,#1         	    // increment the address of the string (forward pointer)
    mov     x2,x0           	    // move the string into x2 and don't increment address (back pointer)

append_line_feed_loop:
    ldrb    w3,[x1],#1      	    // load next byte in forward pointer
    ldrb    w4,[x2],#1      	    // load next byte in back pointer

    cmp     w3,#0                   // if forward pointer == 0
    beq     check_line_feed         // check if we need to append line feed

    b       append_line_feed_loop   // else, continue loop

check_line_feed:
    cmp     w4,#0                   // if backward pointer == 0
    beq     append_line_feed_return // string is empty, so don't append a line feed

    cmp     w4,#10                  // if back pointer == line feed
    beq     append_line_feed_return // no need to append line feed
    
    mov     w4,#13                  // move carriage return into w4 (working with windows new line - \r\n)
    strb    w4,[x2],#1              // store carriage return into string buffer

    mov     w4,#10                  // move line feed into w4
    strb    w4,[x2]                 // store line feed into string buffer

append_line_feed_return:

    ldr     LR,[SP],#16     	    // pop LR off the stack
    ret                             // return to caller

    .end
