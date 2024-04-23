    .global insert_into_kbd
    .global insert_into_file

.equ        bufSize,    256

    .data

buffer:     .skip       256

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
    mov     x2,#0           // move #0 into x1
    str     x2,[x1]         // store #0 into file buffer - clear file buffer
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
    
