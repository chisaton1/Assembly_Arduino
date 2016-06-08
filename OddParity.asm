
 /*
 * OddParity.asm
 * Author: chisaton
 *
 * Arduino pin 8  -- red LED -- 100 ohm resistor -- ground
 * Arduino pin 9  -- red LED -- 100 ohm resistor -- ground
 * Arduino pin 10 -- red LED -- 100 ohm resistor -- ground
 * Arduino pin 11 -- red LED -- 100 ohm resistor -- ground
 * Arduino pin 1  -- green LED -- 100 ohm resistor -- ground
 *
 */ 

.nolist
#include "m328pdef.inc"
.list


.def DELAY_OUTER_LOOP = r22
.def TEMP_REG = r20
.def DATA_REG = r21
.def ODD_PARITY = r16 ;Input the number of 1s and flip the bits in order to blink a green LED
.cseg

; initializes stack pointer
ldi		TEMP_REG, HIGH(RAMEND)
out		SPH, TEMP_REG
ldi		TEMP_REG, LOW(RAMEND)
out		SPL, TEMP_REG

ldi TEMP_REG, 0xFF
out DDRB, TEMP_REG ;Need to use PORTD for a green LED
out DDRD, TEMP_REG
ldi DATA_REG, 0x00

LOOP:   inc DATA_REG ;Increment DATA_REG so that red LEDs can display each number in binary

		;Count how many number of 1s using bits sift
		; Main logic is following (ignore fifth, sixth, seventh, and eighth digits)
		;
		; bits = (bits & 0x05) + (bits >> 1 & 0x05);
		; number of 1's = (bits & 0x03) + (bits >> 2 & 0x03);

		mov r23, DATA_REG 
		mov r24, DATA_REG
		ldi r17, 0x0F ; r17 = 00001111
		ldi r25, 0x05 ; r25 = 00000101
		and r23, r25  ; and r23(current number), 00000101
		and r24, r17  ; Ignores fifth, sixth, seventh, and eighth digits: "and r24, 00001111"
		lsr r24
		and r24, r25 ; and r24(current number), 00000101
		add r23, r24

		mov r26, r23
		mov r27, r23
		ldi r28, 0x03 ; r28 = 00000011
		and r26, r28
		and r27, r17
		lsr r27
		lsr r27
		and r27, r28
		add r26, r27 ;r26 indicates the number of 1s

		com r26 ;Flip the bit since if first digit is 0, the nunmber is even.
				;Green LED which is in pin 1 has to blink when the number of 1s is even.
		mov ODD_PARITY, r26 ;input the number of 1s in binary and filp the bits

		out PORTD, ODD_PARITY ;output to portD
		out PORTB, DATA_REG ;output to portB

		rcall	DELAY
		rjmp LOOP



DELAY:  ldi DELAY_OUTER_LOOP, 200

OUTER:  ldi YL, 0x1F
		ldi YH, 0x4E
INNER:  sbiw Y, 1
		brne INNER
		dec DELAY_OUTER_LOOP
		brne OUTER

		ret