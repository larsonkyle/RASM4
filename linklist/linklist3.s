    .global delete_node

.equ        bufSize,    21

    .data

buffer:     .skip       21
dbDelete:   .quad       0
dbBefore:   .quad       0
dbAfter:    .quad       0
nodeNum:    .quad       0

    .text

delete_node:
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

    ldr     x0,=buffer
    ldr     x1,=bufSize
    bl      getstring
    
    ldr     x0,=buffer
    bl      ascint64

    ldr     x1,=nodeNum
    str     x0,[x1]

    ldr     x1,=headPtr
    bl      search_for
    cmp     x0,#0
    beq     _start

    ldr     x1,=dbDelete
    str     x0,[x1]

    ldr     x1,=headPtr
    ldr     x1,[x1]
    cmp     x0,x1
    beq     delete_head
    
    ldr     x1,=tailPtr
    ldr     x1,[x1]
    cmp     x0,x1
    beq     delete_tail

    ldr     x0,=nodeNum
    ldr     x0,[x0]
    add     x0,x0,#1
    ldr     x1,=headPtr
    bl      search_for

    ldr     x1,=dbAfter
    str     x0,[x1]

    ldr     x0,=nodeNum
    ldr     x0,[x0]
    sub     x0,x0,#1
    ldr     x1,=headPtr
    bl      search_for

    ldr     x1,=dbBefore
    str     x0,[x1]

    add     x0,x0,#8

    ldr     x1,=dbAfter
    ldr     x1,[x1]
    str     x1,[x0]

    ldr     x0,=dbDelete
    ldr     x0,[x0]

    ldr     x1,[x0]         // load string into x1

    str     x1,[SP,#-16]!   // push the string to the stack
    bl      free

    ldr     x0,[SP],#16     // pop the string off the stack
    bl      free            // free the current string

    b       delete_return

delete_head:
    ldr     x2,=tailPtr
    ldr     x2,[x2]

    cmp     x1,x2
    beq     one_node

    mov     x0,#1
    ldr     x1,=headPtr
    bl      search_for

    ldr     x1,=dbAfter
    str     x0,[x1]

    ldr     x1,=headPtr
    str     x0,[x1]

    ldr     x0,=dbDelete
    ldr     x0,[x0]

    ldr     x1,[x0]         // load string into x1

    str     x1,[SP,#-16]!   // push the string to the stack
    bl      free

    ldr     x0,[SP],#16     // pop the string off the stack
    bl      free

    b       delete_return

one_node:
    ldr     x0,=headPtr
    mov     x1,#0
    str     x1,[x0]

    ldr     x0,=tailPtr
    mov     x1,#0
    str     x1,[x0]

    ldr     x0,=dbDelete
    ldr     x0,[x0]

    ldr     x1,[x0]         // load string into x1

    str     x1,[SP,#-16]!   // push the string to the stack
    bl      free

    ldr     x0,[SP],#16     // pop the string off the stack
    bl      free

    b       delete_return

delete_tail:
    ldr     x0,=nodeNum
    ldr     x0,[x0]
    sub     x0,x0,#1
    ldr     x1,=headPtr
    bl      search_for

    ldr     x1,=dbBefore
    str     x0,[x1]

    mov     x1,x0
    add     x1,x1,#8
    mov     x2,#0
    str     x2,[x1]

    ldr     x1,=tailPtr
    str     x0,[x1]

    ldr     x0,=dbDelete
    ldr     x0,[x0]

    ldr     x1,[x0]         // load string into x1

    str     x1,[SP,#-16]!   // push the string to the stack
    bl      free

    ldr     x0,[SP],#16     // pop the string off the stack
    bl      free

delete_return:

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
