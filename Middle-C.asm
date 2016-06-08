/*
 * Middle_C.asm
 *
 *  Created: 2015/12/14 12:15:03
 *   Author: chisaton
 */ 


 .nolist
		.include <m328pdef.inc>
		.list

		.def	TEMP_REG = r16

		; initialize the stack pointer
		ldi		r16, HIGH(RAMEND)
		out		SPH, r16
		ldi		r16, LOW(RAMEND)
		out		SPL, r16

		sbi		DDRB, PB1	; set PB1 to be an output pin

		;load value to produce 261.6Hz frequency into OCR1A (a 2 byte register)
		; when writing to a 16-bit register, always write the high byte first
		ldi		TEMP_REG, 0x77
		sts		OCR1AH, TEMP_REG
		ldi		TEMP_REG, 0x74
		sts		OCR1AL, TEMP_REG

		; set Timer1 to toggle output on compare match using mode 15 
		ldi		TEMP_REG, (1<<COM1A0) | (1<<WGM11) | (1<<WGM10)	
		sts		TCCR1A, TEMP_REG
		ldi		TEMP_REG, (1<<WGM13) | (1<<WGM12) | (1<<CS10) ; start with no prescaler
		sts		TCCR1B, TEMP_REG

DONE:	rjmp	DONE

