	PROCESSOR 16F876A

	#INCLUDE <P16F876A.INC>



; ---변수 선언---

VARIABLE	W_TEMP		= 20H
VARIABLE	STATUS_TEMP	= 21H
VARIABLE	INT_CNT		= 22H
VARIABLE	D_10SEC		= 23H
VARIABLE	D_1SEC		= 24H
VARIABLE	DISP_CNT	= 25H
VARIABLE	COM_A		= 26H
VARIABLE	COM_B		= 27H


; MAIN PROGRAM

	ORG		00H
	GOTO		START_UP
	ORG		04H

; ISR 시작 번지
	MOVWF		W_TEMP		; 현재 사용되고 있는 W REG를 저장
	SWAPF		STATUS, W
	MOVWF		STATUS_TEMP
	CALL		DISP		; DISPLAY 부 프로그램
	SWAPF		STATUS_TEMP, W	; 저장된 내용으로 복원
	MOVWF		STATUS
	SWAPF		W_TEMP, F
	SWAPF		W_TEMP, W
	BCF			INTCON, 2
	RETFIE
	
; DISPLAY ROUTINE
DISP

;7-segment의 표시 숫자가 2자리이므로 두 자리를 순차적으로 표시해야한다.
; 따라서 이 프로그램에 들어오는 횟수를 확인하여 처음 들어오는 경우와
; 다음 들어오는 경우를 구분하여 동작해야한다.
; < 처음 들어올 때 > 와 < 다음 들어올 때 > 를 구분하기

	INCF		DISP_CNT
	BTFSC		DISP_CNT, 0
	GOTO		DISP1
	GOTO		DISP2

; < 처음 들어올 때 >
DISP1
	MOVLW		B'00000000'
	MOVWF		PORTA
	
	MOVF		D_10SEC, W
	CALL		CONV
	MOVWF		PORTC
	
	MOVLW		B'00000010'
	MOVWF		PORTA
		
	RETURN

; < 다음 들어올 때 >
DISP2
	MOVLW		B'00000000'
	MOVWF		PORTA
	
	MOVF		D_1SEC, W
	CALL		CONV
	MOVWF		PORTC
	
	MOVLW		B'00000001'
	MOVWF		PORTA
	

	INCF		INT_CNT
	RETURN

; main program 시작
START_UP	
	BSF			STATUS,RP0	; RAM BANK 1 선택
	MOVLW		B'00000000'	; PORT I/O 선택 
	MOVWF		TRISA
	MOVWF		TRISC
	MOVLW		B'00000111'
	MOVWF		ADCON1

; INTERRUPT 시간 설정 --- 2.048msec 주기
	MOVLW		B'00000010'	; 2.048msec
	MOVWF		OPTIONR
	BCF			STATUS,RP0	; RAM BANK 0 선택
	
	CLRF		DISP_CNT
	
	BSF			INTCON, 5	; TIMER INTERRUPT ENABLE
	BSF			INTCON, 7	; GLOBAL INT. ENABLE
	GOTO		MAIN_ST
	
MAIN_ST
; 여기서부터 USER PROGRAM 작성
; 변수 초기화
; INT_CNT=0, D_10SEC=0, D_1SEC=0, key_IN=0
	CLRF		INT_CNT
	CLRF		D_10SEC
	CLRF		D_1SEC
	
M_LOOP
; interrupt가 들어온 횟수 확인 (시간계수)
	MOVLW		.250
	SUBWF		INT_CNT, W
	BTFSS		STATUS, ZF
	GOTO		XLOOP
	
; 1sec 마다 들어오는 부분
CK_LOOP
	CLRF		INT_CNT		; 다음 1초를 기다리기 위한 초기화
	INCF		D_1SEC		; 1초 단위 변수 증가
	MOVLW		.10
	SUBWF		D_1SEC, W
	BTFSS		STATUS, ZF
	GOTO		XLOOP

; 10sec 마다 들어오는 부분
	CLRF		D_1SEC		; 다음 10초를 기다리기 위한 초기화
	INCF		D_10SEC		; 10초 단위 변수 증가
	MOVLW		.10
	SUBWF		D_10SEC, W
	BTFSC		STATUS, ZF
	CLRF		D_10SEC		; 10초 단위를 초기화
	GOTO		XLOOP
	
; 나머지 시간 동안 사용자 기능을 수행하기 위한 프로그램 영역

XLOOP
; key 확인하여 key에 따른 기능 수행
; 기능에 따른 부저 울리기 등
	GOTO		M_LOOP
	
CONV
	ANDLW		0FH
	ADDWF		PCL
	
	RETLW		B'00000011'	; '0'
	RETLW		B'10011111'	; '1'
	RETLW		B'00100101'	; '2'
	RETLW		B'00001101'	; '3'
	RETLW		B'10011001'	; '4'
	RETLW		B'01001001'	; '5'
	RETLW		B'01000001'	; '6'
	RETLW		B'00011011'	; '7'
	RETLW		B'00000001'	; '8'
	RETLW		B'00001001'	; '9'
	RETLW		B'11111101'	; '-'
	RETLW		B'11111111'	; ' '
	RETLW		B'11100101'	; 'C'
	RETLW		B'11111110'	; '.'
	RETLW		B'01100001'	; 'E'
	RETLW		B'01110001'	; 'F'
	
	
	END