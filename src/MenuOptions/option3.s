    .global delete_node
    .global search_for

.equ        delBufSize,    21

    .data

strPrompt:  .asciz      "Enter Index to Delete: "

delBuf:     .skip       21
dbDelete:   .quad       0
dbBefore:   .quad       0
dbAfter:    .quad       0
nodeNum:    .quad       0

    .text

/*
delete_node() - get an index from the user and delete the node at that index

must have access to:
headPtr
tailPtr
delBuf
dbDelete
dbBefore
dbAfter
nodeNum

not preserved:
Only AAPCS registers x19 - x29 are preserved
*/

delete_node:
    str     LR,[SP,#-16]!       // push LR to the stack
    
    str     X19,[SP, #-16]!     // preserved required AAPCS registers
    str     X20,[SP, #-16]!     // preserved required AAPCS registers
    str     X21,[SP, #-16]!     // preserved required AAPCS registers
    str     X22,[SP, #-16]!     // preserved required AAPCS registers
    str     X23,[SP, #-16]!     // preserved required AAPCS registers
    str     X24,[SP, #-16]!     // preserved required AAPCS registers
    str     X25,[SP, #-16]!     // preserved required AAPCS registers
    str     X26,[SP, #-16]!     // preserved required AAPCS registers
    str     X27,[SP, #-16]!     // preserved required AAPCS registers
    str     X28,[SP, #-16]!     // preserved required AAPCS registers
    str     X29,[SP, #-16]!     // preserved required AAPCS registers

    ldr     x0,=strPrompt       // load user prompt
    bl      putstring           // output user prompt

    ldr     x0,=delBuf          // load delete buffer into x0
    ldr     x1,=delBufSize      // load delete buffer size into x1
    bl      getstring           // get input from user and store into buffer
    
    ldr     x0,=delBuf          // load delete buffer into x0
    bl      ascint64            // convert the string in the buffer to a integer

    ldr     x1,=nodeNum         // load nodeNum into x1
    str     x0,[x1]             // store the converted string into nodeNum

    bl      search_for          // get the address of the node we are deleting
    cmp     x0,#0               // if we get #0 returned, that means the node does not exist
    beq     delete_return       // handle the error

    ldr     x1,=dbDelete        // load the node to delete into x1
    str     x0,[x1]             // store the returned address into x1

    ldr     x1,=headPtr         // load head pointer into x1
    ldr     x1,[x1]             // load head node into x1
    cmp     x0,x1               // if dbDelete == address of head node,
    beq     delete_head         // we are deleting the head, so handle that case
    
    ldr     x1,=tailPtr         // load tail pointer into x1
    ldr     x1,[x1]             // load tail node into x1
    cmp     x0,x1               // if dbDelete == address of tail node,
    beq     delete_tail         // we are deleting the tail, so handle that case

    ldr     x0,=nodeNum         // load nodeNum into x0
    ldr     x0,[x0]             // load the index of the node to delete into x0
    add     x0,x0,#1            // get the index of the node past it
    bl      search_for          // get the address of the node past the node we are deleting

    ldr     x1,=dbAfter         // load the node after the node being deleted into x1
    str     x0,[x1]             // store the address of the node after the node being deleted into x1

    ldr     x0,=nodeNum         // load nodeNum into x0
    ldr     x0,[x0]             // load the index of the node to delete into x0
    sub     x0,x0,#1            // get the index of the node before it
    bl      search_for          // get the address of the node before the node we are deleting

    ldr     x1,=dbBefore        // load the node before the node being deleted into x1
    str     x0,[x1]             // store the address of the node before the node being deleted into x1

    add     x0,x0,#8            // increment the address of the node before the node being deleted by 8 to get its next pointer

    ldr     x1,=dbAfter         // load dbAfter into x1
    ldr     x1,[x1]             // load the node after the node being deleted into x1
    str     x1,[x0]             // store the node after the node being deleted into the next pointer of the node before the node being deleted

    ldr     x0,=dbDelete        // load dbDelete into x0
    ldr     x0,[x0]             // load the node to delete into x0

    ldr     x1,[x0]             // load the string of that node into x1

    str     x1,[SP,#-16]!       // push the string to the stack
    bl      free                // free the node

    ldr     x0,[SP],#16         // pop the string off the stack
    bl      free                // free the string

    b       delete_return       // go to the return statement

delete_head:
    ldr     x2,=tailPtr         // load the tail into x2
    ldr     x2,[x2]             // load the tail node into x2

    cmp     x1,x2               // if head node == tail node,
    beq     one_node            // we only have one node in the list, so handle that 

    mov     x0,#1               // move #1 into x0 (index 1 will always be node after head)
    ldr     x1,=headPtr         // load headPtr into x1
    bl      search_for          // get the address of the second node

    ldr     x1,=headPtr         // load headPtr into x1
    str     x0,[x1]             // store the address of the second node into x1

    ldr     x0,=dbDelete        // load dbDelete into x0
    ldr     x0,[x0]             // load the node to delete into x0

    ldr     x1,[x0]             // load the string of that node into x1

    str     x1,[SP,#-16]!       // push the string to the stack
    bl      free                // free the node

    ldr     x0,[SP],#16         // pop the string off the stack
    bl      free                // free the string

    b       delete_return       // go to the return statement

one_node:
    ldr     x0,=headPtr         // load headPtr into x0
    mov     x1,#0               // mov #0 into x1 (reset head pointer)
    str     x1,[x0]             // store #0 into x1

    ldr     x0,=tailPtr         // load tailPtr into x0
    mov     x1,#0               // mov #0 into x1 (reset tail pointer)
    str     x1,[x0]             // stre #0 into x1

    ldr     x0,=dbDelete        // load dbDelete into x0
    ldr     x0,[x0]             // load the node to delete into x0

    ldr     x1,[x0]             // load the string of that node into x1

    str     x1,[SP,#-16]!       // push the string to the stack
    bl      free                // free the node

    ldr     x0,[SP],#16         // pop the string off the stack
    bl      free                // free the string

    b       delete_return       // go to the return statement

delete_tail:
    ldr     x0,=nodeNum         // load nodeNum into x0
    ldr     x0,[x0]             // load the index of the tail node into x0
    sub     x0,x0,#1            // get the index of the second to last node
    bl      search_for          // get the address of the second to last node

    mov     x1,x0               // move address of node before tail into x1
    add     x1,x1,#8            // increment x1 by 8 to get the next pointer
    mov     x2,#0               // move #0 into x2 (make next pointer null)
    str     x2,[x1]             // store #0 into x2

    ldr     x1,=tailPtr         // load tailPtr into x1
    str     x0,[x1]             // store address of the second to last node into tailPtr

    ldr     x0,=dbDelete        // load dbDelete into x0
    ldr     x0,[x0]             // load the node to delete into x0

    ldr     x1,[x0]             // load the string of that node into x1

    str     x1,[SP,#-16]!       // push the string to the stack
    bl      free                // free the node

    ldr     x0,[SP],#16         // pop the string off the stack
    bl      free                // free the string

delete_return:
    ldr     X29,[SP],#16        // preserved required AAPCS registers
    ldr     X28,[SP],#16        // preserved required AAPCS registers
    ldr     X27,[SP],#16     	// preserved required AAPCS registers
    ldr     X26,[SP],#16     	// preserved required AAPCS registers
    ldr     X25,[SP],#16     	// preserved required AAPCS registers
    ldr     X24,[SP],#16     	// preserved required AAPCS registers
    ldr     X23,[SP],#16     	// preserved required AAPCS registers
    ldr     X22,[SP],#16     	// preserved required AAPCS registers
    ldr     X21,[SP],#16     	// preserved required AAPCS registers
    ldr     X20,[SP],#16
    ldr     X19,[SP],#16

    ldr     LR,[SP],#16         // pop LR off the stack
    ret                         // return to caller

/*
search_for - given an index of a node, return its address

parameters:
x0 - node index

return:
x0 - node address
if there is no node with the index, 0 is returned to x0

All registers are preserved except x1 and x2
*/

search_for:
    str     LR,[SP,#-16]!   // push LR to the stack

    ldr     x1,=headPtr
    ldr     x1,[x1]         // load head into x0

search_for_loop:
    cmp     x0,#0               // if we have reached the node we are looking for
    beq     search_for_return   // end loop

    cmp     x1,#0               // if head/next pointer == null
    beq     search_for_return   // end loop

    ldr     x2,[x1,#8]          // load the pointer to the next node in x2
    mov     x1,x2               // move the next node into x1 so we can get its next pointer in the next iteration

    sub     x0,x0,#1            // decrement loop control
    b       search_for_loop     // continue loop

search_for_return:
    mov     x0,x1           // move the address of the found node into the return register x0
                            // if there is no node at that index, return 0
                            // headPtr initialized to 0 and null tail pointer = 0, so all cases are covered

    ldr     LR,[SP],#16     // pop LR off the stack
    ret                     // return to caller

    .end
    
