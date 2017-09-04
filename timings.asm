
;************************************************
;various timings implemented using assmebly
;************************************************

                
                
;********One second timing implemented using timer0 & interrupts************     
; Counter for timer timeouts, MSB timer driven by software
.DEF	z1 = R4
; Working register for the Interrupt-Service-Routine
.DEF	ri = R5
; Register for counting the seconds as packed BCD
.DEF	seconds = R6

;************ISR for the timer0 interrupt******
tc0i:
	in	ri,SREG 	; save the content of the flag register
	inc	z1 		; increment the software counter
	out	SREG,ri 	; restore the initial value of the flag register
	reti 			; Return from interrupt
	
;*************ISR Ends here*********************	
hardsec:
; Software-Counter-Register reset to zero
	ldi	temp,0 		; z1 cannot be set to a constant value, so we set mp
	mov	z1,temp 	; to zero and copy that to R0=z1

; Prescaler of the counter/timer = 1024, that is 8 MHz/1024 = 7812.5 Hz = $1E84(TCCR0=0x05)
; Period for prescale=1024 is 0.000128 seconds i.e. 128.0 microS. So 8 repeatitions ~ 1mS
; Prescaler of the counter/timer = 256, that is 8 MHz/256 = 31250 Hz = $7A12
	ldi	temp,0x04 	;Initiate Timer/Counter 0 Prescaler=256
	out	TCCR0,temp 	; to Timer 0 Control Register
	
; enable interrupts for timer 0
	ldi	temp,0x01 	; set Bit 0
	out	TIMSK,temp 	; in the Timer Interupt Mask Register
	
; enable all interrupts in general
	sei 			; enable all interrupts by setting the flag in status-reg
	
; **************how to use the above routine?*******************************
; The 8-bit counter overflows from time to time and the interrupt service
; routine increments a counter in a register. The main program loop reads this
; counter register and waits until it reaches hex 7A. Then the timer is read until
; he reaches 12 (one second = dec 31250 = hex 7A12 timer pulses for 8MHz). The timer
; and the register are set to zero and one second is incremented. The seconds
; are handled as packed BCD-digits (one digit = four bits, 1 Byte represents
; two digits). The seconds are reset to zero if 60 is reached. The seconds
; are displayed on the LEDs.
; 0x007d -> 4mS exact for prescale 256    ... r3=0x00 r2=0x7d
; 0x0139 -> 10 mS ~ for prescale 256	  ... r3=0x01 r2=0x39
; 0x0177 -> 12 mS exact for prescale 256  ... r3=0x01 r2=0x77	
; 0x0271 -> 20 mS exact --"--		  ... r3=0x02 r2=0x71
; 0x0C35 -> 100mS for prescale 256	  ... r3=0x0C r2=0x35
; for various for timings in mS, spreadsheet "timerParameters" in same directory
; for 1024 micro seconds, parameters are : 0x00, 0x20
; for 800 micro seconds, : 0x00 , 0x19
; for 	
loop:
	mov	temp,r3 		; compare value for reg counter 0x7A ..
					; r3 contains upper byte
loop1:
	cp	z1,temp 		; compare with the register
	brlt	loop1 			; z1 < mp, wait 
					;(during this interrupt occurs several times.)
loop2:
	in	temp,TCNT0 		; read LSB in the hardware counter
	cp	temp,r2 		; compare with the target value r2=0x12 here 
					; i.e. lower byte
	brlt	loop2 			; TCNT0 < 09, wait
	ldi	temp,0 			; set register zero and ...
	out	TCNT0,temp 		; reset hardware-counter LSB
	mov	z1,temp 		; and software-counter MSB
	cli
	ret				;one second complete

;*******************timer2 is 8 bit timer with pwm @ oc2 chip-pin 17**************	
; 3906.25Hz Fast PWM frequency for prescalar=8=N Xtal=8MHz
; 31250 Hz PWM freq for prescalar = 1 =N, Xtal=8MHz
; OC2 must be defined as output for pwm functionality
; If the OCR2 is set equal to BOTTOM, the output will be a narrow spike
; Setting the OCR2 equal to MAX will result in a constantly high or low output 
; (depending on the polarity of the output set by the COM21:0 bits.)
; *************note1**********************************
; tccr2= 0110 1010B (0x6a)  will mean following
; 1. fast pwm selected
; 2. more ocr2 value, more is the duty cycle (match ocr=>lo, bottom=>hi)
; 3. prescalar=8
;****************************note1 ends here****************************************
fastpwm2:			   	;50% duty cycle fast pwm using timer2
;		ldi	r16,0x7f
;		out	ocr2,r16	;ocr2=127 for 50% duty cycle
;		ldi	r16,(1<<PB3)	;
;		out	ddrb,r16	;make pb3 (oc2) as output pin
		ldi	r16,0x6a	
		out	tccr2,r16	; see note1 above
		ret