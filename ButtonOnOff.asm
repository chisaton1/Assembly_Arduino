/*
 * ButtonOnOff.asm
 *
 *  Created: 2015/10/01 13:31:18
 *   Author: chisaton
 */ 

	.nolist
	#include "m328pdef.inc"
	.list

	.def	TEMP_REG = r20
	.def	ZERO_REG = r21
	.def	INPUT_REG1 = r22
	.def	INPUT_REG2 = r23
	.def	DELAY_OUTER_LOOP = r24

	.cseg

	.org 0
	; initializes stack pointer
	ldi		TEMP_REG, HIGH(RAMEND)
	out		SPH, TEMP_REG
	ldi		TEMP_REG, LOW(RAMEND)
	out		SPL, TEMP_REG

	ldi		TEMP_REG, 0xff
	ldi		ZERO_REG, 0x00

	out		DDRB, TEMP_REG ;output
	out		DDRD, ZERO_REG ;input

	out		PORTD, TEMP_REG ; uses this command instead of resister


READ_INPUT:
	; first input of PIND
	in		INPUT_REG1, PIND
	andi	INPUT_REG1, 0x04 ; push botton is connected to PD2

	rcall	FIVE_MSEC_DELAY ;5msec delay

	; second input of PIND
	in		INPUT_REG2, PIND
	andi	INPUT_REG2, 0x04

	; checks first and second input is same
	cp		INPUT_REG1, INPUT_REG2
	brne	READ_INPUT

	; if these inputs are same, checks these are 0 or 1
	tst		INPUT_REG1
	breq	zero

	; if input is 1
	out		PORTB, TEMP_REG
	rjmp	READ_INPUT
zero:
	; if input is 0
	ldi		r30, 0x00
	out		PORTB, r30
	rjmp	READ_INPUT


FIVE_MSEC_DELAY:
		ldi		DELAY_OUTER_LOOP, 200
OUTER:	
		ldi		YL, 0x64
		ldi		YH, 0x00
INNER:	
		sbiw	Y, 1 ; Y = 100
		brne	INNER
		dec		DELAY_OUTER_LOOP
		brne	OUTER
		ret