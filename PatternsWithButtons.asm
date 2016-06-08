/*
 * PatternsWithButtons.asm
 *
 *  Created: 2015/10/08 13:23:50
 *   Author: chisaton
 *
 * Arduino pin 8  -- red LED -- 100 ohm resistor -- ground
 * Arduino pin 9  -- red LED -- 100 ohm resistor -- ground
 * Arduino pin 10 -- red LED -- 100 ohm resistor -- ground
 * Arduino pin 11 -- red LED -- 100 ohm resistor -- ground
 * Arduino pin 12 -- red LED -- 100 ohm resistor -- ground
 *
 * Button pin 2 -- 100 ohm resister -- ground which changes PATTERNs
 * Button pin 3 -- 100 ohm resister -- ground which changes speed of light
 *
 */ 

	.nolist
	#include "m328pdef.inc"
	.list

	.def	TEMP_REG = r20
	.def	ZERO_REG = r21
	.def	INPUT_REG1 = r22
	.def	INPUT_REG2 = r23
	.def	DELAY_COUNTER1 = r24
	.def	DELAY_COUNTER2 = r25
	.def	DELAY_OUTER_LOOP1 = r19
	.def	DELAY_OUTER_LOOP2 = r18
	.def	SIMPLE_LOOP = r16
	.def	PATTERNS = r17
	
	.cseg

	; initializes stack pointer
	ldi		TEMP_REG, HIGH(RAMEND)
	out		SPH, TEMP_REG
	ldi		TEMP_REG, LOW(RAMEND)
	out		SPL, TEMP_REG

	ldi		TEMP_REG, 0xff
	ldi		ZERO_REG, 0x00
	ldi		r28, 1 ; this register is used whether pushing the button (compares another register with r28 = 1)or not
	out		DDRB, TEMP_REG ;output
	out		DDRD, ZERO_REG ;input

	out		PORTD, TEMP_REG ; uses this command instead of resister
	ldi		DELAY_COUNTER1, 0 ; initiarization
	ldi		DELAY_COUNTER2, 255 ; iniriatization 
	ldi		r29, 0xff ; iniriarization

	rjmp	SWITCH ; start this program

	; SWITCH has 4 patterns programs. When these patterns use "ret", this program returns SWITCH and goes to next pattern
SWITCH:
	rcall	PATTERN1
	rcall	PATTERN2
	rcall	PATTERN3
	rcall	PATTERN4
	rjmp	SWITCH


	;before go back to SWITCH subroutine, the program which is in PATTERNs subroutine has to come to this subroutine
BREAK_LOOP:
	ldi	r27, 0 ; reset r27 = 0 (r27 = 1 indecates push the button) before go back to SWITCH
	ret


PATTERN1:
	ldi		PATTERNS, 0x04
	rcall	LOW_TO_HIGH ; dim to bright (LOW_TO_HIGH connects HIGH_TO_LOW)

	rcall	READ_INPUT_PATTERN ; check whether the button pushed or not
	cp		r27, r28 ; check r27 == 1 or not
	breq	BREAK_LOOP ; break this loop (PATTERN1) and go back to SWITCH

	rjmp	PATTERN1


PATTERN2:
	ldi		r30, 0x03 ;start this point
	out		PORTB, r30
	rcall	SIMPLE_DELAY
LOOP:
	lsl		r30 ; shifts 1 bit left
	out		PORTB, r30
	rcall	SIMPLE_DELAY
	lsl		r30
	out		PORTB, r30
	rcall	SIMPLE_DELAY
	lsl		r30
	out		PORTB, r30
	rcall	SIMPLE_DELAY
	lsr		r30 ;shifts 1 bit right
	out		PORTB, r30
	rcall	SIMPLE_DELAY
	lsr		r30
	out		PORTB, r30
	rcall	SIMPLE_DELAY
	lsr		r30
	out		PORTB, r30
	rcall	SIMPLE_DELAY

	rcall	READ_INPUT_PATTERN ; button
	cp		r27, r28 ; check r27 == 1 (push the button) or not
	breq	BREAK_LOOP ;  break this loop (PATTERN2) and go back to SWITCH

	rjmp	LOOP


PATTERN3:
	ldi		r31, 0x0A ;light up one pattern
	out		PORTB, r31
	rcall	SIMPLE_DELAY

	ldi		r31, 0x15 ; light up another pattern
	out		PORTB, r31
	rcall	SIMPLE_DELAY

	rcall	READ_INPUT_PATTERN ; button
	cp		r27, r28 ; check r27 == 1 (push the button) or not
	breq	BREAK_LOOP ; break this loop (PATTERN3) and go back to SWITCH

	rjmp	PATTERN3


	; PATTERN4 is almost same as PATTERN3. The difference is whether using dim to bright.
PATTERN4:
	ldi		PATTERNS, 0xA ; one pattern
	rcall	LOW_TO_HIGH ; dim to bright
	ldi		PATTERNS,	0x15 ; another pattern
	rcall	LOW_TO_HIGH ; dim to bright

	rcall	READ_INPUT_PATTERN ; button
	cp		r27, r28 ; check r27 == 1 (push the button) or not
	breq	BREAK_LOOP ;  break this loop (PATTERN4) and go back to SWITCH

	rjmp	PATTERN4


LOW_TO_HIGH:
	out		PORTB, ZERO_REG ; light down
	rcall	CHANGE_DELAY2	;decrease
	out		PORTB, PATTERNS;TEMP_REG ; light up
	rcall	CHANGE_DELAY1	;increase
	cp		DELAY_COUNTER1, TEMP_REG ; check DALAY_COUNTER1 == 0xff
	breq	SET_UP1 ; reset DELAY_COUNTER1 and 2
	rjmp	LOW_TO_HIGH ; loop


HIGH_TO_LOW:
	out		PORTB, PATTERNS;TEMP_REG ; light up
	rcall	CHANGE_DELAY2 ;decrease
	out		PORTB, ZERO_REG ; light down
	rcall	CHANGE_DELAY1 ; increase
	cp		DELAY_COUNTER1, TEMP_REG ; check DALAY_COUNTER == 0xff
	breq	SET_UP2 ; reset DEKAY_COUNTER1 and 2
	rjmp	HIGH_TO_LOW ; loop	


SET_UP1:
	ldi		DELAY_COUNTER1, 0 ; initiarization
	ldi		DELAY_COUNTER2, 255
	rjmp	HIGH_TO_LOW


SET_UP2:
	ldi		DELAY_COUNTER1, 0 ; initiarization
	ldi		DELAY_COUNTER2, 255
	;rjmp	LOW_TO_HIGH
	ret


	; check whether button is pushed or not in order to change the pattern
READ_INPUT_PATTERN:
	; first input of PIND
	in		INPUT_REG1, PIND
	andi	INPUT_REG1, 0x04 ; push botton is connected to PD2

	rcall	FIVE_MSEC_DELAY ;5msec delay

	; second input of PIND
	in		INPUT_REG2, PIND
	andi	INPUT_REG2, 0x04
	
	; checks first and second input is same
	cp		INPUT_REG1, INPUT_REG2
	brne	READ_INPUT_PATTERN

	; if these inputs are same, checks these are 0 or 1
	tst		INPUT_REG1
	breq	zero1

	ldi		r27, 1 ;counter 1 = push the button
	ret

zero1:
	ldi		r27, 0
	ret


	; check the button whether the button is pushed or not in order to chage the speed
READ_INPUT_SPEED:
	; first input of PIND
	in		INPUT_REG1, PIND
	andi	INPUT_REG1, 0x08 ; push botton is connected to PD3

	;rcall	FIVE_MSEC_DELAY ;5msec delay

	; second input of PIND
	in		INPUT_REG2, PIND
	andi	INPUT_REG2, 0x08

	; checks first and second input is same
	cp		INPUT_REG1, INPUT_REG2
	brne	READ_INPUT_SPEED

	; if these inputs are same, checks these are 0 or 1
	tst		INPUT_REG1
	breq	zero2

	ldi		r26, 1 ;counter 1 = push the button
	ret

zero2:
	ldi		r26, 0
	ret


	; It as used by LOW_TO_HIGH and HIGHT_TO_LOW
CHANGE_DELAY1:
		inc		DELAY_COUNTER1 ; +1 so that DELAY_OUTER_LOOP1 is getting bigger and bigger
		mov		DELAY_OUTER_LOOP1, DELAY_COUNTER1
OUTER1:	
		ldi		YL, 0x20
		ldi		YH, 0x00
INNER1:	
		sbiw	Y, 1
		brne	INNER1
		dec		DELAY_OUTER_LOOP1
		brne	OUTER1
		ret


	; It as used by LOW_TO_HIGH and HIGHT_TO_LOW as well
CHANGE_DELAY2:
		ldi		r31, 1
		dec		DELAY_COUNTER2 ; -1 so that DELAY_OUTER_LOOP2 is getting smaller and smaller
		mov		DELAY_OUTER_LOOP2, DELAY_COUNTER2
OUTER2:	
		ldi		YL, 0x20
		ldi		YH, 0x00
INNER2:	
		sbiw	Y, 1
		brne	INNER2
		dec		DELAY_OUTER_LOOP2
		brne	OUTER2
		ret


	; once come to this subroutine, r29 is subtracted by 86 so that change the speed (counter = (almost) 255, 170, 85, 255, 170, 85, ...)
CHANGE_SPEED1:
		ldi		r16, 86
		sub		r29, r16 
		mov		SIMPLE_LOOP, r29
		ldi		r26, 0
		rjmp	SIMPLE_DELAY


SIMPLE_DELAY:
		rcall	READ_INPUT_SPEED ; check the button which can change the speed
		cp		r26, r28 ; check r26 == 1 (push the button) or not
		breq	CHANGE_SPEED1 ; if the button is pushed, change the speed
OUTER3:	
		ldi		YL, 0xff
		ldi		YH, 0x10
INNER3:	
		sbiw	Y, 1
		brne	INNER3
		dec		SIMPLE_LOOP
		brne	OUTER3
		ret


	; This is 5 msec dellay subroutine which is used to check whether pushing the button or not
FIVE_MSEC_DELAY:
		ldi		r31, 200
OUTER4:	
		ldi		YL, 0x64
		ldi		YH, 0x00
INNER4:	
		sbiw	Y, 1 ; Y = 100
		brne	INNER4
		dec		r31
		brne	OUTER4
		ret