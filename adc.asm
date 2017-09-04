;.def    delay1 = r17
;.def    delay2 = r18
;.cseg
;chanel-0 selected for a-d conversion        
;***the a2d routine gives number within 0 to 255 for voltage range 0 to 5V in r9
a2d:					; / 	
	ldi	temp,0x60		;|AVcc = Aref volts, chanel 0 selected &	
        out     admux,temp              ; \with left adj adc output (msbits in adch)
        ldi     temp,0xc1		;adc-enabled,STARTED,clk rate clk/2 
	out 	adcsra,temp             ;ADCSRA configured for clk/2   1100'0001
pol_adc:
        sbic    adcsra,adsc             ; wait till a/d conversion complete
        rjmp    pol_adc                 ; up to this instruction
        in      temp,adch               ; left adjusted adc in temp
        mov	r9,temp
;	ldi 	temp,(1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0) ;switch ADC off (same chanel)
	ldi	temp,0x07		; / switch ADC OFF	      
        out	adcsra,temp		;|
        ret


;|--------------------------------------------------------------
;|refs1	|refs0	|adlar	|---	|mux3	|mux2	|mux1	|mux0	|  ADMUX
;|______________________________________________________________
;|--------------------------------------------------------------
;|0	|1	|1	|0	|0	|0	|0	|1	| mux3..0 for chanel-1
;|______________________________________________________________