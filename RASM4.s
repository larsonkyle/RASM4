    .global _start

.equ        DFD,            -100        // DFD
.equ        READ,           0000        // flags
.equ        WRITE,          0001        // flags
.equ        RW_______,      0600        // mode

    .data

szFileIn:       .asciz      "input.txt"      // file name
szFileOut:      .asciz      "output.txt"     // file name
iFD1:            .byte       0               // (FD)
iFD2:            .byte       0               // (FD)

    .text

_start:




    .end

