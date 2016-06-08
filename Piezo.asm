/*
 * Piezo.asm
 *
 * TimerInterrupt.asm - Toggles pin 5 of portB every 40 microseconds while at the same time 
 * transferring data from PORTC to PORTD. Uses interrupts forTimer0.  Timer0 will use CTC mode
 * and a 1/8 prescaler.
 * 
 * Similar to Example 10-3 on page 374 of textbook (Mazidi) 
 *
 *
 *  Created: 2015/11/10 14:17:41
 *   Author: chisaton
 */ 

			.nolist
			.include <m328pdef.inc>
			;.include <WVWCMacros.inc>
			.list
			.listmac

			.def	DATA_REG = r18
			.def	TEMP_REG = r19


			; set up interrupt service routine vector
			.org	0x0000
			jmp		MAIN

			.org	0x001C
			jmp		ISR

			.org	0x0040


MAIN:

			;setup stack pointer
			ldi		r16, HIGH(RAMEND)
			out		SPH, r16
			ldi		r16, LOW(RAMEND)
			out		SPL, r16


			ldi		DATA_REG, 0
			ldi		r16, 0xFF
			out		DDRB, r16 ; use portB as an output pin
			

			;out		OCIE0A, 1 ; OCIE0A = 00000001
			ldi		TEMP_REG, 1<<OCIE0A	; enable the interrupts for output compare register A
			sts		TIMSK0, TEMP_REG

			sei						; enable interrupts globally


			ldi		r20, 0x77		; interrupt when counter reaches this value (should be 80 for 40 microsec)
			out		OCR0A, r20	; OCRnA n = 0 thus Timer0


			ldi		r20, 1<<WGM01	; compare mode (CTC)
			out		TCCR0A, r20


			//ldi		r20, 1<<CS01	; prescaler = 1/8 and start timer  (use prescaler for 40 microsec)
			ldi		r20, 1<<CS02	; start timer with 1/256 prescaler (for demonstration purposes)
			out		TCCR0B, r20	; Once setup here, the time starts

			out PORTB, DATA_REG


; ------ Infinite loop ------- until the timer is done
LOOP:		rjmp	LOOP

;---------Interrupt Service Routine for Timer0 --------------------
ISR:		com		DATA_REG
			out		PORTB, DATA_REG
			reti