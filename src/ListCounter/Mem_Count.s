  .global Mem_Count

  .data
strMemory: .skip 21

  .text

/*
  - Mem_Count: Counts the amount of bytes of dynamic memory currently allocated
    
    Parameters:
      - Nothing: headptr is global
    Returns:
      - Nothing: Results outputed to the terminal
*/

Mem_Count:
  //Save Registers
  str  LR,[SP,#-16]!     // push lr to stack
  
  //Load Head pointer
  ldr  x10,=headPtr      // load head pointer
  ldr  x10,[x10]         // Dereference head pointer

  //Initialize Counter to 0
  mov  x11,#0            // set counter to 0
  
  //Check if head is empty
  cmp  x10,#0            // check if 0
  beq  Mem_Return        // if 0 then return

Mem_Loop:
  ldr  x0,[x10],#8       // load string variable then add 8 to x10 address

  bl   String_length     // get length of string
  add  x0,x0,#1          // add 1 for null char

  add  x11,x11,x0        // add string length+1 to counter
  add  x11,x11,#16       // add 16 for the node

  ldr  x10,[x10]         // load next node

  cmp  x10,#0            // check if end of list
  beq  Mem_Return        // if at end then return

  b    Mem_Loop          // repeat algorithm

Mem_Return:
  mov  x0,x11            // move counter to x0
  ldr  x1,=strMemory     // load buffer address to store converted counter to ascii
  bl   int64asc          // convert counter to ascii

  ldr  x0,=strMemory     // load strNodes
  bl   putstring         // output # of nodes

  ldr  LR,[SP],#16       // pop LR

  ret  LR                // return to caller
