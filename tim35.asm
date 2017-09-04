; ********************************************
; * [Project title: Simple timer using AVR atmega 8535 ]            *
; * [Software version:0.1]    *
; * StartDate and time: Wednesday, August 23, 2017    *
; * Version 1.0 complete on Tuesday, September 5, 2017
; ********************************************
.NOLIST
.INCLUDE "/home/prasad/work/avr/antlib/m8535def.inc";Header for ATMEGA8535
.LIST
.device at90s8535
; ============================================
;   H A R D W A R E  I N F O R M A T I O N
; ============================================
; * No crystal is used. Internal oscillator of 1 MHz used.

; ============================================
;      P O R T S   A N D   P I N S 
; ============================================
; pb is output for leds. These are used as binary display
; pd6 is relay
; 
; ================================================
; Declaration of Constants
; ================================================
; none.

; =======================================================
;  fixed and derrived constants
; =======================================================
; none

; ============================================
;   R E G I S T E R   D E F I N I T I O N S
; ============================================
.equ    led = 1			;portd  bit USED in this programme for led pin 15
.def    temp = r19		;used in lcd routines
.def    a = r20 		;used in lcd routines
.equ	key = 0			;key to be pressed on pd0 pin 14 of 8535
.equ	buzzer = 2		;buzzer connected to pin 16 i.e. pd2
.equ	display = portb
; ============================================
;       S R A M   D E F I N I T I O N S
; ============================================
; none
; 
;=================================================
; ***************REGISTERS USED***********
;================================================
;r2,r3,r16,r17,r18,r19,r20


;==============================================
;   R E S E T   & INTERRUPT VECTORS
; ==============================================
;
.CSEG
.ORG $0000
        rjmp    setup
        reti
        reti
        reti
        reti
        reti
        reti
        reti
        reti
        rjmp	tc0i		;timer0 overflow interrupt
	reti
	reti
	reti
	reti
	reti
	reti
	reti
	reti
	reti
	reti
	reti
; ==========================================
;    I N T E R R U P T   S E R V I C E
; ==========================================
;
; [Write all interrupt service routine here]
; isr is written in the timer.asm.  File included.
; ============================================
;    HERE ARE THE MACROS
; ============================================
.MACRO    hardtime   		; Define an example macro
          ldi	temp,@0 	; macro parameters used to 	-
          mov	r3,temp		; set hardware time
          ldi	temp,@1
          mov	r2,temp
          rcall	hardsec
.ENDMACRO            		; End macro definition
; ============================================
;    HERE STARTS THE MAIN PROGRAMME
; ============================================
;
setup:
; Init Stack
	ldi 	temp, HIGH(RAMEND) ; Init MSB Stack
	out 	SPH,temp
	ldi 	temp, LOW(RAMEND)  ; Init LSB Stack
	out 	SPL,temp
; Configure input and output keys
	cbi	ddrd,key	   ;config pd0 as input
	sbi	ddrd,buzzer	   ;buzzer pin configured as output
	sbi	ddrd,led	   ;led pin configured as output
	ser 	temp		   ;temp=0xff
	out 	ddrb,temp	   ;portb configured as output: pins 1 to 8
;uncomment the following two lines if you want to use the lcd display
;	ser     a
;	out	ddrc,a		   ;port c configured as o/p
;*********intial blinking: settles the voltage i/p to adc*************
blink:	rcall	t_one

;******sense the potentiometer to know the time set by the user.*****
sense:	rcall	a2d		   ;conversion started: result in r9
	out	display,r9	   ;show the adc value on display
test:	rjmp	check_key
;*****wait till a button is pressed and then starts the timer********
check_key:
	sbis	pind,key	;if key is NOT-PRESSED, skip the next instruction
	rjmp	chk_again
	rjmp	check_key	;check the key again
chk_again:
	rcall	ms50		;debounce delay
	sbic	pind,key	;if key IS PRESSED,skip the next instsruction
	rjmp	check_key
wait:	sbis	pind,key	;wait till the key is released
	rjmp	wait
strttimer:
	mov	r18,r9		;result of adc now in r18
onemin:	rcall	min1
	dec	r18		
	out	portb,r18	;show remaining minutes on binary display
	brne	onemin
	ldi	r18,0x00
	out	portb,r18
	sbi	portd,buzzer
	rcall	t_one
	cbi	portd,buzzer
stop:	rjmp	sense		;programme stops here	

; ============================================
;     P R O G R A M M E - SUBROUTINES
; ============================================
t_one:	sbi	 portd,led	;flashes led once with 50% duty cycle
	hardtime 0x07,0xA0 	; 3d09 for 8MHz; 1c23 for 3.68Mhz; 
	cbi	 portd,led
	hardtime 0x07,0xA0	;0x00 to compensate ret and other instruction time
	ret	
ms50:   hardtime 0x00,0xd0
	ret
;	sub-routine for one minute
min1:	ldi	r17,60
minloop:
	rcall	t_one
	dec	r17
	brne	minloop
	ret

; 	one second subroutine
sec1:	hardtime 0x0F,0x42  	   ;1 S for 8 MHz 0x7a,0x12
	ret

; files included in the above programme
.include "adc.asm"
.include "timings.asm"
