  .global print_str_sub

  .equ MAX_LEN, 20

  .data

strPrompt:     .asciz "Search: "
strEmpty:      .asciz "[EMPTY]\n"
strSubstring:  .skip  21
strEC1:        .asciz "\n("
strEC2:        .asciz " hits in 1 file of 1 searched)\n"

strBuf:     .skip       21
numBuf:     .skip       21
chSP:       .byte       32
chFB:       .byte       91
chBB:       .byte       93

  .text

/*
starter code for print_str_sub (copy of print_list)

*/

print_str_sub:
  str     LR,[SP,#-16]!   // push LR to the stack

  ldr     x0,=headPtr     // load head pinter into x0
  ldr     x0,[x0]         // load head into x0

  //Check if list is empty
  cmp     x0,#0		  // check if head is 0
  beq     list_empty_sub  // if 0 branch to end

  //Prompt User for substring to search for  
  str     X0,[SP,#-16]!   // push Head node to the stack

  ldr     X0,=strPrompt   // Load User Prompt
  bl      putstring       // Output User Prompt

  ldr     X0,=strSubstring// Load buffer address
  ldr     X1,=MAX_LEN     // #define length of buffer address 
  bl      buf_clear       //branch to buf_clear

  ldr     X0,=strSubstring// Load buffer address
  ldr     X1,=MAX_LEN     // #define length of buffer address 
  bl      getstring       // Get user input

  bl      outputHits      // Output Notepad++ Results

  ldr     X0, [SP], #16   // pop head off the stack
  
  mov     x19,#0          // initialize index counter to 0
  
loop:
  cmp     x0,#0           // if head == null, there are no nodes, so
  beq     print_return_sub// end loop

  ldr     x20,[x0]        // load the string of the current node into x20
  ldr     x21,[x0,#8]     // load the next node into x21

  //call findSubstring
  mov     X0,X20          // Load String
  ldr     X1,=strSubstring// Load substring 
  bl      findSubstring   // Call find substring

  cmp     X0,#0           // If function returned 0, then not in string
  beq     notInSubstring  // If not in string, Do not output the string 
  
// --- IF BLOCK

  mov     x0,x19          // move index coutner to x0
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

  mov     x0,x20          // move the string of the current node into x0
  bl      putstring       // output this string

// --- IF BLOCK END
  notInSubstring:

  mov     x0,x21          // move next node into x0
  add     x19,x19,#1      // increment the index counter

  b       loop            // continue loop

print_return_sub:
  ldr     LR,[SP],#16     // pop LR off the stack
  ret                     // return to caller
 
list_empty_sub:
  ldr     x0,=strEmpty    // Print Empty Result if list empty
  bl      putstring       // Output String

  ldr     LR,[SP],#16     // pop LR off the stack
  ret                     // return to caller 



/*
  Parameters:
    - X0: Address of full string
  Return:
    - Outputs to the console the number of 'hits' found in the current linked list
*/

outputHits:
  str     LR,[SP,#-16]!   // push LR to the stack
 
  ldr     x0,=strEC1	  // Output start of hits
  bl      putstring	  // Output String
 
  ldr     x0,=headPtr     // load head pinter into x0
  ldr     x0,[x0]         // load head into x0

  mov     x19,#0          // initialize index counter to 0

loopHits:
  cmp     x0,#0           // if head == null, there are no nodes, so
  beq     hits_Return	  // end loop

  ldr     x20,[x0]        // load the string of the current node into x20
  ldr     x21,[x0,#8]     // load the next node into x21

  //call findSubstring
  mov     X0,X20          // Load String
  ldr     X1,=strSubstring// Load substring 
  bl      findSubstring   // Call find substring

  cmp     X0,#0           // If function returned 0, then not in string
  beq     notInList	  // If not in string, Do not output the string 
  
// --- IF BLOCK

  add     x19,x19,#1      // increment the index counter
  notInList:
// --- IF BLOCK END

  mov     x0,x21          // move next node into x0
  b       loopHits        // continue loop

hits_Return:
  mov     x0,x19
  ldr     x1,=strBuf
  bl      int64asc

  ldr     x0,=strBuf
  bl      putstring

  ldr     x0,=strEC2
  bl      putstring

  ldr     LR,[SP],#16     // pop LR off the stack
  ret                     // return to caller 

/*
  Parameters:
    - X0: Address of full string
    - X1: Address of Substring
  Return:
    - X0: Will return 1 or 0 whether substring is found or not
*/

findSubstring:
  str X30, [SP, #-16]!  //PUSH LR

//Check if susbtring is EMPTY
  str X0, [SP, #-16]!    //Store parameter 1
  str X1, [SP, #-16]!
  mov X0, X1             //Move substring param to X0
  bl  String_length      //Call substring
  cmp X0, #0             //If size 0, then exit with false
  beq findSubstringFalse //Branch to false result

//Reset Parameters
  ldr X1, [SP], #16
  ldr X0, [SP], #16

findSubstringLoop:
  //Set Starting positions for Next Loop
  // - X0 is current full string starting position
  // - X1 is substring starting position (Always reset back to the beginning)
  // - X2 copy of full string starting address to iterate through
  // - X3 copy of substring address to iterate through
  mov X2, X0
  mov X3, X1
  

  // - W4 is dereferenced byte of full string
  // - W5 is dereferenced byte of substring
  //while (W4 == W5)
  checkBytesLoop:
    //Load byte from full string, then substring. Ignore case for each byte
    ldrb W4, [X2], #1      //Load Char from full string
    ldrb W5, [X3], #1      //Load Char from Substring

    /*** IGNORE CASE ALGORITHM ***/

    //Check to see if substring byte is an uppercase char
    cmp W4, #0x41                      //check if W4 < 'A'
    blt findSubstringIgnoreCase1       //If less than, then not in range
    cmp W4, #0x5a                      //check if W4 > 'Z'
    bgt findSubstringIgnoreCase1       //If greater, then not in range
    //If it is in the range, convert to lower case. If not, skip
    add W4, W4, #32                    //if did not branch, then was in range,
                                       //So convert to lowercase
    findSubstringIgnoreCase1:    
 
    //Check to see if fullstring byte is an uppercase char
    cmp W5, #0x41                      //Check if W5 < 'A'
    blt findSubstringIgnoreCase2       //If less than, then not in range
    cmp W5, #0x5a                      //Check if W5 > 'Z'
    bgt findSubstringIgnoreCase2       //If greater than, then not in range
    //If it is in the range, convert to lower case. If not, skip
    add W5, W5, #32                    //If did not branch, then was in range,
                                       //So convert to lowercase 
    findSubstringIgnoreCase2:    
    
    //Check for null char in substring byte (IF NULL, RETURN TRUE)
    cmp W5, #0             //cmp substring byte to null
    beq findSubstringTrue  //if null, RETURN TRUE

    //Check for null char in full string byte (IF NULL, RETURN FALSE)
    cmp W4, #0             //cmp full string byte to null
    beq findSubstringFalse //If null, RETURN FALSE

    //Check if bytes are equal or not
    //If bytes aren't equal, then fall through the loop and continue to outer loop.
    cmp W4, W5             //Compare bytes
    beq checkBytesLoop     //if equal, REPEAT INNER ALGORITHM


  //Increment full string starting position
  add X0, X0, #1        //Add 1 to full string address
  b   findSubstringLoop //Repeat Outer Algorithm



findSubstringFalse:
  //Return False
  mov X0, #0         //Move 0 into

  ldr X30, [SP], #16 //Pop LR

  RET  LR            //Return LR

findSubstringTrue:
  //Return True
  mov X0, #1         //Move 1 into

  ldr X30, [SP], #16 //Pop LR

  RET  LR            //Return LR

  .end
