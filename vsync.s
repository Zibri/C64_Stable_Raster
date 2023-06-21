; VSYNC example
;
; VSYNC routine will always SYNC to
; the first cycle of the first SCANLINE
; at the very top of the screen
; (avoid badlines)
;
; By Zibri


                * =  $801
                .BYTE $B, 8, $E7, $07 , $9E, $32, $30, $36, $31, 0, 0, 0

START

JSR $E5A0         ; VIC reset (only for testing)
SEI
LDA #<START
STA $318
LDA #>START
STA $319          ; this is for testing: pressing RESTORE re-runs the program.

LDA #$00
STA $DC03         ; this is redundant because the default is 00.
STA ZZ+1


JSR VSYNC         ; after this we are at scaline 0 first cycle.
LDA #$0b
STA $D011         ; this is needed only during the HSYNC routine.

                  ; just some vertical bars to check the horizontal sync
ZZ
LDA #$00          ; after this we are at cycle 9 of scanline
STA $D020
INC $D020
INC $D020
INC $D020
INC $D020
INC $D020
INC $D020
INC $D020
CPX #$9B
BNE W4J
EOR #$08
STA ZZ+1
LDX #$00
JMP ZZ
W4J
INX
NOP
.byte $04,$ea ;3
JMP ZZ

VSYNC:            ; SYNC to scanline 0 cycle 1

LDA #$FF
-
CMP $D012
BNE -
LDA #$35          ; wait for scanline before the last one
-
CMP $D012
BNE -

JSR HSYNC

JSR +
JSR +
JSR +
JSR +
JSR +
NOP
NOP
NOP
NOP
.BYTE $44,$5A

RTS
 
HSYNC:            ; This routine will always get you to cycle 50 (44 at RTS) of a scanline

LDA $d012
-
CMP $D012
BEQ -             ; wait for the start of the next scaline.

DEC $DC03         ; trigger the light pen
INC $DC03         ; restore port B to input
LDA $D013         ; read the raster X position
CLC
CMP #$0B          ; this is just sheer magic :D
ADC #$11          ; this is just sheer magic :D
LSR A
LSR A
STA SS+1          ; A will be: 0-6
SS:
BVC *
; the following 1 cycle clock slide does not affect any registers nor the cpu status.

.BYTE $80
.BYTE $80, $80
.BYTE $80, $80
.BYTE $44,$5A
+
RTS
