
.include "m8515def.inc"



.def temp = r16	;������ ����������� ���������
.def dig = r17	;������ ��������� ��������� �� ��������� ����� (� hex-������)
.def counter = r18		;�������� ����� � ��������� ��������� ��������
.def counter1 = r20		;�������� ������� ��������� ����� ���������
.def plus = r19		;������, ���� ������ ���������, �� �������� �� �����
.def long_delay_low = r24	;�������� ���� ��������� ����� ��������
.def long_delay_high = r25	;������� ���� ��������� ����� ��������

;*** ����������� �������� ***

;������ ���� ���� ��������� ���������� ��������������� ����������
.EQU stat_7seg_left = 0xA000
;������ ���� ������ ��������� ���������� ��������������� ����������
.EQU stat_7seg_right = 0xB000
;������ ������� ��������� ����������/������� �����/��������� ���������� �������������� ����������
.EQU stat_7seg_control = 0xA004

;***** ������� �������� *****

.CSEG		;��������� ������� �������� ����
.ORG 0x0000	;��������� ������ ������� �������� ���� � ���'�� �������

; *** ������ ���������� ���������� ***

	rjmp Init; ������ ����������� �� ��������
	reti; rjmp EXT_INT0; IRQ0 Handler
	reti; rjmp EXT_INT1; IRQ1 Handler
	reti; rjmp TIM1_CAPT; Timer1 Capture Handler
	reti; rjmp TIM1_COMPA; Timer1 Compare A Handler
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

;*** ��������� ����������� ���������� ***

Init:

	ldi temp, low (RAMEND)	;����������� ��������� ����� SP
	out SPL, temp
	ldi temp, high (RAMEND)
	out SPH, temp	;������������ SP �� ������ �������� ������ Internal SRAM
	sbi ACSR, 7		;���������� �������� ����������� �����������

;���������� ������ �� ��������� ���'���� (��������� �� ���������� ����������)
	ldi temp, 0b10000000
	out MCUCR, temp

;�������� � ��������� �������������� �����������

;������������ �������� X �� ������ ��� ���� ��������� ���������� ����������
	ldi XL, low (stat_7seg_left)
	ldi XH, high (stat_7seg_left)

;������������ �������� Y �� ������ ����� ���� ��������� ���������� ����������
	ldi YL, low (stat_7seg_right)
	ldi YH, high (stat_7seg_right)

;������������ �������� Z �� ������ ������� ��������� ��������� �����������
	ldi ZL, low (stat_7seg_control)
	ldi ZH, high (stat_7seg_control)

;*** ���������� � ����������� ���� ***

Infinite_loop:	;����������� ����

	;��������� �����������
	ldi dig, 0x00	;�������� ��������� ��������, ��� ���������� �� ���������
	ldi plus, 0x11	;�������� ����� 0�11, �� ��� ���� ������������ ���������
	ldi counter1, 0x10	;���������� �������� ��������� ���������

Loop:; ���� ��������� ������������� ������� �� ���������

	st X, dig	;������ ����� �� ��� ���� ��������� ����������
	st Y, dig	;������ ����� �� ����� ���� ��������� ����������

	ldi temp, 0x00	;�������� �� ����� � ��������� �� ���������
	st Z, temp		;�������� �� ����� � ������ ��������� �����������

	rcall long_delay	;��������� �������� ��������� �� 2 �

	ldi temp, 0x0F	;�������� �� ����� � ������ �� ���������
	st Z, temp		;�������� �� ����� � ������ ��������� �����������

	rcall long_delay	;��������� �������� ��������� �� 2 �

	add dig, plus	;������ �� ����������� �������� ����� ����� 11h
	dec counter1	;�������� �������� ��������� ������� �������� �� 1

	breq Infinite_loop	;������� ���������, ���� �������� ������� 0
	rjmp Loop			;�������� �� ��������� �������� �������� ���������

;*** ϳ��������� ����� �������� ***

long_delay:
;* ���� � ��������� ���� ����������� ����� 18432 (4800h), �� �������� ���� ������� 2 ������

;* ��������� ������� ���������� ����������� ��� ������ � 7.3728 ��� ����:
;* 800 x ���������� �������� / (7.3728 * 1 000 000) = ���������� ��� � [�]

	ldi long_delay_low, 0x00;������������ � ��������� ���� ����������� ��������
	ldi long_delay_high, 0x48	;(4800h), �� ���� �������� �� 2 �

long_loop:	;��� ����� ����� 796 + 2 + 2 = 800 �����
	rcall short_delay		;������� ��������
	sbiw long_delay_high: long_delay_low, 0b00000001	;�������� � ���� ����� 1 (��������� ������� ���������)
	brne long_loop	;���� �� 0, ��������� ����
	ret			;���������� � ������� ��������

;*** ϳ��������� ������� �������� (������� ��� ��������� ������ ��������) ***
short_delay:	;��� ���������� ����� ���� 796 ����� ����� � rcall � ret

	nop
	ldi counter, 0xC5	;�������� �����
short_loop:
	nop
	dec counter
	brne short_loop	;������� ������������ �� �������� ���� (����������)
	ret			;���������� � ������� ��������	
.EXIT				;����� ��������
