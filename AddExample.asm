/*
 * AddExample.asm
 *
 *  Created: 2015/09/03 14:00:53
 *   Author: chisaton
 */ 

		.nolist
		#include "m328pdef.inc"
		.list

		.cseg // code segment

		ldi		r21, 12
		ldi		r22, 013
		ldi		r23, $14
		ldi		r24, 0x15
		ldi		r25, 0b11001111
		ldi		r26, 'a'
		add		r22, r21
 done:	rjmp	done