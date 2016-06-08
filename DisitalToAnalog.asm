/*
 * DisitalToAnalog.asm
 *
 *  Created: 2015/12/11 17:58:49
 *   Author: chisaton
 */ 


			.nolist
			.include <m328pdef.inc>
			.list

			.def	ONE_REG = r20
			.def	ZERO_REG = r21
			.def	VALUE_HIGH = r22
			.def	TEMP_REG = r23


			; set up interrupt service routine vector
			.org	0x0000	; reset
			jmp		MAIN

			.org	0x002A	; ADC Conversion Complete
			jmp		T0_ISR

			; set up DDRB as an output
			/*ldi		r16, 0xFF
			out		DDRB, r16

			; set up DDRC as a input
			ldi		r16, 0x00
			out		DDRC, r16*/
			
			.org	0x0040	; past the interrupt service routine vector	
MAIN:
			; set up DDRB as an output
			ldi		r16, 0xFF
			out		DDRB, r16

			; set up DDRC as a input
			ldi		r16, 0x00
			out		DDRC, r16

			ldi		r16, HIGH(RAMEND)
			out		SPH, r16
			ldi		r16, LOW(RAMEND)
			out		SPL, r16

			ldi		r20, 0xFF
			ldi		r21, 0x00

			ldi		TEMP_REG, (1 << REFS0)
			sts		ADMUX, TEMP_REG
			ldi		TEMP_REG, (1 << ADEN) | (1 << ADSC) | (1 << ADIE) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0)
			sts		ADCSRA, TEMP_REG

			sei ; global interrupts

LOOP:		rjmp	LOOP ; do nothing



;---------Interrupt Service Routine --------------------
T0_ISR:		lds		VALUE_HIGH, ADCH
			
			cpi		VALUE_HIGH, 0x03 ; 00000011
			brsh	FOUR

			cpi		VALUE_HIGH, 0x02 ; 00000010
			brsh	THREE

			cpi		VALUE_HIGH, 0x01 ; 00000001
			brsh	TWO

			rjmp	ONE ; 00000000


FOUR:		ldi		r26, 0x0F
			out		PORTB, r26
			rjmp	DONE


THREE:		ldi		r26, 0x07
			out		PORTB, r26
			rjmp	DONE

TWO:		ldi		r26, 0x03
			out		PORTB, r26
			rjmp	DONE

ONE:		ldi		r26, 0x01
			out		PORTB, r26

			

DONE:			; Start conversion again
			ldi		TEMP_REG, (1 << ADEN) | (1 << ADSC) | (1 << ADIE) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0)
			sts		ADCSRA, TEMP_REG
			reti