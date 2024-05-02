    .global _start
    .global headPtr
    .global tailPtr
    .global iFD

.equ        DFD,            -100           // directory file descriptor (DFD)
.equ        READ,           0000           // read and do not create file
.equ        WRITE,         01101           // write and create file
.equ        RW_______,      0600       	   // mode (permissions)
.equ        menuBufSize,      21

    .data
szFileIn:       .skip      21              // input  file name
szFileOut:      .skip      21              // output file name
iFD:            .byte       0              // file descriptor (fd)

headPtr:        .quad       0              // head pointer
tailPtr:        .quad       0              // tail pointer

menuBuf:        .skip       21             // menuBuf of the menu input (only a single digit + null)

//Menu Prompts
strHeader:      .asciz      "Contributers: Kyle Larson & Andrew Maciborski\nProject     : RASM4\nClass       : CS3B\nProfessor   : Dr.Barnett\nGithub      : https://github.com/larsonkyle/RASM4\n\n\n\n"

strMenu1:       .asciz      "		 RASM4 TEXT EDITOR\n"
strMenuBytes1:  .asciz      "        Data Structure Heap Memory Consumption: "
strMenuBytes2:  .asciz      " bytes\n"
strMenuNodes:   .asciz      "        Number of Nodes: "
strMenu2:       .asciz      "<1> View all strings\n\n<2> Add string\n    <a> from Keyboard\n    <b> from File.\n\n<3> Delete string.\n\n<4> Edit string.\n\n<5> String search.\n\n<6> Save File (output.txt)\n\n<7> Quit\n"
strMenu3:       .asciz      "\n\n<2> Add String\n    <a> from Keyboard\n    <b> from File.\n"

strPause:       .asciz      "\n		PRESS A KEY TO CONTINUE: "

strFilePrompt:  .asciz      "Enter File name: "
strFileError:   .asciz      "\nERROR: File Does Not Exist.\n"

chLF:           .byte       0xA

    .text

main: //For GDB to know where the program starts
_start:
    b       clearScreen		// start program with clear screen

start_program:
    //Output Header
    ldr     x0,=strHeader	// load header
    bl      putstring		// output header

// get menu number and branch to that option
 
    ldr     x0,=strMenu1	// load header
    bl      putstring		// output header
    ldr     x0,=strMenuBytes1	// load mem count header
    bl      putstring		// output mem count header

// ---
    bl      Mem_Count 		// branch to mem count fnct
// ---

    ldr     x0,=strMenuBytes2	// output word bytes
    bl      putstring		// out word

    ldr     x0,=strMenuNodes	// load node count header
    bl      putstring		// output message

// ---
    bl      Node_Count		// branch to node counter fnct
// ---

    ldr     x0,=chLF		// load new line
    bl      putch		// output new line

    ldr     x0,=strMenu2	// load menu options
    bl      putstring		// output menu options

    ldr     x0,=menuBuf		// load input buffer
    ldr     x1,=menuBufSize	// load input buffer size
    bl      getstring		// call getstring

    ldr     x0,=menuBuf		// load menu buffer
    ldrb    w0,[x0]    		// load user input

    cmp     x0,#'1'		// check ONLY for options 1-7
    beq     option_1		// branch to appropriate option

    cmp     x0,#'2'		// check ONLY for options 1-7
    beq     option_2		// branch to appropriate option

    cmp     x0,#'3'		// check ONLY for options 1-7
    beq     option_3		// branch to appropriate option

    cmp     x0,#'4'		// check ONLY for options 1-7
    beq     option_4		// branch to appropriate option

    cmp     x0,#'5'		// check ONLY for options 1-7
    beq     option_5		// branch to appropriate option

    cmp     x0,#'6'		// check ONLY for options 1-7
    beq     option_6		// branch to appropriate option

    cmp     x0,#'7'		// check ONLY for options 1-7
    beq     option_7		// branch to appropriate option

    b       _start  		// if not proper input, repeat

// print list
//***********************************************************************************************************
option_1:
    bl      print_list		// branch to print list fnct
    
    ldr     x0,=strPause	// output pause for input msg
    bl      putstring		// call putstring
    
    ldr     x0,=menuBuf		// load menu buffer
    ldr     x1,=menuBufSize	// load buffer size
    bl      getstring		// call getstring

    b   clearScreen 		// branch to clear screen and 


// input to end of list
//********************************************
option_2:
    ldr     x0,=strMenu3	// load sub options
    bl      putstring		// output sub options

    ldr     x0,=menuBuf		// load input buffer
    ldr     x1,=menuBufSize	// load size of input buffer
    bl      getstring		// call getstring
		
    ldr     x0,=menuBuf		// load menu buffer 
    ldrb    w0,[x0]  		// load user input

    cmp     x0,#'a'		// check for only a input
    beq     option_2a		// branch to appropriate option

    cmp     x0,#'b'		// check for only b input
    beq     option_2b		// branch to appropriate option

    b   clearScreen		// clear screen and restart menu


// keyboard
//*********************
option_2a:
    bl      insert_into_kbd	// branch to get keyboard function

    b   clearScreen		// clear screen and restart menu

// file
//*********************
option_2b:
    //EC:   LET USER CHOOSE OUTPUT NAME
    ldr     x0,=strFilePrompt	// load file name prompt
    bl      putstring		// call putstring 

    ldr     x0,=szFileIn	// load file name for output
    ldr     x1,=menuBufSize	// load input buffer size
    bl      getstring		// call getstring
    // ---

    mov     x0,#DFD         	// load DFD into x0              
    ldr     x1,=szFileIn    	// load file name into x1
    mov     x2,#READ        	// load flags into x2
    mov     x3,#RW_______   	// load mode into x3

    mov     x8,#56          	// openat
    svc     0               	// system call to openat

    //EC:   Handle error for if file DNE
    cmp     x0,#0               // check if file exists
    blt     File_Error          // if file DNE, branch to error message and restart menu

    ldr     x1,=iFD         	// load FD into x1
    strb    w0,[x1]         	// store returned FD value into FD

    bl      insert_into_file    // branch to load file into list fnct

    ldr     x0,=iFD         	// load FD into x0
    ldrb    w0,[x0]         	// load value of FD into w0
    mov     x8,#57          	// close
    svc     0               	// system call to close

    b   clearScreen		// clear screen and restart menu

// delete node given #
//********************************************
option_3:
    bl      delete_node		// branch to delete_node

    b   clearScreen		// clear screen and restart menu

// edit string in node given #
//********************************************
option_4:
    bl      edit_string		// branch to edit_string function

    b   clearScreen		// clear screen and restart menu

// search strings based on given substring
//********************************************
option_5:
    bl      print_str_sub	// branch to find substring fnct

    ldr     x0,=strPause	// load menu pause message
    bl      putstring		// call putstring
    
    ldr     x0,=menuBuf		// load input buff
    ldr     x1,=menuBufSize	// load sizeof input buff
    bl      getstring   	// call getstring

    b   clearScreen		// clear screen and restart menu

// write strings to output file
//********************************************
option_6:
    //EC:   LET USER CHOOSE OUTPUT NAME
    ldr     x0,=strFilePrompt	// load file name prompt
    bl      putstring		// call putstring

    ldr     x0,=szFileOut	// load file name for output
    ldr     x1,=menuBufSize	// load input buffer size
    bl      getstring		// call getstring
    // ---

    mov     x0,#DFD         	// load DFD into x0              
    ldr     x1,=szFileOut   	// load file name into x1
    mov     x2,#WRITE       	// load flags into x2
    mov     x3,#RW_______   	// load mode into x3

    mov     x8,#56          	// openat
    svc     0               	// system call to openat

    ldr     x1,=iFD         	// load FD into x1
    strb    w0,[x1]         	// store returned FD value into FD

    bl      save_list		// branch to save_list fnct

    ldr     x0,=iFD         	// load FD into x0
    ldrb    w0,[x0]         	// load value of FD into w0
    mov     x8,#57          	// close
    svc     0               	// system call to close

    b   clearScreen		// clear screen and restart menu

// free list and exit program
//********************************************
option_7:
    bl      free_list		// branch to free list

    mov     x0,#0               // end sequence
    mov     X8,#93		// end sequence
    svc     0			// end sequence

File_Error:
    ldr     x0,=strFileError	// output error message
    bl      putstring           // call putstring

    ldr     x0,=strPause	// load menu pause message
    bl      putstring		// call putstring
    
    ldr     x0,=menuBuf		// load input buff
    ldr     x1,=menuBufSize	// load sizeof input buff
    bl      getstring   	// call getstring

    b   clearScreen		// clear screen and restart menu

clearScreen:
    mov X19,#0			// initialize counter

clearScreen_loop:
  //Just print a million new lines to clear screen
  ldr X0,=chLF			// load new line
  bl  putch			// output new line

  add X19,X19,#1		// increment counter
  
  cmp X19, #46   		// 45 newlines to be exact
  blt clearScreen_loop		// if less than 45 repeat

  b   start_program		// restart program

  .end
