    .global print_list

    .data

numBuf:     .skip       21
chSP:       .byte       32
chFB:       .byte       91
chBB:       .byte       93

    .text

/*
print_list - insert string into linked list

parameters:
x0 - headPtr

int64asc, putstring, putch - registers x0 - x10 are not preserved
 */

print_list:
    str     LR,[SP,#-16]!   // push LR to the stack
    
    ldr     x0,[x0]         // load head into x0

    mov     x1,#0           // initialize index counter to 0

loop:
    cmp     x0,#0           // if head == null, there are no nodes, so
    beq     print_return    // end loop

    str     x1,[SP,#-16]!   // push index counter to the stack
    str     x0,[SP,#-16]!   // push current node address to the stack
    str     x0,[SP,#-16]!   // push current node address to the stack again

    mov     x0,x1           // move index coutner to x0
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

    ldr     x0,[SP],#16     // pop current node address off the stack
    ldr     x0,[x0]         // load the string of the current node
    bl      putstring       // output this string

    ldr     x0,[SP],#16     // pop current node address off the stack
    ldr     x0,[x0,#8]      // load the next node into x0

    ldr     x1,[SP],#16     // pop the index counter off the stack
    add     x1,x1,#1        // increment the index counter

    b       loop            // continue loop

print_return:
    ldr     LR,[SP],#16     // pop LR off the stack
    ret                     // return to caller

    .end
    