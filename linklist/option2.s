    .global insert_into_kbd
    .global insert_into_file
    .global insert_into
    .global append_line_feed

.equ        bufSize,    100

    .data

buffer:     .skip       100

    .text

/*
insert_into_kbd - given the headPtr and tailPtr of the linked list, get string
input from the user and push it to the list

parameters:
x0 - headPtr
x1 - tailPtr
access to buffer

All registers are preserved except x1 and x2
*/

insert_into_kbd:
    str     LR,[SP,#-16]!   // push LR to the stack
    
    str     X19,[SP, #-16]! // preserved required AAPCS registers
    str     X20,[SP, #-16]!
    str     X21,[SP, #-16]!
    str     X22,[SP, #-16]!
    str     X23,[SP, #-16]!
    str     X24,[SP, #-16]!
    str     X25,[SP, #-16]!
    str     X26,[SP, #-16]!
    str     X27,[SP, #-16]!
    str     X28,[SP, #-16]!
    str     X29,[SP, #-16]!

    str     x0,[SP,#-16]!   // push LR to the stack
    str     x1,[SP,#-16]!   // push LR to the stack

    ldr     x0,=buffer
    ldr     x1,=bufSize
    bl      getstring

    ldr     x0,=buffer
    bl      append_line_feed

    ldr     x2,[SP],#16     // pop LR off the stack
    ldr     x1,[SP],#16     // pop LR off the stack
    bl      insert_into

    ldr     X29,[SP],#16    // preserved required AAPCS registers
    ldr     X28,[SP],#16
    ldr     X27,[SP],#16
    ldr     X26,[SP],#16
    ldr     X25,[SP],#16
    ldr     X24,[SP],#16
    ldr     X23,[SP],#16
    ldr     X22,[SP],#16
    ldr     X21,[SP],#16
    ldr     X20,[SP],#16
    ldr     X19,[SP],#16

    ldr     LR,[SP],#16     // pop LR off the stack
    ret                     // return to caller


insert_into_file:
    str     LR,[SP,#-16]!   // push LR to the stack

    str     X19,[SP, #-16]! // preserved required AAPCS registers
    str     X20,[SP, #-16]!
    str     X21,[SP, #-16]!
    str     X22,[SP, #-16]!
    str     X23,[SP, #-16]!
    str     X24,[SP, #-16]!
    str     X25,[SP, #-16]!
    str     X26,[SP, #-16]!
    str     X27,[SP, #-16]!
    str     X28,[SP, #-16]!
    str     X29,[SP, #-16]!

    str     x0,[SP,#-16]!   // push FD to the stack
    str     x1,[SP,#-16]!   // push FD to the stack
    str     x2,[SP,#-16]!   // push FD to the stack

insert_into_file_loop:
    ldr     x2,[SP],#16     // pop FD off the stack
    ldr     x1,[SP],#16     // pop FD off the stack
    ldr     x0,[SP],#16     // pop FD off the stack

    str     x0,[SP,#-16]!   // push FD to the stack
    str     x1,[SP,#-16]!   // push FD to the stack
    str     x2,[SP,#-16]!   // push FD to the stack

    ldr     x1,=buffer      // load file buffer into x1
    bl      buf_clear
    ldr     x1,=buffer
    bl      getline

    ldr     x0,=buffer
    ldrb    w1,[x0]
    cmp     w1,#0
    beq     insert_into_file_return

    ldr     x2,[SP],#16     // pop FD off the stack
    ldr     x1,[SP],#16     // pop FD off the stack

    bl      insert_into

    str     x1,[SP,#-16]!   // push FD to the stack
    str     x2,[SP,#-16]!   // push FD to the stack

    b       insert_into_file_loop

insert_into_file_return:
    add     SP,SP,#48       // want to leave svc control in x0 for return

    ldr     X29,[SP],#16    // preserved required AAPCS registers
    ldr     X28,[SP],#16
    ldr     X27,[SP],#16
    ldr     X26,[SP],#16
    ldr     X25,[SP],#16
    ldr     X24,[SP],#16
    ldr     X23,[SP],#16
    ldr     X22,[SP],#16
    ldr     X21,[SP],#16
    ldr     X20,[SP],#16
    ldr     X19,[SP],#16
    
    ldr     LR,[SP],#16     // pop LR off the stack
    ret                     // return to caller

/*
getline()
given FD in x0 and file buffer in x1, input the next line
from file into x1 and return svc control

parameters:
x0 - FD
x1 - file buffer

local:
x2 - # of bytes to read (1)
x8 - getchar() svc call # (63)

return:
x0 - svc control (if #0, then the end of the file has been reached)

not preserved:
nothing guaranteed to be preserved due to svc call
*/

getline:
    str     LR,[SP,#-16]!   // push LR to the stack
    str     x0,[SP,#-16]!   // push FD to the stack

getline_loop:
    ldr     x0,[SP],#16     // pop FD off the stack
    str     x0,[SP,#-16]!   // push FD to the stack
    bl      getchar         // put next character in x1
    mov     x2,x0           // move svc control to x2 (if #0, then the end of the file has been reached)

    ldrb    w0,[x1],#1      // load next char from file buffer to test and increment address

    cmp     w0,#10                      // compare char to line feed
    beq     getline_done_line_feed      // if char == line feed, then we have reached end of line, so take line feed and return

    cmp     x2,#0                       // compare svc control to #0
    beq     getline_done_file_end       // if svc control == #0, then we have reached the end of the file, so return

    b       getline_loop                // else, continue reading in characters

getline_done_line_feed:
    mov     w2,#0           // move #0 into x2 - null character
    ldr     w2,[x1]

    b       getline_return

getline_done_file_end:
    mov     w2,#0           // move #0 into x2 - null character
    ldr     w2,[x1]

    ldr     x1,=buffer
    ldrb    w2,[x1]
    cmp     w2,#0
    beq     getline_return

    mov     x0,x1
    bl      append_line_feed
    mov     x1,x0

getline_return:
    add     SP,SP,#16       // want to leave svc control in x0 for return
    ldr     LR,[SP],#16     // pop LR off the stack
    ret                     // return to caller

/*
getchar()
given FD in x0 and file buffer in x1, input the next character 
from file into x1 and return svc control

parameters:
x0 - FD
x1 - file buffer

local:
x2 - # of bytes to read (1)
x8 - svc call # (63)

return:
x0 - svc control (if #0, then the end of the file has been reached)

not preserved:
nothing guaranteed to be preserved due to svc call
*/

getchar:
    str     LR,[SP,#-16]!   // push LR to the stack

    mov     x2,#1           // load the # of characters to read in
    mov     x8,#63          // read
    svc     0               // system call to read

    ldr     LR,[SP],#16     // pop LR off the stack
    ret                     // return to caller



buf_clear:
    str     LR,[SP,#-16]!   // push LR to the stack
    mov     x3,#0
    ldr     x4,=bufSize

buf_clear_loop:
    cmp     x3,x4
    beq     buf_clear_return

    mov     w2,#0
    strb    w2,[x1],#1

    add     x3,x3,#1

    b       buf_clear_loop

buf_clear_return:
    ldr     LR,[SP],#16     // pop LR off the stack
    ret
 

/*
insert_into - insert string into linked list

parameters:
x0 - address of dyn alloc string
x1 - headPtr
x2 - tailPtr

return:
x1 - headPtr
x2 - tailPtr

Only AAPCS registers x19 - x29 are preserved
 */

insert_into:
    str     LR,[SP,#-16]!   // push LR to the stack

    str     X19,[SP, #-16]! // preserved required AAPCS registers
    str     X20,[SP, #-16]!
    str     X21,[SP, #-16]!
    str     X22,[SP, #-16]!
    str     X23,[SP, #-16]!
    str     X24,[SP, #-16]!
    str     X25,[SP, #-16]!
    str     X26,[SP, #-16]!
    str     X27,[SP, #-16]!
    str     X28,[SP, #-16]!
    str     X29,[SP, #-16]!

    str     x1,[SP, #-16]!  // push headPtr to the stack
    str     x2,[SP, #-16]!  // push tailPtr to the stack
    
    // Step 1a. Get the length of the string (+1 to account for the null at the end)
    // Step 1b. Pass the length to malloc, and copy the string into the new malloc'd string. You have to remember where this is
    //          is so its probably best to store in a label or temp register.
    bl      String_copy     // copy string and return new string address
    str     x0,[SP,#-16]!   // push the new string address to the stack

    // Step 2a. Malloc 16 bytes (8 bytes for the &data element and 8 bytes for the &next element) for the newNode.
    mov     x0,#16          // load 16 bytes into x0 - bytes needed for one node (two pointers)
    bl      malloc          // address of dyn alloc mem for the node in x0

    // Step 2b. Store the address of previously malloc'd string in the newNode along with setting the next element to null.
    ldr     x1,[SP],#16     // pop copied string address off the stack into x1
    mov     x2,x0           // move new node address into x2

    str     x1,[x0],#8      // store copied string address to the new node and increment #8 so we can move on to handling the nex pointer

    mov     x1,#0           // move null #0 into x1
    str     x1,[x0]         // store null #0 into the pointer space in the node

    mov     x0,x2           // load unchanged new node address into x0

    // Step 2c. Insert the newNode into the linked list.
    ldr     x1,[SP],#16     // load tailPtr into x1
    ldr     x2,[x1]         // load tail node address into x2

    str     x0,[x1]         // store new node address in tail pointer
    mov     x4,x1           // move updated tail pointer to x4 so we can save it

    ldr     x1,[SP],#16     // load headPtr into x1
    str     x4,[SP, #-16]!  // push tail pointer to the stack
    ldr     x3,[x1]         // load head in x3

    cmp     x3,#0                   // if head == null,
    beq     insert_into_init_head   // make new node head

    str     x0,[x2,#8]              // store the address of the current node in the next pointer of the previous node
                                    // previous node came from tail pointer

    b       insert_into_return      // go to return statement

insert_into_init_head:
    str     x0,[x1]         // store new node address in head pointer

insert_into_return:
    ldr     x2,[SP],#16     // pop tail pointer off the stack

    ldr     X29,[SP],#16    // preserved required AAPCS registers
    ldr     X28,[SP],#16
    ldr     X27,[SP],#16
    ldr     X26,[SP],#16
    ldr     X25,[SP],#16
    ldr     X24,[SP],#16
    ldr     X23,[SP],#16
    ldr     X22,[SP],#16
    ldr     X21,[SP],#16
    ldr     X20,[SP],#16
    ldr     X19,[SP],#16

    ldr     LR,[SP],#16     // pop LR off the stack
    ret                     // return to caller

append_line_feed:
    str     LR,[SP,#-16]!   // push LR to the stack

    str     X19,[SP, #-16]! // preserved required AAPCS registers
    str     X20,[SP, #-16]! 
    str     X21,[SP, #-16]!
    str     X22,[SP, #-16]!
    str     X23,[SP, #-16]!
    str     X24,[SP, #-16]!
    str     X25,[SP, #-16]!
    str     X26,[SP, #-16]!
    str     X27,[SP, #-16]!
    str     X28,[SP, #-16]!
    str     X29,[SP, #-16]!

    mov     x1,x0           // move the string into x1
    add     x1,x1,#1        // increment the address of the string (forward pointer)
    mov     x2,x0           // move the string into x2 and don't increment address (back pointer)

append_line_feed_loop:
    ldrb    w3,[x1],#1      // load next byte in forward pointer
    ldrb    w4,[x2],#1      // load next byte in back pointer

    cmp     w3,#0                   // if forward pointer == 0
    beq     check_line_feed         // check if we need to append line feed

    b       append_line_feed_loop   // else, continue loop

check_line_feed:
    cmp     w4,#0                       // if backward pointer == 0
    beq     append_line_feed_return     // string is empty, so don't append a line feed

    cmp     w4,#10                      // if back pointer == line feed
    beq     append_line_feed_return     // no need to append line feed

    mov     w4,#10                  // move line feed into w4
    strb    w4,[x2],#1              // store line feed into new string

    mov     w4,#0                   // move null terminator into w4
    strb    w4,[x2]                 // store null terminator into new string

append_line_feed_return:
    ldr     X29,[SP],#16    // preserved required AAPCS registers
    ldr     X28,[SP],#16
    ldr     X27,[SP],#16
    ldr     X26,[SP],#16
    ldr     X25,[SP],#16
    ldr     X24,[SP],#16
    ldr     X23,[SP],#16
    ldr     X22,[SP],#16
    ldr     X21,[SP],#16
    ldr     X20,[SP],#16
    ldr     X19,[SP],#16

    ldr     LR,[SP],#16     // pop LR off the stack
    ret                     // return to caller

    .end
