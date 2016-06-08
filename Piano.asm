/*
 * Piano.asm
 *
 *  Created: 2015/11/19 14:09:53
 *   Author: chisaton
 */ 

			.nolist
			.include <m328pdef.inc>
			.list
			
			.def TEMP_REG = r16
			.def LOOP_REG = r17
			

			;set up interrupt service routine vector
			.org	0x0000	; reset
			rjmp	MAIN
			
			.org	0x0002  ;INT0
			rjmp	INT0_ISR	

			.org	0x0004	; INT1
			rjmp	INT1_ISR

			.org	0x0040
				
MAIN:		; initialize the stack pointer
			ldi		r16, HIGH(RAMEND)
			out		SPH, r16
			ldi		r16, LOW(RAMEND)
			out		SPL, r16

			
			sbi		DDRB, PB1		; use pin1 of portB as an output pin
			
			cbi		DDRB, PB2		;set input
			sbi		PORTB, PB2
			nop

			cbi		DDRB, PB3
			sbi		PORTB, PB3
			nop

			cbi		DDRB, PB4
			sbi		PORTB, PB4
			nop

			;set interrupt on rising and falling edge
			ldi		TEMP_REG, (1<<ISC11) | (1<<ISC01) | (1<<ISC00)
			sts		EICRA, TEMP_REG
			ldi		TEMP_REG, (1<<INT1)|(1<<INT0)

			out		EIMSK, TEMP_REG ;enable external iterrupt 0 and 1

			;set Timer1 to toggle
			ldi		TEMP_REG, (1<<COM1A0) | (1<<WGM11) | (1<<WGM10)
			sts		TCCR1A, TEMP_REG
			

			sei	; enable interrupts globally	


	LOOP:	rjmp	LOOP


	INT0_ISR:	;wait to see if rising edge was due to bounce
			ldi		LOOP_REG, 200
	OUTER:	ldi		XH, HIGH(132)
			ldi		XL,	LOW(132)
	INNER:  sbiw	X,1
			brne	INNER
			dec		LOOP_REG
			brne	OUTER
			
			
			;see if input is still high
			in		TEMP_REG, PIND
			andi	TEMP_REG, (1<<PD2)
			breq	DONE1
			
			
			;select value of key
			ldi		ZH, HIGH(KEYS<<1)
			nop
			in		TEMP_REG, PIND ;read input
			andi	TEMP_REG, 0b00011100 
			ldi		ZL, LOW(KEYS<<1)
			
			add		ZL, TEMP_REG
			

			;load value to make frequences
			lpm		TEMP_REG, Z+
			
			sts		OCR1AH, TEMP_REG
			
			lpm		TEMP_REG, Z
			
			sts		OCR1AL, TEMP_REG

			ldi		TEMP_REG, (1<<WGM13) | (1<<WGM12) | (1<<CS10)
			sts		TCCR1B, TEMP_REG
	DONE1:	reti


	INT1_ISR:	;stop buzzer
			ldi		LOOP_REG, 200
	OUTER2:	ldi		XH, HIGH(132)
			ldi		XL,	LOW(132)
	INNER2: sbiw	X,1
			brne	INNER2
			dec		LOOP_REG
			brne	OUTER2
		
			
			;see if input is still low
			in		TEMP_REG, PIND
			andi	TEMP_REG, (1<<PD3)
			brne	DONE2
			
			ldi		TEMP_REG, (0<<CS10)
			sts		TCCR1B, TEMP_REG

DONE2:		reti





	;Keys Table
		.org 0x0FFF
		KEYS:	.dw	0X7774, 0x6A66, 0x5ECF