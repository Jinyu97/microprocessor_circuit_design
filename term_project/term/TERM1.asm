		PROCESSOR 16F876A
		#INCLUDE <P16F876A.INC>
		
; 변수 선언
		VARIABLE	W_TEMP		=	20H
		VARIABLE	STATUS_TEMP	=	21H
		VARIABLE	INT_CNT		=	22H
		VARIABLE	D_10SEC		=	23H
		VARIABLE	D_1SEC		=	24H
		VARIABLE	DISP_CNT	=	25H
		VARIABLE	COM_A		=	26H
		VARIABLE	COM_B		=	27H
		VARIABLE	D_10MIN		=	28H
		VARIABLE	D_1MIN		=	29H
		
; MAIN PROGRAM

	ORG		00H
	GOTO	START_UP
	ORG		04H
	
; ISR 시작 번지
	MOVWF	W_TEMP ; 현재 사용되고 있는 W REG를 저장
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP
	CALL  	DISP ; DISPLAY 부 프로그램
	SWAPF 	STATUS_TEMP,W ; 저장된 내용으로 복원
	MOVWF 	STATUS
	SWAPF 	W_TEMP,F
	SWAPF 	W_TEMP,W
	BCF 	INTCON,2
	RETFIE
	
; DISPLAY ROUTINE
DISP
	INCF	DISP_CNT
	BTFSS	DISP_CNT, 0
	GOTO	DISP3


; 처음 들어올 때	
DISP4
	MOVLW	B'00000000'
	MOVWF	PORTA
	
	MOVF	D_10MIN, W
	CALL	CONV
	MOVWF	PORTC
	
	MOVLW	B'00001000'
	MOVWF	PORTA	
	
	INCF	INT_CNT
	RETURN	


DISP3
	MOVLW	B'00000000'
	MOVWF	PORTA
	
	MOVF	D_1MIN, W
	CALL	CONV
	MOVWF	PORTC
	
	MOVLW	B'00000100'
	MOVWF	PORTA	

	
	BTFSS	DISP_CNT, 1
	GOTO	DISP2
	
		
	INCF	INT_CNT

		
DISP1
	MOVLW	B'00000000'
	MOVWF	PORTA
	
	MOVF	D_10SEC, W
	CALL	CONV
	MOVWF	PORTC
	
	MOVLW	B'00000010'
	MOVWF	PORTA
	
	RETURN
	
; 다음 들어올 때
DISP2
	MOVLW	B'00000000'
	MOVWF	PORTA
	
	MOVF	D_1SEC, W
	CALL	CONV
	MOVWF	PORTC
	
	MOVLW	B'00000001'
	MOVWF	PORTA	
	
	INCF	INT_CNT
	RETURN	
	

	

	
; MAIN PROGRAM 시작
START_UP
	BSF 	STATUS,RP0 ; RAM BANK 1 선택
	MOVLW 	B'00000000' ; PORT I/O 선택
	MOVWF 	TRISA
	MOVWF	TRISC
	MOVLW 	B'00000111' ; PORT I/O 선택
	MOVWF	ADCON1

; INTERRUPT 시간 설정 --- 2.048msec 주기
	MOVLW 	B'00000010' ; 2.048msec
	MOVWF 	OPTION_REG
	BCF 	STATUS,RP0 ; RAM BANK 0 선택
	BSF 	INTCON,5 ; TIMER INTERRUPT ENABLE
	BSF 	INTCON,7 ; GLOBAL INT. ENABLE
	GOTO 	MAIN_ST

MAIN_ST
	CLRF	INT_CNT
	CLRF	D_10SEC
	CLRF	D_1SEC
	CLRF	D_10MIN
	CLRF	D_1MIN
	
M_LOOP
; interrupt가 들어온 횟수 확인(시간계수)
	MOVLW 	.244
	SUBWF 	INT_CNT,W
	BTFSS 	STATUS, Z
	GOTO 	XLOOP
; 1sec 마다 들어오는 부분
CK_LOOP
	CLRF 	INT_CNT ; 다음 1초를 기다리기 위한 초기화
	INCF 	D_1SEC ; 1초 단위 변수 증가
	MOVLW 	.10
	SUBWF 	D_1SEC,W
	BTFSS 	STATUS, Z
	GOTO 	XLOOP
; 10초마다 들어오는 부분
	CLRF 	D_1SEC ; 다음 10초를 기다리기 위한 초기화
	INCF 	D_10SEC ; 10초 단위 변수 증가
	MOVLW 	.6
	SUBWF 	D_10SEC,W
	BTFSC 	STATUS, Z
	CLRF 	D_10SEC ; 10초 단위를 초기화
	GOTO 	XLOOP
; 1분마다 들어오는 부분
;	CLRF 	D_1SEC ; 다음 10초를 기다리기 위한 초기화
	CLRF	D_10SEC
	INCF 	D_1MIN ; 10초 단위 변수 증가
	MOVLW 	.10
	SUBWF 	D_1MIN,W
	BTFSC 	STATUS, Z
	CLRF 	D_1MIN ; 10초 단위를 초기화
	GOTO 	XLOOP
; 10분마다 들어오는 부분
;	CLRF 	D_1SEC ; 다음 10초를 기다리기 위한 초기화
;	CLRF	D_10SEC
	CLRF	D_1MIN
	INCF 	D_10MIN ; 10초 단위 변수 증가
	MOVLW 	.6
	SUBWF 	D_10MIN,W
	BTFSC 	STATUS, Z
	CLRF 	D_10MIN ; 10초 단위를 초기화
	GOTO 	XLOOP

; 나머지 시간 동안 사용자 기능을 수행하기 위한 프로그램 영역


XLOOP
; KEY 확인하여 KEY에 따른 기능 수행
; 기능에 따른 부저 울리기 등
	GOTO	M_LOOP
	
CONV 
	ANDLW 	0FH ; W의 low nibble 값을 변환하자.
	ADDWF 	PCL,F ; PCL+변환 숫자값 --> PCL
; PC가 변경되므로 이 명령어 다음 수행 위
; 치가 변경되지요.
	RETLW 	B'00000011' ;'0'를 표시 하는 값이 W로 들어옴
	RETLW 	B'10011111' ; '1'를 표시 하는 값
	RETLW 	B'00100101' ; '2'를 표시 하는 값
	RETLW 	B'00001101' ; '3'를 표시 하는 값
	RETLW 	B'10011001' ; '4'를 표시 하는 값
	RETLW 	B'01001001' ; '5'를 표시 하는 값
	RETLW 	B'01000001' ; '6'를 표시 하는 값
	RETLW 	B'00011011' ; '7'를 표시 하는 값
	RETLW 	B'00000001' ; '8'를 표시 하는 값
	RETLW 	B'00001001' ; '9'를 표시 하는 값
	RETLW 	B'11111101' ; '-'를 표시 하는 값
	RETLW 	B'11111111' ; ' '를 표시 하는 값
	RETLW 	B'11100101' ; 'C'를 표시 하는 값
	RETLW 	B'11111110' ; '．'를 표시 하는 값
	RETLW 	B'01100001' ; 'E'를 표시 하는 값
	RETLW 	B'01110001' ; 'F'를 표시 하는 값



END