  .global Node_Count

  .data
strNodes: .skip 21

  .text

/*
  - Node_Count: Counts the amount of nodes currently active in a linked list and outputs the count to the terminal
    
    Parameters:
      - Nothing: headptr is global
    Returns:
      - Nothing: Results outputed to the terminal
*/

Node_Count:
  //Save Registers
  str  LR,[SP,#-16]!    // push lr to stack
  
  //Load Head pointer
  ldr  x0,=headPtr      // load head pointer
  ldr  x0,[x0]          // Dereference head pointer

  //Initialize Counter to 0
  mov  x1,#0            // set counter to 0
  
  //Check if head is empty
  cmp  x0,#0            // check if 0
  beq  Node_Return      // if 0 then return

 
Node_Loop:
  add  x0,x0,#8         // MANUALLY add 8 to the address cause apparently postincrementing the address in the previous line is illegal to the entire world including the assembler and valgrind !!!!
  ldr  x0,[x0]          // load the nextPtr

  add  x1,x1,#1          // increment counter
 
  cmp  x0,#0            // check if 0
  beq  Node_Return      // if 0 then return

  b    Node_Loop        // repeat algorithm

Node_Return:
  mov  x0,x1            // move counter to x0
  ldr  x1,=strNodes     // load buffer address to store converted counter to ascii
  bl   int64asc         // convert counter to ascii

  ldr  x0,=strNodes     // load strNodes
  bl   putstring        // output # of nodes

  ldr  LR,[SP],#16      // pop LR

  ret  LR               // return to caller
