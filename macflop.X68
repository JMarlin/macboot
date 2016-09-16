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

*START   ORG $0       the program will load into address $1000
 ** HERES WHERE THE MACFLOP WORK STARTS **
*bbID            dc.w $4C4B *Macintosh volume magic number
*bbEntry         dc.l $60000086 *68k instruction to jump to the code following this header
*bbVersion       dc.w
*bbPageFlags     dc.w
*bbSysName       dc.b 'Noth'
*                dc.b 'ing'
*                dc.b $0,$0,$0,$0,$0,$0,$0,$0
*bbShellName     dc.b 'Noth'
*                dc.b 'ing'
*                dc.b $0,$0,$0,$0,$0,$0,$0,$0
*bbDbg1Name      dc.b 'Noth'
*                dc.b 'ing'
*                dc.b $0,$0,$0,$0,$0,$0,$0,$0
*bbDbg2Name      dc.b 'Noth'
*                dc.b 'ing'
*                dc.b $0,$0,$0,$0,$0,$0,$0,$0
*bbScreenName    dc.b 'Noth'
*                dc.b 'ing'
*                dc.b $0,$0,$0,$0,$0,$0,$0,$0
*bbHelloName     dc.b 'Noth'
*                dc.b 'ing'
*                dc.b $0,$0,$0,$0,$0,$0,$0,$0
*bbScrapName     dc.b 'Noth'
*                dc.b 'ing'
*                dc.b $0,$0,$0,$0,$0,$0,$0,$0
*bbCntFCBs       dc.w
*bbCntEvts       dc.w
*bb128KSHeap     dc.l
*bb256KSHeap     dc.l
*bbSysHeapSize   dc.l
*filler:         dc.w *It seems these are ignores on the 7.0.1 floppies
*bbSysHeapExtra: dc.w
*bbSysHeapFract: dc.l

BOOTCODE ORG $8A

screen_base_glob EQU $00000824
screen_width_glob EQU $00000106
TheGDevice EQU $00000CC8
MainDevice EQU $000008A4
gdPMap_offset EQU 22
pmBaseAddr_offset EQU 0
pmRowBytes_offset EQU 4
pmBounds_offset EQU 6
pmVersion_offset EQU 14
pmPackType_offset EQU 16
pmPackSize_offset EQU 18
pmHRes_offset EQU 22
pmVRes_offset EQU 26
pmPixelType_offset EQU 30 *PixelType is 0 for indexed mode, 16 for direct color
pmPixelSize_offset EQU 32 *For indexed: 1,2,4 or 8. For direct, 16 or 32 (rgb is 5-bit in 16 and 8-bit in 32)
pmCmpCount_offset EQU 34
pmCmpSize_offset EQU 36
pmPlaneBytes_offset EQU 38
pmTable_offset EQU 42
pmReserved_offset EQU 46
rTop_offset EQU 0
rLeft_offset EQU 2
rBottom_offset EQU 4
rRight_offset EQU 6

BII_BREAK_OP EQU $7101

     *GET SCREEN BASE AND DIMENSIONS
     *This could all probably be done way easier using offset addressing
     *to directly load struct entries from the struct pointer
     *Dereference the MainDevice pointer
     move.l MainDevice,a0     
     
          dc.w BII_BREAK_OP
     
     *Increase the pointer to point at the gdPMap entry
     add #gdPMap_offset,a0     
     *Load the #gdPMap pointer value
     move.l (a0),a0     *This is some crazy high number at the top of memory for some reason, which causes the load below to crash
                        *I'm clearly not dereferencing things correctly, because whether I do this starting with the value in TheGDevice
                        *OR MainDevice, I get the exact same values. If both of those variables contain the same info, that definitely
                        *means they're not junk and THAT means that I'm definitely doing something wrong
                        *(both return the pointer as 211c for the quadra rom I'm using)
     *Set a1 to the screen base addr
     move.l a0,a1
     add #pmBaseAddr_offset,a1
     move.l (a1),a1    
     *Set a2 to the bounds rect address
     move.l a0,a2
     add #pmBounds_offset,a2
     *Set a3 to the address of the bound top
     move.l a2,a3
     add #rTop_offset,a3
     *Load the top value into d0
     eor d0,d0
     move.w (a3),d0
     *Set a3 to the address of the bound bottom
     move.l a2,a3
     add #rBottom_offset,a3
     *Load the bottom value into d1
     eor d1,d1
     move.w (a3),d1
     *Subtract d0 from d1(bottom-top) and add one to get height in d0
     sub.w d0,d1
     add.w #1,d1
     move.w d1,d0
     *Set a3 to the address of the bound left 
     move.l a2,a3
     add #rLeft_offset,a3
     *Load the left value into d1
     move.w (a3),d1
     *Set a3 to the address of the bound right
     move.l a2,a3
     add #rRight_offset,a3
     *Load the right value into d2
     eor d2,d2
     move.w (a3),d2
     *Subtract d1 from d2 (right-left) and add one to get width in d1
     sub.w d1,d2
     add.w #1,d2
     move.w d2,d1

     *GET SCREEN PIXEL FORMAT INFO
     *Set a2 to the PixelType address
     move.l a0,a2
     add #pmPixelType_offset,a2
     *Load the PixelType into d2
     move.w (a2),d2
     *Set a2 to the PixelSize address
     move.l a0,a2
     add #pmPixelSize_offset,a2
     *Load the PixelSize into d3
     move.w (a2),d3
     
     *Now a0=gdPMap address of the screen (TheGDevice)
     *    a1=screen buff address
     *    d0=screen height (pixels)
     *    d1=screen width  (pixels)
     *    d2=screen pixel type (0=indexed 16=direct)
     *    d3=screen pixel size (indexed=1,2,4,8bits direct=16,32bits)
     
     dc.w BII_BREAK_OP
     
     *CALCULATE TOTAL SIZE OF SCREEN BUFFER
     move.l d1,d4
     mulu.w d0,d4
     
     move.l #0,d5 *size counter
     *now d4=screen size in pixels
     
     *CALCULATE NUMBER OF LONGWORDS IN SCREEN BUFFER
     cmp.w #32,d3
     beq.s draw_loop
     lsr.l #1,d4 *divide d4 by 2
     cmp.w #16,d3
     beq.s draw_loop
     lsr.l #1,d4 *divide d4 by 2
     cmp.w #8,d3
     beq.s draw_loop
     lsr.l #1,d4 *divide d4 by 2
     cmp.w #4,d3
     beq.s draw_loop
     lsr.l #1,d4 *divide d4 by 2
     cmp.w #2,d3
     beq.s draw_loop
     lsr.l #1,d4 *divide d4 by 2
     
     *FILL THE SCREEN TO ZERO (whatever that may be color-wise)
draw_loop
     
     move.l #0,(a1)+
     add.l #1,d5
     cmp.l d5,d4 *check to see if we've hit the end of the row
     beq.s here
     bra.s draw_loop
     
here bra.s here

*Looks like we're going to want to check out the toolbox function GetMainDevice which should supply us
*with a GDevice handle from whence we can discern some details about the video device
*Either way, I've found that the most useful information about screen details seems to be in
*Quickdraw Imaging chapter 5
*UPDATE: According to chapter 5, the pointer to the currently active GDevice is stored in the global
*variable TheGDevice, which, according to the almanac, is at 0CC8. So what we need to do to get our 
*screen information is get the PixMap for the handle held in (*TheGDevice).gdPMap, which is the PixMap
*struct representing the details of the GDevice (should have color format, dimensions, etc) see page 5-15 of imaging


    END     BOOTCODE   end of program with start address specified





