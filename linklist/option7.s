    .global free_list

    .text

/*
free_list - free all nodes in the linked list

parameters:
x0 - headPtr

Only AAPCS registers x19 - x29 are preserved
 */

free_list:
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

    ldr     x0,[x0]         // load head into x0

free_loop:
    cmp     x0,#0           // if head/next pointer == null
    beq     free_return     // end loop

    ldr     x1,[x0]         // load the string of the current node
    ldr     x2,[x0,#8]      // load the next node into x2

    str     x2,[SP,#-16]!   // push the next node to the stack
    str     x1,[SP,#-16]!   // push the string to the stack

    bl      free            // free the current node

    ldr     x0,[SP],#16     // pop the string off the stack
    bl      free            // free the current string

    ldr     x0,[SP],#16     // pop the next node
    b       free_loop       // continue loop

free_return:
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
    