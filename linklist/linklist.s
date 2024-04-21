    .global insert_into
    .global print_list
    .global free_list

/*
insert_into - insert string into linked list

parameters:
x0 - string address

AAPCS registers x19 - x29 are preserved (none others guaranteed)
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
    mov     x2,x0           // move new node address into x3

    str     x1,[x0],#8      // store copied string address to the new node and increment #8 so we can move on to handling the nex pointer

    mov     x1,#0           // move null #0 into x1
    str     x1,[x0]         // store null #0 into the pointer space in the node

    mov     x0,x2           // load unchanged new node address into x0

    // Step 2c. Insert the newNode into the linked list.
    ldr     x1,=tailPtr     // load address of tail pointer into x1
    ldr     x2,[x1]         // load tail node address into x2

    str     x0,[x1]         // store new node address in tail pointer

    ldr     x1,=headPtr     // load address of head pointer into x1
    ldr     x1,[x1]         // load head in x1

    cmp     x1,#0                   // if head == null,
    beq     insert_into_init_head   // make new node head

    str     x0,[x2,#8]              // store the address of the current node in the next pointer of the previous node
                                    // previous node came from tail pointer

    b       insert_into_return      // go to return statement

insert_into_init_head:
    ldr     x1,=headPtr     // load address of head pointer into x1
    str     x0,[x1]         // store new node address in head pointer

insert_into_return:
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
print_list - insert string into linked list

parameters:
x0 - head pointer

putstring - All registers are preserved, except X0, X1, X2, and X8.
 */

print_list:
    str     LR,[SP,#-16]!   // push LR to the stack
    
    ldr     x0,[x0]         // load head into x0

loop:
    cmp     x0,#0           // if head == null, there are no nodes, so
    beq     print_return    // end loop

    str     x0,[SP,#-16]!   // push current node pointer
    ldr     x0,[x0]         // load the string of the current node
    bl      putstring       // output this string

    ldr     x0,[SP],#16     // pop current node pointer
    ldr     x0,[x0,#8]      // load the next node pointer
    b       loop            // continue loop

print_return:
    ldr     LR,[SP],#16     // pop LR off the stack
    ret                     // return to caller

/*
free_list - free all nodes in the linked list

parameters:
x0 - head pointer

AAPCS registers x19 - x29 are preserved (none others guaranteed)
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
    ldr     x2,[x0,#8]      // load the pointer to the next node in x2

    str     x2,[SP,#-16]!   // push the next node to the stack
    str     x1,[SP,#-16]!   // push the string to the stack

    bl      free            // free the current node

    ldr     x0,[SP],#16     // pop the string off the stack
    bl      free            // free the current string

    ldr     x0,[SP],#16     // pop the next node pointer
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

    .end
    