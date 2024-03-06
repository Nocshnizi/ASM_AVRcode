.include "m8515def.inc"




.def temp = r16    
.def encoder_data = r17 


.def last_encoder_state = r19

.def next_encoder_state = r20
.def counterclockwise = r15
.def counter = r23
.def againstCounter = r22    
.def long_delay_low = r24  
.def long_delay_high = r25
.def lcd_data = r18
.def little_letter = r21
.def permition = r26

.EQU lcd_data_reg = 0x8005

.EQU lcd_com_reg = 0x8004



.CSEG    
.ORG 0x0000  



  rjmp Init; Reset Handler (aaeoi? ia?a?eaaiiy ii neeaaii?)
  reti; rjmp EXT_INT0; IRQ0 Handler
  reti; rjmp EXT_INT1; IRQ1 Handler
  reti; rjmp TIM1_CAPT; Timer1 Capture Handler
  rjmp TIM0_COMP ; Timer1 Compare A Handler
;oiaoi, aa?ana ia?aoiao ia ia?iaiee ia?a?eaaiiy ii ni?aiaa?ii? A oaeia?a/e??eeuieea T1
  reti; rjmp TIM1_COMPB; Timer1 Compare B Handler
  reti; rjmp TIM1_OVF; Timer1 Overflow Handler
  reti; rjmp TIM0_OVF; Timer0 Overflow Handler
  reti; rjmp SPI_STC; SPI Transfer Complete Handler
  reti; rjmp USART_RXC; USART RX Complete Handler
  reti; rjmp USART_UDRE; UDR0 Empty Handler
  reti; rjmp USART_TXC; USART TX Complete Handler
  reti; rjmp ANA_COMP; Analog Comparator Handler
  reti; rjmp EXT_INT2; IRQ2 Handler
  reti; rjmp TIM0_COMP; Timer0 Compare Handler
  reti; rjmp EE_RDY; EEPROM Ready Handler
  reti; rjmp SPM_RDY; Store Program memory Ready

Init:

  ldi temp, low (RAMEND)  
  out SPL, temp
  ldi temp, high (RAMEND)
  out SPH, temp    
  sbi ACSR, 7      
  ldi temp, 0b10000000 
  out MCUCR, temp





  ldi temp, (1 << OCIE0)
  out TIMSK, temp    
          

  ldi temp, 0x1D
  out OCR0, temp
  ldi temp, (1 << PSR10)  
  out SFIOR, temp 


  ldi temp, (1 << WGM01) | (1 << CS02)  
  out TCCR0, temp   



ldi ZL, low (lcd_com_reg)
  ldi ZH, high (lcd_com_reg)

; Function Set
  ldi lcd_data, 0b00111000  
  st Z, lcd_data
  rcall long_delay_10ms    

; Display ON/OFF Control
  ldi lcd_data, 0b00001110  
  st Z, lcd_data
  rcall long_delay_10ms   

;Display Clear
  ldi lcd_data, 0b00000001 
  st Z, lcd_data
  rcall long_delay_10ms    

; Entry Mode Set
  ldi lcd_data, 0b00000110  
  st Z, lcd_data
  rcall long_delay_10ms   


  ldi ZL, low (lcd_data_reg)
  ldi ZH, high (lcd_data_reg)

  in last_encoder_state, PINB
  andi last_encoder_state, 0b10010000

  ldi againstCounter, 0x02

  sei  
  

Infinite_loop:
	rcall long_delay_1

	cpi permition, 0x01	
	breq Infinite_loop

    ldi little_letter, 0x61
    mov encoder_data, little_letter

    in next_encoder_state, PINB
    andi next_encoder_state, 0b10010000

  cp next_encoder_state, last_encoder_state
  breq Next_iterate
  cpi last_encoder_state, 0b00000000 
  brne Next_iterate; 

  cpi next_encoder_state, 0b00010000
  breq Decr_state

  cpi next_encoder_state, 0b10000000
  breq Incr_state
  


  cpi againstCounter, 0x00
  brne Next_iterate
	ldi	againstCounter, 0x02 
	ldi lcd_data, 0b11000000  
	st Z, lcd_data
	mov little_letter, encoder_data

	mov little_letter, encoder_data  
	mov lcd_data, little_letter
  
	st Z, lcd_data    
	rcall long_delay_10ms
	  
	mov last_encoder_state, next_encoder_state




  rjmp Next_iterate
 
  
  
 
TIM0_COMP: 
  
  	ldi permition, 0x01
 	reti 


Next_iterate:  
  in temp, PINB  
  andi temp, 0b00100000

  tst temp  
  brne Led_action    
  rjmp Infinite_loop


Incr_state:
  inc encoder_data  ;encoder_data++
  dec againstCounter
  cpi encoder_data, 0x61
  brcs to_z

  rjmp Infinite_loop 

  to_z:
    ldi encoder_data, 0x7A
    rcall

  
Decr_state:
  dec encoder_data ;encoder_data--
  dec againstCounter
  cpi encoder_data, 0x7A
    brlo to_a

    rjmp Infinite_loop

    to_a:
      ldi encoder_data, 0x61
      rcall 
  
Led_action:

    ldi lcd_data, 0x01
	rcall long_delay_10ms

  rjmp Infinite_loop




long_delay_1:


  ldi long_delay_low, 0x00
  ldi long_delay_high, 0x24  

long_loop_1:  

  rcall short_delay  
  sbiw long_delay_high: long_delay_low, 0b00000001 
  brne long_loop_1 

  ret    


long_delay_10ms:


  ldi long_delay_low, 0x5D
  ldi long_delay_high, 0x00

long_loop_10: 

  rcall short_delay  
  sbiw long_delay_high: long_delay_low, 0b00000001  
  brne long_loop_10  

  ret     


long_delay:

	ldi long_delay_low, 0x09
	ldi long_delay_high, 0x00

short_delay:  

  nop
  ldi counter, 0xC5

short_loop :      
  nop
  dec counter
  brne short_loop  

  ret 

.EXIT
