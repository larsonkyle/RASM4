    .global save_list

    .text

/*
save_list - save all string in the list to a file

must have access to:
headPtr
tailPtr

int64asc, putstring, putch - registers x0 - x10 are not preserved
*/

save_list:
    str     LR,[SP,#-16]!   // push LR to the stack

    ldr     x0,=headPtr     // load head pinter into x0
    ldr     x0,[x0]         // load head into x0

loop:
    cmp     x0,#0           // if head == null, there are no nodes, so
    beq     print_return    // end loop

    mov     x19,x0          // save the address of the current node to x19
    ldr     x20,[x0]        // load the string of the current node into x20
    ldr     x0,[x0,#8]      // load the next node into x0

    str     x0,[SP,#-16]!   // push the next node to the stack

    ldr     x1,=tailPtr     // load tail pointer into x1
    ldr     x1,[x1]         // load the last node into x1
    cmp     x1,x19          // if last node == saved address of current node,
    beq     last_line       // go to special case for handling the last string

    mov     x0,x20          // mov string into x0
    bl      String_length   // get the length of the string and put it into x0
    mov     x2,x0           // mov string length into x2

    b       save_write      // go to writing the string to file

// if there is extra line with no data at end, \r\n is already on the last line of data
// if there is no extra line, \r\n is appended to the last line of data
last_line:
    mov     x0,x20          // mov string into x0
    bl      String_length   // get the length of the string and put it into x0
    sub     x0,x0,#2        // subtract 2 for the carriage return and line feed 
    mov     x2,x0           // mov string length into x2

save_write:
    ldr     x0,=iFD         // load file descriptor into x0
    ldrb    w0,[x0]         // load value of file descriptor into w0
    mov     x1,x20          // load string to print into x1

    mov     x8,#64          // write
    svc     0               // system call to read

    ldr     x0,[SP],#16     // pop the next node off the stack
    b       loop            // continue loop

print_return:
    ldr     LR,[SP],#16     // pop LR off the stack
    ret                     // return to caller

    .end
    