    .global _start

.equ        DFD,            -100        // DFD
.equ        READ,           0000        // flags
.equ        WRITE,          0001        // flags
.equ        RW_______,      0600        // mode

    .data

szFileIn:       .asciz      "input.txt"     // file name
szFileOut:      .asciz      "output.txt"    // file name
iFD1:           .byte       0               // (FD)
iFD2:           .byte       0               // (FD)

headPtr:    .quad       0
tailPtr:    .quad       0

strTest:        .asciz      "Hello There"

    .text

_start:
    ldr     x0,=strTest
    bl      String_copy         // "Hello There" - must copy because x0 must be dyn alloc (append_line_feed frees passed in string)
    
    bl      append_line_feed    // "Hello There\n"

    ldr     x1,=headPtr
    ldr     x2,=tailPtr
    bl      insert_into         // insert "Hello There\n"   Note: insert_into also frees passed in string

    ldr     x0,=headPtr
    bl      print_list          // print nodes - only prints "Hello There\n"

    ldr     x0,=0
    ldr     x1,=headPtr
    bl      search_for          // return address of first node

    ldr     x0,[x0]
    bl      putstring           // prints "Hello There\n"

    ldr     x0,=headPtr
    bl      free_list           // frees nodes

    mov     x0,#0               // end sequence
    mov     X8,#93
    svc     0

    .end

