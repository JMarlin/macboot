*-----------------------------------------------------------
* Title         : Tutorial 1 for EASy68k
* Written by    : Chuck Kelly
* Date Created  : Feb-05-2003
* Dec-25-2012 by CK, Uses SIMHALT
* Description   : A program that adds two bytes, two words, two long words
*                 then displays the results. Demonstrates use of trap #15 for display
*                 and subroutine.
* 
* This program is public domain.
*
* Note! asterisk '*' in first column for comments
*-----------------------------------------------------------
* labels must start in first column

START   ORG $1000       the program will load into address $1000
    
    move.b  #3,d1       put 3 in low byte of data register D1
    add.b   #5,d1       add 5 to low byte of data register D1
* D1 contains 8 in its low byte

    move.w  #512,d2     put 512 in low word of data register D2
    add.w   d1,d2       add contents of low word in D1 to D2
    move.w  d2,sum2     write low word of D2 to memory location sum2
* D2 contains 520 in its low word (16 bits)

    move.l  #67500,d3   put 67,500 in data register D3
    add.w   sum2,d3     add contents of sum2 to D3
* D3 contains 68020 as a 32 bit number

* Display the results in D1
    move    #14,d0      load task number into D0
* task number 14 is used to display the NULL terminated string at (A1) without new line
* see Help/Simulator IO for a complete list of task numbers
    lea     textD1,a1   load address of string to display into A1
    trap    #15         trap #15 activates input/output task

    move    #3,d0       task number 3 into D0
* task number 3 is used to display the contents of D1.L as a number
    trap    #15         display number in D1.l

    bsr     newLine

* Display D2
    move    #14,d0      task number 14 (display null string)
    lea     textD2,a1   address of string
    trap    #15         display it
    move.l  d2,d1       put d2 into d1
    move    #3,d0       task number 3 (display number in D0)
    trap    #15         display it
    bsr     newLine

* Display D3
    move    #14,d0      task number 14 (display null string)
    lea     textD3,a1   address of string
    trap    #15         display it
    move.l  d3,d1       put d3 into d1
    move    #3,d0       task number 3 (display number in D0)
    trap    #15         display it
    bsr     newLine

* Display end message
    move    #14,d0      task number 14 (display null string)
    lea     textEnd,a1  address of string
    trap    #15         display it
    
* Stop execution
    SIMHALT

    
*------------------------------------
* Subroutine to display Carriage Return and Line Feed
newLine movem.l d0/a1,-(a7) push d0 & a1
    move    #14,d0      task number into D0
    lea     crlf,a1     address of string
    trap    #15         display return, linefeed
    movem.l (a7)+,d0/a1 restore d0 & a1
    rts                 return


*------------------------------------
* Variable storage and strings
* ds (define storage) is used to reserve memory for variables
* dc (define constant) is used to place data in memory
** HERES WHERE THE MACFLOP WORK STARTS **
bbID            ds.w $4C4B *Macintosh volume magic number
bbEntry         ds.l $60000086 *68k instruction to jump to the code following this header
bbVersion       ds.w
bbPageFlags     ds.w
bbSysName       ds.b '               ' *string15
bbShellName     ds.b '               ' *string15
bbDbg1Name      ds.b '               ' *string15
bbDbg2Name      ds.b '               ' *string15
bbScreenName    ds.b '               ' *string15
bbHelloName     ds.b '               ' *string15
bbScrapName     ds.b '               ' *string15
bbCntFCBs       ds.w
bbCntEvts       ds.w
bb128KSHeap     ds.l
bb256KSHeap     ds.l
bbSysHeapSize   ds.l
filler:         ds.w
bbSysHeapExtra: ds.w
bbSysHeapFract: ds.l

    END     START   end of program with start address specified




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
