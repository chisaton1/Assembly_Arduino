/*
 * TimerExample1.asm
 *
 * TimerExample1version2.asm - continuously toggles pin 5 of port B
 * using timer0 in normal mode (no prescaler)
 * to control the short delay.
 *
 * Similar to Example 9-3 on page 318 of Mazidi
 *
 *  Created: 2015/10/27 13:48:12
 *   Author: chisaton
 */ 

		.nolist 
		.include <m328pdef.inc>
		.include "WVWCmacros.inc"
		.list

		.def	EOR_MASK_REG = r16
		.def	DATA_REG = r17
		.def	TEMP_REG = r20

		.listmac
		INIT_SP		; initialize the stack pointer

		sbi		DDRB, PB5	;use bit 5 of port B as an output
		clr		DATA_REG	; first value to output is 0  
		out		PORTB, DATA_REG

		ldi		EOR_MASK_REG, 1<<PB5	; so we can toggle PB5 in the loop

; the endless loop to toggle PB5
LOOP:	rcall	DELAY
		eor		DATA_REG, EOR_MASK_REG
		out		PORTB, DATA_REG
		rjmp	LOOP
; ---------------------
; use Timer0 to perform a delay of 9 cycles. Add the cycles before the timer starts and after
; the timer stops to find the clock cycles of the entire delay loop.
; we will constantly check (poll) the overflow flag in the timer to see when it is done.

DELAY:	ldi		TEMP_REG, -9		;since the timer increments the value in TCNT0, the timer will
									;set the overflow bit after 9 clock ticks
		out		TCNT0, TEMP_REG		;the counter value = -9

		; set up the timer's condition code registers
		ldi		TEMP_REG, 0<<WGM01 | 0 << WGM00	
		out		TCCR0A, TEMP_REG		
		ldi		TEMP_REG,  0<<WGM02 | 0<<CS02 | 0<<CS01 | 1<<CS00
		out		TCCR0B, TEMP_REG		;start timer0 in normal mode with no prescaler


		;keep checking the timer until it overflows (reaches 0)
CHECK:	in		TEMP_REG, TIFR0		;TIFR0 = Timer Interrupt Flag Register for timer0
		sbrs	TEMP_REG, TOV0		; skip (next instr) if the overflow bit is set
		rjmp	CHECK


		;stop the timer
		ldi		TEMP_REG, 0<<CS00	; (can't use cbi since TCCR0B's addr > 0x1F)
		out		TCCR0B, TEMP_REG	; CS01 and CS02 are already 


		;clear the overflow flag
		sbi		TIFR0, TOV0		; write a 1 to TOV0 in order to clear it!

		ret