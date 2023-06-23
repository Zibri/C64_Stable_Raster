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
LDA #<NEXT
STA $318
LDA #>NEXT
STA $319          ; this is for testing: pressing RESTORE re-runs the program.

LDA #$00
STA $DC03         ; this is redundant because the default is 00.
P1
STA ZZ+1
TAX


JSR VSYNC         ; after this we are at scaline 0 first cycle.
P2
LDA #$00
STA $D011,X       ; this is just for the color bars (+waste 1 cycle)

                  ; just some vertical bars to check the horizontal sync

ZZ
LDY #$00          ; after this we are at cycle 9 of scanline
STY $D020
INY
STY $D020
INY
STY $D020
INY
STY $D020
INY
STY $D020
INY
STY $D020
INY
STY $D020
INY
STY $D020
SP
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

VSYNC:            ; SYNC to scanline 0 cycle 0

LDA #$FF
-
CMP $D012
BNE -
SM
LDA #$35          ; wait for scanline before the last one
-
CMP $D012
BNE -

JMP HSYNC

JSR + 
JSR +
JSR +
JSR +
JSR +
;NOP
.byte $04,$ea ;3


;RTS
 
HSYNC:            ; This routine will always get you to cycle 0 (58 at RTS) of a scanline

LDA $d012
-
CMP $D012
BEQ -             ; wait for the start of the next scaline.

DEC $DC03         ; trigger the light pen
INC $DC03         ; restore port B to input
LDA $D013         ; read the raster X position
STA $2
LSR A
LDA $2
ADC #$00          ; if carry is set this is a 8565 i f it's clear it's a 6569
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
.BYTE $80, $80
.BYTE $44,$5A
.BYTE $44,$5A
+
RTS

NEXT
LDA #$08
STA P2+1
LDA #$26
STA SP+1
LDA #$1f
STA SM+1
LDA #$0C
STA P1
JMP START
