    .global insert_into
    .global print_list
    .global free_list
    .global search_for
    .global append_line_feed

    .data

numBuf:     .skip       21
chSP:       .byte       32
chFB:       .byte       91
chBB:       .byte       93

    .text

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

/*
search_for - given an index of a node, return its address

parameters:
x0 - node index
x1 - headPtr

return:
x0 - node address
if there is no node with the index, 0 is returned to x0

All registers are preserved except x1 and x2
*/

search_for:
    str     LR,[SP,#-16]!   // push LR to the stack

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

/*
append_line_feed - given an address of a string, return the address of the same string 
with a line feed before the null terminator. If the string already has a line feed before the
null terminator, the same string address that was passed is returned (never changed).

parameters:
x0 - address of dyn alloc string

return:
x0 - new string address

Only AAPCS registers x19 - x29 are preserved
*/

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
