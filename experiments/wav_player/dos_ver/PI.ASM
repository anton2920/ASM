        PAGE    55, 132
        .386

        ; File inclusions
        INCLUDE .\ALL_D.ASM

CODE    SEGMENT para 'CODE' PUBLIC USE16
        ASSUME  CS:CODE, DS:DATA, SS:CODE

        EXTRN   WRITE:PROC
        EXTRN   IPRINT:PROC
        EXTRN   EIPRINT:PROC
        EXTRN   LSTRLEN:PROC
        EXTRN   LPUTCHAR:PROC

        PUBLIC PRINT_DEV_INFO
PRINT_DEV_INFO  PROC
        ; Initializing function's stack frame
        PUSH    BP
        MOV     BP, SP

        ; I/O flow
        PUSH    LEN_INFO_RATE
        LEA     DX, INFO_RATE
        PUSH    DX
        PUSH    STDOUT
        CALL    WRITE
        ADD     SP, 06H

        PUSH    DWORD PTR [BP + FIRST_ARG]
        CALL    EIPRINT
        ADD     SP, 04H

        PUSH    LEN_INFO_HZ
        LEA     DX, INFO_HZ
        PUSH    DX
        PUSH    STDOUT
        CALL    WRITE
        ADD     SP, 06H

        PUSH    LEN_INFO_SIZE
        LEA     DX, INFO_SIZE
        PUSH    DX
        PUSH    STDOUT
        CALL    WRITE
        ADD     SP, 06H

        PUSH    WORD PTR [BP + SECOND_ARG + SIZEOF_WORD]
        CALL    IPRINT
        ADD     SP, 02H

        PUSH    LEN_INFO_BITS
        LEA     DX, INFO_BITS
        PUSH    DX
        PUSH    STDOUT
        CALL    WRITE
        ADD     SP, 06H

        ; Main part
        MOV     AX, [BP + THIRD_ARG + SIZEOF_WORD]
        CMP     AX, 01H
        JNE     STEREO_CHAN

        PUSH    LEN_INFO_CHANNELS_MONO
        LEA     DX, INFO_CHANNELS_MONO

        JMP     END_IF_CHAN

STEREO_CHAN:
        PUSH    LEN_INFO_CHANNELS_STEREO
        LEA     DX, INFO_CHANNELS_STEREO

END_IF_CHAN:
        PUSH    DX
        PUSH    STDOUT
        CALL    WRITE
        ADD     SP, 06H

        ; Destroying function's stack frame
        MOV     SP, BP
        POP     BP
        RET

PRINT_DEV_INFO  ENDP

        PUBLIC  PRINT_CUR_PLAY
PRINT_CUR_PLAY  PROC
        ; Initializing function's stack frame
        PUSH    BP
        MOV     BP, SP

        ; I/O flow
        PUSH    LEN_CURRENTLY_PLAYING
        LEA     DX, CURRENTLY_PLAYING
        PUSH    DX
        PUSH    STDOUT
        CALL    WRITE
        ADD     SP, 06H

        PUSH    WORD PTR [BP + FIRST_ARG]
        CALL    LSTRLEN
        ADD     SP, 02H

        PUSH    AX
        PUSH    WORD PTR [BP + FIRST_ARG]
        PUSH    STDOUT
        CALL    WRITE
        ADD     SP, 06H

        PUSH    0AH
        CALL    LPUTCHAR

        PUSH    0DH
        CALL    LPUTCHAR
        ADD     SP, 04H

        ; Destroying function's stack frame
        MOV     SP, BP
        POP     BP
        RET

PRINT_CUR_PLAY  ENDP

        PUBLIC  PRINT_FILE_INFO
PRINT_FILE_INFO PROC
        ; Initializing function's stack frame
        PUSH    EBP
        MOV     EBP, ESP
        HOUR_VAR        EQU     -4 ; DWORD
        MINUTE_VAR      EQU     -8 ; DWORD
        SECOND_VAR      EQU     -12 ; DWORD
        SUB     SP, 0CH ; Acquiring space for three variables

        ; Saving registers
        PUSH    EBX

        ; Initializing variables
        MOV     EBX, DWORD PTR [EBP + EFIRST_ARG]
        MOV     DWORD PTR [EBP + HOUR_VAR], 00H
        MOV     EAX, DWORD PTR [EBP + ESECOND_ARG]
        SUB     EAX, WAV_HEADER_SIZE
        XOR     EDX, EDX

        ; Main part
        IDIV    EBX ; duration in seconds

        XOR     EDX, EDX
        MOV     EBX, 60
        IDIV    EBX ; AX - minutes, DX - seconds
        MOV     DWORD PTR [EBP + MINUTE_VAR], EAX
        MOV     DWORD PTR [EBP + SECOND_VAR], EDX

        XOR     EDX, EDX
        IDIV    EBX

        TEST    EAX, EAX
        JZ      PRINT_FILE_INFO_NO_HR

        MOV     DWORD PTR [EBP + HOUR_VAR], EAX
        MOV     DWORD PTR [EBP + MINUTE_VAR], EDX

PRINT_FILE_INFO_NO_HR:
        PUSH    LEN_INFO_FILE_SIZE
        LEA     DX, INFO_FILE_SIZE
        PUSH    DX
        PUSH    STDOUT
        CALL    WRITE
        ADD     SP, 06H

        PUSH    DWORD PTR [EBP + ESECOND_ARG]
        CALL    PROPER_SIZE
        ADD     SP, 04H

        TEST    EAX, EAX
        JS      PRINT_FILE_INFO_BYTE

        PUSH    EAX
        CALL    EIPRINT
        ADD     SP, 04H

        PUSH    LEN_INFO_KIB
        LEA     DX, INFO_KIB
        PUSH    DX
        PUSH    STDOUT
        CALL    WRITE
        ADD     SP, 06H

        PUSH    DWORD PTR [EBP + ESECOND_ARG]
        CALL    EIPRINT
        ADD     SP, 04H

        PUSH    ')'
        CALL    LPUTCHAR

        PUSH    0AH
        CALL    LPUTCHAR

        PUSH    0DH
        CALL    LPUTCHAR
        ADD     SP, 06H

        JMP     PRINT_FILE_INFO_CONT

PRINT_FILE_INFO_BYTE:
        PUSH    DWORD PTR [EBP + ESECOND_ARG]
        CALL    EIPRINT
        ADD     SP, 04H

        PUSH    LEN_INFO_BYTE
        LEA     DX, INFO_BYTE
        PUSH    DX
        PUSH    STDOUT
        CALL    WRITE
        ADD     SP, 06H

PRINT_FILE_INFO_CONT:
        PUSH    LEN_INFO_FILE_DURATION
        LEA     DX, INFO_FILE_DURATION
        PUSH    DX
        PUSH    STDOUT
        CALL    WRITE
        ADD     SP, 06H

        CMP     DWORD PTR [EBP + HOUR_VAR], 00H
        JE      PRINT_FILE_INFO_CONT_CONT

        PUSH    DWORD PTR [EBP + HOUR_VAR]
        CALL    EIPRINT

        PUSH    'h'
        CALL    LPUTCHAR

        PUSH    ' '
        CALL    LPUTCHAR
        ADD     SP, 08H

PRINT_FILE_INFO_CONT_CONT:
        CMP     DWORD PTR [EBP + MINUTE_VAR], 00H
        JE      PRINT_FILE_INFO_CONT_CONT_CONT

        PUSH    DWORD PTR [EBP + MINUTE_VAR]
        CALL    EIPRINT

        PUSH    'm'
        CALL    LPUTCHAR

        PUSH    ' '
        CALL    LPUTCHAR
        ADD     SP, 08H

PRINT_FILE_INFO_CONT_CONT_CONT:
        PUSH    DWORD PTR [EBP + SECOND_VAR]
        CALL    EIPRINT

        PUSH    's'
        CALL    LPUTCHAR

        PUSH    0AH
        CALL    LPUTCHAR

        PUSH    0DH
        CALL    LPUTCHAR
        ADD     SP, 0AH

        ; Restoring registers
        POP     EBX

        ; Destroying function's stack frame
        MOV     ESP, EBP
        POP     EBP
        RET

PRINT_FILE_INFO ENDP

PROPER_SIZE     PROC
        ; Initializing function's stack frame
        PUSH    EBP
        MOV     EBP, ESP

        ; Saving registers
        PUSH    EBX

        ; Initializing variables
        MOV     EAX, [EBP + EFIRST_ARG]
        LEA     EBX, INFO_KIB

        ; Main part
PROPER_SIZE_KIB:
        SHR     EAX, 0AH

        TEST    EAX, EAX
        JNZ     PROPER_SIZE_MIB

        XOR     EAX, EAX
        DEC     EAX

        JMP     PROPER_SIZE_EXIT

PROPER_SIZE_MIB:
        SHR     EAX, 0AH

        TEST    EAX, EAX
        JNZ     PROPER_SIZE_GIB

        MOV     BYTE PTR [EBX + 1], 'k'

        MOV     EAX, [EBP + EFIRST_ARG]
        SHR     EAX, 0AH

        JMP PROPER_SIZE_EXIT

PROPER_SIZE_GIB:
        SHR     EAX, 0AH

        TEST    EAX, EAX
        JNZ     PROPER_SIZE_GIB_OK

        MOV     BYTE PTR [EBX + 1], 'M'

        MOV     EAX, [EBP + EFIRST_ARG]
        SHR     EAX, 14H

        JMP PROPER_SIZE_EXIT

PROPER_SIZE_GIB_OK:
        MOV     BYTE PTR [EBX + 1], 'G'

PROPER_SIZE_EXIT:
        ; Restoring registers
        POP     EBX
        
        ; Destroying function's stack frame
        MOV     ESP, EBP
        POP     EBP
        RET

PROPER_SIZE     ENDP

CODE    ENDS
        END
