    .global edit_string

.equ    editBufSize, 100

    .data

editBuf:        .skip   100
dbEdit:         .quad   0
stringPtr:      .quad   0

strPrompt1:     .asciz  "Enter Index To Edit: "
strPrompt2:     .asciz  "Enter New String: "

    .text

edit_string:
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

    ldr     x0,=editBuf         //load editbuf
    ldr     x1,=editBufSize     //load size of editbuf
    bl      buf_clear           //branch to buf_clear

    ldr     x0,=strPrompt1      // load user prompt
    bl      putstring           // output user prompt

    ldr     x0,=editBuf         // load delete buffer into x0
    ldr     x1,=editBufSize     // load delete buffer size into x1
    bl      getstring           // get input from user and store into buffer
    
    ldr     x0,=editBuf         // load delete buffer into x0
    bl      ascint64            // convert the string in the buffer to a integer

    bl      search_for          // get the address of the node we are deleting
    cmp     x0,#0               // if we get #0 returned, that means the node does not exist
    beq     edit_return         // handle the error

    ldr     x1,=dbEdit          // load the node to delete into x1
    str     x0,[x1]             // store the returned address into x1

    ldr     x0,=editBuf         //load editbuf
    ldr     x1,=editBufSize     //load size of editbuf
    bl      buf_clear           //branch to buf_clear

    ldr     x0,=strPrompt2      // load user prompt
    bl      putstring           // output user prompt

    ldr     x0,=editBuf         // load delete buffer into x0
    ldr     x1,=editBufSize     // load delete buffer size into x1
    bl      getstring           // get input from user and store into buffer

    ldr     x0,=editBuf         // load editbuf
    bl      append_line_feed    // append carriage return and line feed to the string buffer
    bl      String_copy         // branch to string_copy

    ldr     x1,=stringPtr       // load stringptr
    str     x0,[x1]             // store into stringptr

    ldr     x0,=dbEdit          // load dbEdit
    ldr     x0,[x0]             // dereference dbedit
    ldr     x0,[x0]             // dereference dbedit
    bl      free                // free memory

    ldr     x0,=dbEdit          // load dbedit
    ldr     x0,[x0]             // load contents of dbedit
    ldr     x1,=stringPtr       // load strinptr
    ldr     x1,[x1]             // load stringtr
    str     x1,[x0]             // store string pointer into contents of dbedit

edit_return:
    ldr     X29,[SP],#16    // preserved required AAPCS registers
    ldr     X28,[SP],#16    // preserved required AAPCS registers
    ldr     X27,[SP],#16    // preserved required AAPCS registers
    ldr     X26,[SP],#16    // preserved required AAPCS registers
    ldr     X25,[SP],#16    // preserved required AAPCS registers
    ldr     X24,[SP],#16    // preserved required AAPCS registers
    ldr     X23,[SP],#16    // preserved required AAPCS registers
    ldr     X22,[SP],#16    // preserved required AAPCS registers
    ldr     X21,[SP],#16    // preserved required AAPCS registers
    ldr     X20,[SP],#16    // preserved required AAPCS registers
    ldr     X19,[SP],#16    // preserved required AAPCS registers

    ldr     LR,[SP],#16     // pop LR off the stack
    ret                     // return to caller

    .end
