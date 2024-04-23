    .global _start

.equ        DFD,            -100        // DFD
.equ        READ,           0100        // flags
.equ        WRITE,          0101        // flags
.equ        RW_______,      0600        // mode

    .data

szFileIn:       .asciz      "input.txt"     // file name
szFileOut:      .asciz      "output.txt"    // file name
iFD1:           .byte       0               // (FD)
iFD2:           .byte       0               // (FD)

headPtr:        .quad       0
tailPtr:        .quad       0

menuBuf:        .skip       2

strMenu1:       .asciz      "Enter menu num: "
strMenu2:       .asciz      "Enter submenu num: "

    .text

_start:
    // openat
    mov     x0,#DFD         // load DFD into x0              
    ldr     x1,=szFileIn    // load file name into x1
    mov     x2,#READ        // load flags into x2
    mov     x3,#RW_______   // load mode into x3

    mov     x8,#56          // openat
    svc     0               // system call to openat

    ldr     x1,=iFD1        // load FD into x1
    strb    w0,[x1]         // store returned FD value into FD

    // openat
    mov     x0,#DFD         // load DFD into x0              
    ldr     x1,=szFileOut   // load file name into x1
    mov     x2,#WRITE       // load flags into x2
    mov     x3,#RW_______   // load mode into x3

    mov     x8,#56          // openat
    svc     0               // system call to openat

    ldr     x1,=iFD2        // load FD into x1
    strb    w0,[x1]         // store returned FD value into FD

//************************************************************************************************
start_menu:
    ldr     x0,=strMenu1
    bl      putstring

    ldr     x0,=menuBuf
    mov     x1,#2
    bl      getstring

    ldr     x0,=menuBuf
    bl      ascint64

    cmp     x0,#1
    beq     option_1

    cmp     x0,#2
    beq     option_2

    cmp     x0,#3
    beq     option_3

    cmp     x0,#4
    beq     option_4

    cmp     x0,#5
    beq     option_5

    cmp     x0,#6
    beq     option_6

    cmp     x0,#7
    beq     option_7

    b       start_menu    

option_1:
    ldr     x0,=headPtr
    bl      print_list

    b       start_menu    

option_2:
    ldr     x0,=strMenu2
    bl      putstring

    ldr     x0,=menuBuf
    mov     x1,#2
    bl      getstring

    ldr     x0,=menuBuf
    bl      ascint64

    cmp     x0,#1
    beq     option_2a

    cmp     x0,#2
    beq     option_2b

    b       option_2

option_2a:
    ldr     x0,=headPtr
    ldr     x1,=tailPtr
    bl      insert_into_kbd

    b       start_menu    

option_2b:
    ldr     x0,=iFD1
    ldrb    w0,[x0]
    ldr     x1,=headPtr
    ldr     x2,=tailPtr
    bl      insert_into_file

    b       start_menu    

option_3:

    b       start_menu    

option_4:

    b       start_menu    

option_5:

    b       start_menu    

option_6:

    b       start_menu    

option_7:
    ldr     x0,=headPtr
    bl      free_list

    mov     x0,#0               // end sequence
    mov     X8,#93
    svc     0

    .end

