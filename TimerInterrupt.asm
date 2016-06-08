/*
 * TimerInterrupt.asm
 *
 *  Created: 2015/11/03 13:29:01
 *   Author: chisaton
 */ 


 /*
 * TimerInterrupt.asm - Toggles pin 5 of portB every 40 microseconds while at the same time 
 * transferring data from PORTC to PORTD. Uses interrupts forTimer0.  Timer0 will use CTC mode
 * and a 1/8 prescaler.
 * 
 * Similar to Example 10-3 on page 374 of textbook (Mazidi) 
 *
 *  Created: Tue, 11, 3, 2015 10:27:03 AM
 *   Author: Lynn
 */

			.nolist
			.include <m328pdef.inc>
			;.include <WVWCMacros.inc>
			.list
			;.listmac

			; set up interrupt service routine vector
			.org	0x0000	; reset
			jmp		MAIN

			;.org	0x0020	; timer0 overflow
			;jmp		T0_ISR

			.org	0x001C	; timer0 compare register A
			jmp		T0_ISR

			;set up DDRB
			ldi		r16, 0xFF
			out		DDRB, r16
			
			.org	0x0040	; past the interrupt service routine vector	
MAIN:
			;ldi		r16, HIGH(RAMEND)
			;out		SPH, r16
			;ldi		r16, LOW(RAMEND)
			;out		SPL, r16

			;sbi		DDRB, 5			; use pin5 of portB as an output pin
			ldi		r20, 1<<OCIE0A	; enable the interrupts for output compare register A
			sts		TIMSK0, r20

			sei						; enable interrupts globally

			ldi		r20, 4			; interrupt when counter reaches this value (should be 80 for 40 microsec)
			out		OCR0A, r20
			ldi		r20, 1<<WGM01	; compare mode (CTC)
			out		TCCR0A, r20
			//ldi		r20, 1<<CS01	; prescaler = 1/8 and start timer  (use prescaler for 40 microsec)

			ldi		r20, 1<<CS00	; start timer with no prescaler (for demonstration purposes)
			out		TCCR0B, r20


			ldi		r20, 0xFF
			out		DDRB, r20

			ldi		r20, 0x00
			out		DDRB, r20	

; ------ Infinite loop -------
HERE:		in		r20, PINC		; read from port C
			out		PORTD, r20		; and send it to PORTD
			rjmp	HERE
;---------Interrupt Service Routine for Timer0 --------------------
T0_ISR:		in		r16, PORTB
			ldi		r17, 0b00100000	; a one in bit 5 for toggling PB5
			eor		r16, r17
			out		PORTB, r16		; toggle PB5
			reti					; return from interrupt
