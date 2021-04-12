	PROCESSOR 16F876A

	#INCLUDE <P16F876A.INC>


VARIABLE	WDT_CNT		= 20H
VARIABLE	W_TEMP		= 21H
VARIABLE	STATUS_TEMP 	= 22H
	

; MAIN PROGRAM

	ORG		00H
	GOTO	START

	ORG	04H
ISR
	MOVWF	W_TEMP		; W REG PUSH
	SWAPF	STATUS,W	;
	MOVWF	STATUS_TEMP	; STATUS REG PUSH

;	CLRWDT

	SWAPF	STATUS_TEMP,W	
	MOVWF	STATUS		; STATUS REG POP
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	; W REG POP
	BCF		INTCON,2	; INTERRUT FLAG CLEAR
	RETFIE				; GIE SET AND RETURN



; WATCHDOG 시간 설정 --- 18mSEC 주기 
START
	BSF		STATUS, RP0
	MOVLW	B'00000000'
	MOVWF	TRISC
	MOVLW	B'00000010'
	MOVWF	OPTIONR
	MOVLW	B'00000111'
	MOVWF	ADCON1
	BSF		INTCON,5	
	BSF		INTCON,7
	BCF		STATUS, RP0

	INCF	WDT_CNT, F
	MOVF	WDT_CNT, W
	MOVWF	PORTC
	
LLLP
	NOP
	GOTO		LLLP
	
	END

