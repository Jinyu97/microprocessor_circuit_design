	INCLUDE <P16F876A.INC>

	ORG 0

	BSF STATUS, RP1
	MOVLW 00H
	MOVWF EEADR
	MOVLW 41H
	MOVWF EEDATA
	BSF	STATUS, RP0
	BSF	EECON1, WREN
	MOVLW 055H
	MOVWF EECON2
	MOVLW 0AAH
	MOVWF EECON2
	BSF	EECON1, WR
LP7	BTFSC EECON1, WR
	GOTO LP7
	BCF	EECON1, WREN
	BCF	STATUS, RP0
	BCF STATUS, RP1

	GOTO $

	END



