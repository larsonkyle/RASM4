  .global findSubstring

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
