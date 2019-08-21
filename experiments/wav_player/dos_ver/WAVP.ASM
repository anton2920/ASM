        PAGE 55,132
	.386

        ; External declarations
        EXTRN   WRITE:PROC
        EXTRN   READ:PROC
        EXTRN   OPEN:PROC
        EXTRN   FIND_SIZE:PROC
        EXTRN   TUNE_DEVICE:PROC
        EXTRN   PRINT_DEV_INFO:PROC
        EXTRN   PRINT_CUR_PLAY:PROC
        EXTRN   PRINT_FILE_INFO:PROC
        EXTRN   LPUTCHAR:PROC
        EXTRN   WRITE_DSP:PROC
        EXTRN   READ_DSP:PROC
        EXTRN   IPRINT:PROC
        EXTRN   EIPRINT:PROC
        EXTRN   LSEEK:PROC
        EXTRN   GET_CURR_TIME:PROC

        ; File inclusions
        INCLUDE .\ALL_D.ASM

CODE	SEGMENT	para 'CODE' PUBLIC USE16
        ASSUME  CS:CODE, DS:DATA, SS:STACK

START:
	; Initializing .section .data
        MOV     AX, DATA
	    MOV	    DS, AX
        MOV     ES, AX
        XOR     SI, SI
        XOR     DI, DI

WAVP:
	; Initializing stack frame
        MOV     ESP, EBP
        file            EQU     -2 ; WORD
        file_size       EQU     -8 ; DWORD (4-byte aligned)
        rate            EQU     -12; DWORD (4-byte aligned)
        sizeb           EQU     -14; WORD
        chan            EQU     -16; WORD
        last_time       EQU     -24; DWORD (4-byte aligned)
        SUB     SP, 18H

	; Initializing variables
        MOV     DWORD PTR [BP + rate] , 00H
        MOV     WORD PTR [BP + sizeb], 00H
        MOV     WORD PTR [BP + chan] , 00H
        MOV     DWORD PTR [BP + last_time], 00H

	; I/O flow
        PUSH    LEN_HELLO
        LEA     DX, HELLO
        PUSH    DX
        PUSH    STDOUT
        CALL    WRITE
        ADD     SP, 6

        ; Main part. FPU
        FINIT

        ; Open .wav file
        PUSH    O_RDONLY
        LEA     DX, WAV_FILE
        PUSH    DX
        CALL    OPEN
        ADD     SP, 04H

        TEST    AX, AX
        JS      WAVP_ERROR

        MOV     WORD PTR [BP + file], AX

        PUSH    WORD PTR [BP + file]
        CALL    FIND_SIZE
        ADD     SP, 02H

        MOV     WORD PTR [BP + file_size], AX
        MOV     WORD PTR [BP + file_size + 2], DX

        ; Tune device
        PUSH    WAV_HEADER_SIZE
        LEA     DX, WAV_INFO_BUF
        PUSH    DX
        PUSH    WORD PTR [BP + file]
        CALL    READ
        ADD     SP, 06H

        TEST    AX, AX
        JS      WAVP_ERROR

        MOV     EAX, DWORD PTR [WAV_INFO_BUF + 24]
        MOV     DWORD PTR [BP + rate], EAX

        MOV     AX, WORD PTR [WAV_INFO_BUF + 34]
        MOV     WORD PTR [BP + sizeb], AX

        MOV     AX, WORD PTR [WAV_INFO_BUF + 22]
        MOV     WORD PTR [BP + chan], AX

        PUSH    DWORD PTR [BP + rate]
        CALL    TUNE_DEVICE
        ADD     SP, 04H

        TEST    AX, AX
        JS      WAVP_ERROR

        PUSH    WORD PTR [BP + chan]
        PUSH    WORD PTR [BP + sizeb]
        PUSH    DWORD PTR [BP + rate]
        CALL    PRINT_DEV_INFO
        ADD     SP, 08H

        PUSH    SEEK_SET
        PUSH    WAV_HEADER_SIZE
        PUSH    00H
        PUSH    WORD PTR [BP + file]
        CALL    LSEEK
        ADD     SP, 06H

WAVP_REPLAY_CONT:
        ; Dispay current song title
        LEA     DX, WAV_FILE
        PUSH    DX
        CALL    PRINT_CUR_PLAY
        ADD     SP, 02H

        PUSH    DWORD PTR [BP + file_size]
        PUSH    DWORD PTR [WAV_INFO_BUF + 28]
        CALL    PRINT_FILE_INFO
        ADD     SP, 08H

        PUSH    0AH
        CALL    LPUTCHAR
        ADD     SP, 02H

        MOV     ECX, WAV_HEADER_SIZE

WAVP_PLAY_LOOP:
        CMP     ECX, DWORD PTR [BP + file_size]
        JGE     PLAY_LOOP_END

        ; Saving registers
        PUSH    ECX

        PUSH    10H
        CALL    WRITE_DSP
        ADD     SP, 02H

WAVP_PLAY_LOOP_WAIT:
        CALL    GET_CURR_TIME

        CMP     EAX, DWORD PTR [BP + last_time]
        JBE     WAVP_PLAY_LOOP_WAIT

        PUSH    01H
        LEA     DX, SOUND
        PUSH    DX
        PUSH    WORD PTR [BP + file]
        CALL    READ
        ADD     SP, 06H

        TEST    AX, AX
        JZ      PLAY_LOOP_END
        JS      PLAY_LOOP_END

        XOR     AX, AX
        MOV     AL, BYTE PTR [SOUND]

        PUSH    AX
        CALL    WRITE_DSP
        ADD     SP, 02H

        ; Restoring registers
        POP     ECX

        INC     ECX

        JMP WAVP_PLAY_LOOP

PLAY_LOOP_END:

        PUSH    0D3H
        CALL    WRITE_DSP
        ADD     SP, 02H

        JMP WAVP_EXIT

WAVP_ERROR:
        PUSH    LEN_UN_ERR
        LEA     DX, UN_ERR
        PUSH    DX
        PUSH    STDOUT
        CALL    WRITE
        ADD     SP, 06H

        JMP     WAVP_EXIT

WAVP_ARG_F:
        PUSH    LEN_ERROR_MSG
        LEA     DX, ERROR_MSG
        PUSH    DX
        PUSH    STDOUT
        CALL    WRITE
        ADD     SP, 06H

WAVP_EXIT:
    	; Exiting
    	MOV	AH, 4CH
    	INT	21H

CODE	ENDS
	END START
