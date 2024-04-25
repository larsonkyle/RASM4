    .global _start
    .global headPtr
    .global tailPtr

.equ        DFD,            -100        // directory file descriptor (DFD)
.equ        READ,           0000        // read and do not create file
.equ        WRITE,          0101        // write and create file
.equ        RW_______,      0600        // mode (permissions)
.equ        bufSize,        21

    .data

szFileIn:       .asciz      "input.txt"     // input file name
szFileOut:      .asciz      "output.txt"    // file name
iFD:            .byte       0              // file descriptor (fd)

headPtr:        .quad       0           // head pointer
tailPtr:        .quad       0           // tail pointer

buffer:         .skip       21           // buffer of the menu input (only a single digit + null)

strMenu1:       .asciz      "Enter menu num (1,2,3,4,5,6,7): "
strMenu2:       .asciz      "Enter submenu num (a, b): "

    .text

_start:
// get menu number and branch to that option
    ldr     x0,=strMenu1
    bl      putstring

    ldr     x0,=buffer
    ldr     x1,=bufSize
    bl      getstring

    ldr     x0,=buffer
    ldrb    w0,[x0]    

    cmp     x0,#'1'
    beq     option_1

    cmp     x0,#'2'
    beq     option_2

    cmp     x0,#'3'
    beq     option_3

    cmp     x0,#'4'
    beq     option_4

    cmp     x0,#'5'
    beq     option_5

    cmp     x0,#'6'
    beq     option_6

    cmp     x0,#'7'
    beq     option_7

    b       _start  

// print list
//***********************************************************************************************************
option_1:
    ldr     x0,=headPtr
    bl      print_list

    b       _start

// input to end of list
//********************************************
option_2:
    ldr     x0,=strMenu2
    bl      putstring

    ldr     x0,=buffer
    ldr     x1,=bufSize
    bl      getstring

    ldr     x0,=buffer
    ldrb    w0,[x0]  

    cmp     x0,#'a'
    beq     option_2a

    cmp     x0,#'b'
    beq     option_2b

    b       _start

// keyboard
//*********************
option_2a:
    ldr     x0,=headPtr
    ldr     x1,=tailPtr
    bl      insert_into_kbd

    b       _start

// file
//*********************
option_2b:
    mov     x0,#DFD         // load DFD into x0              
    ldr     x1,=szFileIn    // load file name into x1
    mov     x2,#READ        // load flags into x2
    mov     x3,#RW_______   // load mode into x3

    mov     x8,#56          // openat
    svc     0               // system call to openat

    ldr     x1,=iFD         // load FD into x1
    strb    w0,[x1]         // store returned FD value into FD

    ldr     x1,=headPtr
    ldr     x2,=tailPtr
    bl      insert_into_file

    ldr     x0,=iFD         // load FD into x0
    ldrb    w0,[x0]         // load value of FD into w0
    mov     x8,#57          // close
    svc     0               // system call to close

    b       _start  

// delete node given #
//********************************************
option_3:
    bl      delete_node

    b       _start

// edit string in node given #
//********************************************
option_4:

    b       _start

// search strings based on given substring
//********************************************
option_5:

    b       _start

// write strings to output file
//********************************************
option_6:

    b       _start

// free list and exit program
//********************************************
option_7:
    ldr     x0,=headPtr
    bl      free_list

    mov     x0,#0               // end sequence
    mov     X8,#93
    svc     0

    .end
