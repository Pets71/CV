--Package for defining the enum operation to all.
package operation_package is
    type op_type is 
    (ADDWF, ANDWF, CLRF, CLRW, COMF, DECF, DECFSZ, INCF, INCFSZ, IORWF, MOVF, MOVWF, NOP, RLF, RRF, SUBWF, SWAPF, XORWF, BCF, BSF, BTFSC, BTFSS, ADDLW, ANDLW, CALL, CLRWDT, GOTO, IORLW, MOVLW, RETFIE, RETLW, RETRN, SLEEP, SUBLW, XORLW, ERR);
    type possible_states is
    (iFETCH, Mread, Execute, Mwrite);
end operation_package;

