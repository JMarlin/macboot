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
BII_BREAK_OP EQU $7101

*we're going to try just dumping some junk into the screen buffer

     move.l screen_base_glob,a0
     move.l #0,d2
     move.w screen_width_glob,d2
     *We assume a 1bpp display here and will be writing a longword at a time.
     *At 1bpp, a longword = 32 pixels. Therefore, we must divide our screen
     *width by 32 to get 'screen longword width'. 32 = 2^5, so we can just rsh 5
     lsr.l #2,d2
     move.l #0,d0 *width counter
     move.l #0,d1 *height counter
     move.l #$FF00FF00,d3 *fill 'color'
     *dc.w BII_BREAK_OP *Special basilisk II op for triggering a halt and reg dump
     *we could do the bit below in a more straightforward fashion if we just calculated
     *the line width in longwords multiplied by 50 (the height we want), but FUCK THAT
top
     move.l d3,(a0)+
     *not.l d3
     add.l #1,d0
     cmp.l d2,d0 *check to see if we've hit the end of the row
     beq.s next_row
     bra.s top
next_row
     *not.l d3 *invert the row color
     move.l #0,d0 *clear the column counter
     add.l #1,d1 *increase the row counter
     cmp.l #50,d1
     beq.s here
     bra.s top

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




