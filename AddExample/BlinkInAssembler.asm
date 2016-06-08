/*
 * BlinkInAssembler.asm
 * Author: chisaton
 */

.nolist
#include "m328pdef.inc"
.list

.def DELAY_OUTER_LOOP = r22

.def TEMP_REG = r20
.def DATA_REG = r21
.cseg

ldi TEMP_REG, 0xFF
out DDRB, TEMP_REG
ldi DATA_REG, 0xFF

LOOP:   out PORTB, DATA_REG
DELAY:  ldi DELAY_OUTER_LOOP 200
OUTER:  ldi YL, 0x3F
		ldi YH, 0x9C
INNER:  sbiw Y, 1
		brne INNER
		dec DELAY_PUTER_LOOP
		brne OUTER

		com DATA_REG
		rjmp LOOP