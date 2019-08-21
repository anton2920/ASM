        PAGE    55,132
	.386

        ; File inclusions
        INCLUDE .\ALL_D.ASM

CODE	SEGMENT para 'CODE' PUBLIC USE16
        ASSUME CS:CODE, DS:DATA, SS:STACK

	PUBLIC	WRITE
WRITE	PROC
	; Initializing function's stack frame
	PUSH 	BP
	MOV     BP, SP

        ; Saving registers
        PUSH    BX

	; Syscall
	MOV	AH, 40H
	MOV	BX, [BP + FIRST_ARG]
	MOV	CX, [BP + THIRD_ARG]
	MOV	DX, [BP + SECOND_ARG]
	INT	21H

        MOV     DX, AX

        JNC     WRITE_EXIT

        MOV     AX, -1

WRITE_EXIT:
        ; Restoring registers
        POP     BX

	; Destroying function's stack frame
        MOV     SP, BP
	POP	BP
	RET


WRITE	ENDP

        PUBLIC  READ
READ    PROC
        ; Initializing function's stack frame
        PUSH    BP
        MOV     BP, SP

        ; Saving registers
        PUSH    BX

        ; Syscall
        MOV     AH, 3FH
        MOV     BX, [BP + FIRST_ARG]
        MOV     CX, [BP + THIRD_ARG]
        MOV     DX, [BP + SECOND_ARG]
        INT     21H

        JNC     READ_EXIT

        MOV     DX, AX

        MOV     AX, -1

READ_EXIT:
        ; Restoring registers
        POP     BX

        ; Destroying function's stack frame
        MOV     SP, BP
        POP     BP
        RET

READ    ENDP

        PUBLIC  OPEN
OPEN    PROC
        ; Initializing function's stack frame
        PUSH    BP
        MOV     BP, SP

        ; Syscall
        MOV     AX, [BP + SECOND_ARG]
        MOV     AH, 3DH
        MOV     DX, [BP + FIRST_ARG]
        INT     21H

        JC OPEN_ERR

        JMP OPEN_EXIT

OPEN_ERR:
        MOV     AX, -1

OPEN_EXIT:
        ; Destroying function's stack frame
        MOV     SP, BP
        POP     BP
        RET

OPEN    ENDP

        PUBLIC  CLOSE
CLOSE   PROC
        ; Initializing function's stack frame
        PUSH    BP
        MOV     BP, SP

        ; Saving registers
        PUSH    BX

        ; Syscall
        MOV     AH, 3EH
        MOV     BX, [BP + FIRST_ARG]
        INT     21H

        ; Restoring registers
        POP     BX

        ; Destroying function's stack frame
        MOV     SP, BP
        POP     BP
        RET

CLOSE   ENDP

        PUBLIC  LSTRLEN
LSTRLEN PROC
        ; Initializing function's stack frame
        PUSH    BP
        MOV     BP, SP

        ; Saving registers
        PUSH    DI
        PUSH    SI

        ; Initializing variables
        MOV     DI, [BP + FIRST_ARG]
        XOR     AX, AX
        MOV     CX, 0FFFFH
        CLD

        ; Main part
        REPNZ   SCASB
        JNE     LSTRLEN_NOTFOUND

        SUB     CX, 0FFFFH
        NEG     CX
        DEC     CX

        MOV     AX, CX

        JMP LSTRLEN_FIN

LSTRLEN_NOTFOUND:
        MOV     AX, -1

LSTRLEN_FIN:
        ; Restoring registers
        POP     SI
        POP     DI

        ; Destroying function's stack frame
        MOV     SP, BP
        POP     BP
        RET

LSTRLEN ENDP

        PUBLIC  LPUTCHAR
LPUTCHAR        PROC
        ; Initializing function's stack frame
        PUSH    BP
        MOV     BP, SP

        ; Syscall
        MOV     AH, 02H
        MOV     DX, [BP + FIRST_ARG]
        INT     21H

        ; Destroying function's stack frame
        MOV     SP, BP
        POP     BP
        RET

LPUTCHAR        ENDP

        PUBLIC  PLAY_MORE
PLAY_MORE       PROC
        ; Initializing function's stack frame
        PUSH    BP
        MOV     BP, SP

        ; Saving registers
        PUSH    BX

PLAY_MORE_BEGIN:
        ; I/O flow
        PUSH    LEN_PLAY_AGAIN
        LEA     DX, PLAY_AGAIN
        PUSH    DX
        PUSH    STDOUT
        CALL    WRITE
        ADD     SP, 06H

        PUSH    MENUBUF_LEN
        LEA     DX, MENUBUF
        PUSH    DX
        PUSH    STDIN
        CALL    READ
        ADD     SP, 06H

        ; Main part
        LEA     BX, MENUBUF

        XOR     CX, CX
        MOV     CL, [BX]

        CMP     AX, 01H
        JE      TEST_NL

        CMP     AX, 02H
        JE      TEST_YN

TEST_NL:
        CMP     CL, 0AH
        JE      ANS_NO

        JMP     NO_CMD

TEST_YN:
        CMP     CL, 'Y'
        JE      ANS_YES

        CMP     CL, 'y'
        JE      ANS_YES

        CMP     CL, 'N'
        JE      ANS_NO

        CMP     CL, 'n'
        JE      ANS_NO

        JMP     NO_CMD

ANS_YES:
        XOR     AX, AX
        INC     AX

        JMP PLAY_MORE_EXIT

ANS_NO:
        XOR     AX, AX

        JMP PLAY_MORE_EXIT

NO_CMD:
        PUSH    LEN_PLAY_AGAIN_ERR
        LEA     DX, PLAY_AGAIN_ERR
        PUSH    DX
        PUSH    STDOUT
        CALL    WRITE
        ADD     SP, 06H

        JMP     PLAY_MORE_BEGIN

PLAY_MORE_EXIT:
        ; Restoring registers
        POP     BX

        ; Destroying function's stack frame
        MOV     SP, BP
        POP     BP
        RET

PLAY_MORE       ENDP

        PUBLIC  IPRINT
IPRINT  PROC
        ; Initializing function's stack frame
        PUSH    BP
        MOV     BP, SP

        ; Initializing variables
        MOV     AX, [BP + FIRST_ARG]

        ; Main part
IPRINT_IF:
        CMP     AX, 00H
        JG      IPRINT_ELSE

IPRINT_THEN:
        TEST    AX, AX
        JNZ     IPRINT_PRINT_N

        PUSH    00H
        CALL    LPUTCHAR
        ADD     SP, 02H

        JMP     IPRINT_FIN

IPRINT_PRINT_N:
        ; Saving registers
        PUSH    AX

        PUSH    '-'
        CALL    LPUTCHAR
        ADD     SP, 02H

        ; Restoring registers
        POP     AX

        NEG     AX

IPRINT_ELSE:
        ; Saving registers
        PUSH    AX

        PUSH    AX
        CALL    NUMLEN
        ADD     SP, 02H

        ; Restoring registers
        POP     CX

        ; Saving registers
        PUSH    AX

        PUSH    AX
        PUSH    CX
        CALL    REVERSE
        ADD     SP, 04H

        ; Restoring registers
        POP     AX

        PUSH    AX
        LEA     DX, NUM_BUF
        PUSH    DX
        PUSH    STDOUT
        CALL    WRITE
        ADD     SP, 06H

IPRINT_FIN:
        ; Destroying function's stack frame
        MOV     SP, BP
        POP     BP
        RET

IPRINT  ENDP

REVERSE PROC
        ; Initializing function's stack frame
        PUSH    BP
        MOV     BP, SP

        ; Saving registers
        PUSH    DI
        PUSH    BX

        ; Initializing variables
        MOV     AX, [BP + FIRST_ARG]
        MOV     BX, [BP + SECOND_ARG]
        DEC     BX
        MOV     CX, 0AH
        LEA     DI, NUM_BUF

        ; Main part
REVERSE_MAIN_LOOP:
        TEST    BX, BX
        JS      REVERSE_MAIN_LOOP_END

        XOR     DX, DX
        IDIV    CX

        ADD     DL, '0'
        MOV     [DI + BX], DL
        DEC     BX

        JMP REVERSE_MAIN_LOOP

REVERSE_MAIN_LOOP_END:
        ; Restoring registers
        POP     BX
        POP     DI

        ; Destroying function's stack frame
        MOV     SP, BP
        POP     BP
        RET

REVERSE ENDP

        PUBLIC  FIND_SIZE
FIND_SIZE       PROC
        ; Initializing function's stack frame
        PUSH    BP
        MOV     BP, SP

        ; Main part
        PUSH    SEEK_END
        PUSH    00H
        PUSH    00H
        PUSH    WORD PTR [BP + FIRST_ARG]
        CALL    LSEEK
        ADD     SP, 08H

        ; Saving registers
        PUSH    AX
        PUSH    DX

        PUSH    SEEK_SET
        PUSH    00H
        PUSH    00H
        PUSH    WORD PTR [BP + FIRST_ARG]
        CALL    LSEEK
        ADD     SP, 08H

        ; Restoring registers
        POP     DX
        POP     AX

        ; Destroying function's stack frame
        MOV     SP, BP
        POP     BP
        RET

FIND_SIZE       ENDP

NUMLEN  PROC
        ; Initializing function's stack frame
        PUSH    BP
        MOV     BP, SP

        ; Saving registers
        PUSH    BX

        ; Initializing variables        
        MOV     AX, [BP + FIRST_ARG]
        XOR     BX, BX
        MOV     CX, 0AH

        ; Main part
NUMLEN_LOOP:
        TEST    AX, AX
        JZ      NUMLEN_LOOP_END

        XOR     DX, DX
        IDIV    CX

        INC     BX

        JMP     NUMLEN_LOOP

NUMLEN_LOOP_END:
        ; Returning value
        MOV     AX, BX

        ; Restoring registers
        POP     BX

        ; Destroying function's stack frame
        MOV     SP, BP
        POP     BP
        RET      

NUMLEN  ENDP

        PUBLIC  TUNE_DEVICE
TUNE_DEVICE     PROC
        ; Initializing function's stack frame
        PUSH    BP
        MOV     BP, SP

        ; Main part
        ; Resetting DSP
        MOV     DX, wSBCBaseAddx
        ADD     DL, 6

        MOV     AL, 1
        OUT     DX, AL

        SUB     AL, AL

TUNE_DEVICE_DELAY:
        DEC     AL
        JNZ     TUNE_DEVICE_DELAY

        OUT     DX, AL

        XOR     CX, CX

TUNE_DEVICE_EMPTY:
        MOV     DX, wSBCBaseAddx
        ADD     DL, 0EH

        IN      AL, DX

        TEST    AL, AL
        JNS     TUNE_DEVICE_NEXT

        SUB     DL, 04H
        IN      AL, DX

        CMP     AL, 0AAH
        JNE     TUNE_DEVICE_ERR

TUNE_DEVICE_OK:
        ; Returning value
        MOV     AX, 1

        JMP TUNE_DEVICE_EXIT

TUNE_DEVICE_NEXT:
        LOOP    TUNE_DEVICE_EMPTY

TUNE_DEVICE_ERR:
        ; Returning value
        MOV     AX, -1

TUNE_DEVICE_EXIT:
        ; Saving registers
        PUSH    AX       

        PUSH    DWORD PTR [BP + FIRST_ARG]
        CALL    SET_TIME_CONST
        ADD     SP, 04H

        ; Turn on speakers
        PUSH    0D1H
        CALL    WRITE_DSP
        ADD     SP, 02H

        ; Restoring registers
        POP     AX

        ; Destroying function's stack frame
        MOV     SP, BP
        POP     BP
        RET

TUNE_DEVICE     ENDP

SET_TIME_CONST  PROC
        ; Initializing function's stack frame
        PUSH    EBP
        MOV     EBP, ESP

        ; Initializing variables
        MOV     EAX, 1234DCH
        MOV     ECX, [EBP + EFIRST_ARG]

        ; Main part
        IDIV    ECX

       ;SUB     EAX, 10000H
       ;NEG     EAX              ; Correct time value

        MOV     EDX, EAX

        MOV     AL, 36H
        OUT     43H, AL

        MOV     AL, DL
        OUT     40H, AL

        MOV     AL, DH
        OUT     40H, AL

        ; Destroying function's stack frame
        MOV     ESP, EBP
        POP     EBP
        RET

SET_TIME_CONST  ENDP

        PUBLIC  WRITE_DSP
WRITE_DSP       PROC
        ; Initializing function's stack frame
        PUSH    BP
        MOV     BP, SP

        ; Initializing variables
        MOV     DX, wSBCBaseAddx
        ADD     DL, 0CH
        MOV     CX, [BP + FIRST_ARG]

        ; Main part
WRITE_DSP_BUSY:
        IN      AL, DX
        TEST    AL, AL
        JS      WRITE_DSP_BUSY

        MOV     AL, CL
        OUT     DX, AL

        ; Destroying function's stack frame
        MOV     SP, BP
        POP     BP
        RET

WRITE_DSP       ENDP

        PUBLIC  READ_DSP
READ_DSP        PROC
        ; Initializing function's stack frame
        PUSH    BP
        MOV     BP, SP

        ; Initializing variables
        MOV     DX, wSBCBaseAddx
        ADD     DL, 0EH

        ; Main part
READ_DSP_BUSY:
        IN      AL, DX
        TEST    AL, AL
        JNS      READ_DSP_BUSY

        SUB     DL, 04H
        IN      AL, DX

        ; Destroying function's stack frame
        MOV     SP, BP
        POP     BP
        RET

READ_DSP        ENDP
        PUBLIC  LSEEK
LSEEK   PROC
        ; Initializing function's stack frame
        PUSH    BP
        MOV     BP, SP

        ; Saving registers
        PUSH    BX

        ; Syscall
        MOV     AX, [BP + FOURTH_ARG]
        MOV     AH, 42H
        MOV     BX, [BP + FIRST_ARG]
        MOV     CX, [BP + SECOND_ARG]
        MOV     DX, [BP + THIRD_ARG]
        INT     21H

        JNC     LSEEK_EXIT

        MOV     DX, AX
        MOV     AX, -1

LSEEK_EXIT:
        ; Restoring registers
        POP     BX
        
        ; Destroying function's stack frame
        MOV     SP, BP
        POP     BP
        RET

LSEEK   ENDP

        PUBLIC  EIPRINT
EIPRINT PROC
        ; Initializing function's stack frame
        PUSH    EBP
        MOV     EBP, ESP

        ; Initializing variables
        MOV     EAX, [EBP + EFIRST_ARG]

        ; Main part
EIPRINT_IF:
        CMP     EAX, 00H
        JG      EIPRINT_ELSE

EIPRINT_THEN:
        TEST    EAX, EAX
        JNZ     EIPRINT_PRINT_N

        PUSH    00H
        CALL    LPUTCHAR
        ADD     ESP, 02H

        JMP     EIPRINT_FIN

EIPRINT_PRINT_N:
        ; Saving registers
        PUSH    EAX

        PUSH    '-'
        CALL    LPUTCHAR
        ADD     ESP, 02H

        ; Restoring registers
        POP     EAX

        NEG     EAX

EIPRINT_ELSE:
        ; Saving registers
        PUSH    EAX

        PUSH    EAX
        CALL    ENUMLEN
        ADD     ESP, 04H

        ; Restoring registers
        POP     ECX

        ; Saving registers
        PUSH    EAX

        PUSH    EAX
        PUSH    ECX
        CALL    EREVERSE
        ADD     SP, 08H

        ; Restoring registers
        POP     EAX

        PUSH    AX
        LEA     DX, NUM_BUF
        PUSH    DX
        PUSH    STDOUT
        CALL    WRITE
        ADD     ESP, 06H

EIPRINT_FIN:
        ; Destroying function's stack frame
        MOV     ESP, EBP
        POP     EBP
        RET

EIPRINT ENDP

EREVERSE        PROC
        ; Initializing function's stack frame
        PUSH    EBP
        MOV     EBP, ESP

        ; Saving registers
        PUSH    EDI
        PUSH    EBX

        ; Initializing variables
        MOV     EAX, [EBP + EFIRST_ARG]
        MOV     EBX, [EBP + ESECOND_ARG]
        DEC     EBX
        MOV     ECX, 0AH
        LEA     EDI, NUM_BUF

        ; Main part
EREVERSE_MAIN_LOOP:
        TEST    EBX, EBX
        JS      EREVERSE_MAIN_LOOP_END

        XOR     EDX, EDX
        IDIV    ECX

        ADD     DL, '0'
        MOV     [EDI + EBX], DL
        DEC     EBX

        JMP EREVERSE_MAIN_LOOP

EREVERSE_MAIN_LOOP_END:
        ; Restoring registers
        POP     EBX
        POP     EDI

        ; Destroying function's stack frame
        MOV     ESP, EBP
        POP     EBP
        RET

EREVERSE        ENDP

ENUMLEN PROC
        ; Initializing function's stack frame
        PUSH    EBP
        MOV     EBP, ESP

        ; Saving registers
        PUSH    EBX

        ; Initializing variables        
        MOV     EAX, [EBP + EFIRST_ARG]
        XOR     EBX, EBX
        MOV     ECX, 0AH

        ; Main part
ENUMLEN_LOOP:
        TEST    EAX, EAX
        JZ      ENUMLEN_LOOP_END

        XOR     EDX, EDX
        IDIV    ECX

        INC     EBX

        JMP     ENUMLEN_LOOP

ENUMLEN_LOOP_END:
        ; Returning value
        MOV     EAX, EBX

        ; Restoring registers
        POP     EBX

        ; Destroying function's stack frame
        MOV     ESP, EBP
        POP     EBP
        RET      

ENUMLEN ENDP

        PUBLIC  GET_CURR_TIME
GET_CURR_TIME   PROC
        ; Initializing function's stack frame
        PUSH    BP
        MOV     BP, SP

        ; Saving registers
        PUSH    ES

        ; Initializing variables
        XOR     AX, AX
        MOV     ES, AX
        MOV     EAX, ES:[46CH]

        ; Restoring registers
        POP     ES

        ; Destroying function's stack frame
        MOV     SP, BP
        POP     BP
        RET

GET_CURR_TIME   ENDP

CODE	ENDS
        END                                                 
