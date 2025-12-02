------------------------------
--Operation package
------------------------------
--Package for defining the enum operations used in the PIC.
--op_type defines all of the instructions used in the PIC.
----RETURN is renamed to RETRN, since return is a command in VHDL, and therefore not allowed.
--possible_states defines all of the states gone through in the execution cycle of an instruction in the PIC.


package operation_package is
    type op_type is 
    (ADDWF, ANDWF, CLRF, CLRW, COMF, DECF, DECFSZ, INCF, INCFSZ, IORWF, MOVF, MOVWF, NOP, RLF, RRF, SUBWF, SWAPF, XORWF, BCF, BSF, BTFSC, BTFSS, ADDLW, ANDLW, CALL, CLRWDT, GOTO, IORLW, MOVLW, RETFIE, RETLW, RETRN, SLEEP, SUBLW, XORLW, ERR);
    type possible_states is
    (iFETCH, Mread, Execute, Mwrite);
end operation_package;

