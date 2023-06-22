; CHIP DETECT
;
; A simple program to detect all main C64
; chips (VIC, SID and the two CIAs).
; The SID routine is an adaptation of a known
; method.
; The VIC routine comes from my VSYNC/HSYNC
; raster routine.
; The CIA detection comes after studying 
; the documentation and understanding
; that the newer CIAs respond one cpu cycle before
; the old ones when generating an IRQ using timers.
;
; By Zibri

PRINT=$99
DIM=$86
EQUALS=$B2
PEEK=$C2
BY=$AC
PLUS=$AA
REM=$8F
SYS=$9E


*       = $0801
        .word (+), 10  ;pointer, line number
        .null PRINT,'"C64 CHIP DETECT BY ZIBRI.":',PRINT,":",DIM,"A$(4)"
+       .word (+), 20  ;pointer, line number
        .null "A$(0)",EQUALS,'"6567":',"A$(1)",EQUALS,'"8562":',"A$(2)",EQUALS,'"6569":',"A$(3)",EQUALS,'"8565"'
+       .word (+), 20  ;pointer, line number
        .null SYS,format("%d:", VICD),REM," DETECT VIC"
+       .word (+), 30  ;pointer, line number
        .null PRINT, '" VIC CHIP: ";',"A$(",PEEK,"(2))"
+       .word (+), 40  ;pointer, line number
        .null SYS,format("%d:", SIDD),REM," DETECT VIC"
+       .word (+), 50  ;pointer, line number
        .null PRINT, '" SID CHIP:";',PEEK,"(2)",BY,"1999",PLUS,"6581"
+       .word (+), 60  ;pointer, line number
        .null DIM,"B$(2)"
+       .word (+), 70  ;pointer, line number
        .null "B$(0)",EQUALS,'"6526":',"B$(1)",EQUALS,'"8521"'
+       .word (+), 80  ;pointer, line number
        .null SYS,format("%d:", CIA1D),REM," DETECT CIA1"
+       .word (+), 90  ;pointer, line number
        .null PRINT, '"CIA1 CHIP: ";B$(',PEEK,"(2))"
+       .word (+), 100  ;pointer, line number
        .null SYS,format("%d:", CIA2D),REM," DETECT CIA2"
+       .word (+), 110  ;pointer, line number
        .null PRINT, '"CIA2 CHIP: ";B$(',PEEK,"(2))"
+       .byte 0,0


VICD
SEI
LDA $d012
-
CMP $D012
BEQ -             ; wait for the start of the next scaline.

DEC $DC03         ; trigger the light pen
INC $DC03         ; restore port B to input
LDA $D013         ; read the raster X 
AND #$1           ; EVEN? 656x. ODD? 856x
STA $2
LDA $D012
BNE *-3
LDA $D019
AND #$1
ASL A
ORA $2
STA $2
CLI
RTS

SIDD
SEI
LDX #$fF
CPX $D012
BNE *-3
STX $D412
STX $D40E
STX $D40F
LDX #$20          ; Sawtooth Waveform.
STX $D412
LDA $D41B
AND #$1           ; First amplitude played.
EOR #$1           ; ODD? 6581. EVEN? 8580.
STA $2
CLI
RTS

.align $100
CIA1D
SEI
LDA #$A           ; Create a 10 cpu cycle timer.
STA $DC06
LDA #$00
STA $DC07
LDA #<MY
STA $FFFE
LDA #>MY
STA $FFFF         ; Point NMI to MY routine
DEC $1
DEC $1            ; Disable KERNEL ROM
LDA #$11
STA $DC0F         ; Reset Timer B
LDA #$82
STA $DC0D         ; Start Timer B
CLI
-
NOP
NOP
NOP    ; 8521
NOP    ; 6526
RTS

MY
INC $1
INC $1
LDA $DC06
AND #$1
EOR #$1
STA $2
JSR $FD15
JSR $FDA3
LDA $DC0D
LDA #$FF
STA $DC06
STA $DC07
RTI

CIA2D
SEI
LDA #$A
STA $DD06
LDA #$00
STA $DD07
LDA #<MY2
STA $0318
LDA #>MY2
STA $0319
LDA #$11
STA $DD0F
LDA #$82
STA $DD0D
CLI
-
NOP
NOP
NOP    ; 8520
NOP    ; 6526
RTS

MY2
LDA $DD06
LSR A
STA $2
JSR $FD15
JSR $FDA3
LDA $DD0D
LDA #$FF
STA $DD06
STA $DD07
RTI
