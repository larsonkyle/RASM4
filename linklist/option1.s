    .global print_list

    .data

numBuf:     .skip       21
chSP:       .byte       32
chFB:       .byte       91
chBB:       .byte       93

    .text

/*
print_list - print all strings in linked list

must have access to headPtr adn numBuf

int64asc, putstring, putch - registers x0 - x10 are not preserved
*/

print_list:
    str     LR,[SP,#-16]!   // push LR to the stack

    ldr     x0,=headPtr     // load head pinter into x0
    ldr     x0,[x0]         // load head into x0

    mov     x19,#0          // initialize index counter to 0

loop:
    cmp     x0,#0           // if head == null, there are no nodes, so
    beq     print_return    // end loop

    ldr     x20,[x0]        // load the string of the current node into x20
    ldr     x21,[x0,#8]     // load the next node into x21

    mov     x0,x19          // move index coutner to x0
    ldr     x1,=numBuf      // load number numBuf into x1
    bl      int64asc        // store index counter as a string in the number numBuf

    ldr     x0,=chFB        // load front bracket into x0
    bl      putch           // output front bracket

    ldr     x0,=numBuf      // load index as a string into x0
    bl      putstring       // output the index of the current node

    ldr     x0,=chBB        // load back bracket into x0
    bl      putch           // output back bracket

    ldr     x0,=chSP        // load space into x0
    bl      putch           // output space

    mov     x0,x20          // move the string of the current node into x0
    bl      putstring       // output this string

    mov     x0,x21          // move next node into x0
    add     x19,x19,#1      // increment the index counter

    b       loop            // continue loop

print_return:
    ldr     LR,[SP],#16     // pop LR off the stack
    ret                     // return to caller

    .end
    