        PAGE 55, 132
        .386

STACK   SEGMENT para 'STACK' STACK
        DW     100 DUP(?)
STACK   ENDS

DATA    SEGMENT para
        RAND_SEED       DD      12345
DATA    ENDS

CODE    SEGMENT para 'CODE' PUBLIC USE16
        ASSUME  CS:CODE, DS:DATA, SS:STACK

START:
        ; Initializing .section .data
        MOV     AX, DATA
        MOV     DS, AX
        MOV     ES, AX
        XOR     SI, SI
        XOR     DI, DI

TST:
        ; Initializing stack frame
        MOV     EBP, ESP
        VAR_X   EQU     -2 ; WORD
        VAR_Y   EQU     -4 ; WORD
        VAR_CLR EQU     -5 ; BYTE
        VAR_TM  EQU     -6 ; BYTE
        SUB     SP, 06H

        ; Main part
        CALL    VGA_MODE_ON

        ; MOV     AH, 2CH
        ; INT     21H
        ; MOV     BYTE PTR [BP + VAR_TM], DL

        ;PUSH    EDX
        ;CALL    SRAND
        ;ADD     SP, 04H

TEST_MAIN_LOOP:
        ;CALL    VGA_WAIT_FRAME

        ; X-position
        CALL    RAND
        XOR     DX, DX
        MOV     CX, 320
        IDIV    CX
        MOV     WORD PTR [BP + VAR_X], DX

        ; Y-position
        CALL    RAND
        XOR     DX, DX
        MOV     CX, 240
        IDIV    CX
        MOV     WORD PTR [BP + VAR_Y], DX

        ; Generating color
        CALL    RAND
        AND     AX, 0FFH       

        ; Writing pixel
        MOV     AH, 0CH
        MOV     CX, WORD PTR [BP + VAR_X]
        MOV     DX, WORD PTR [BP + VAR_Y]
        INT     10H

        MOV     CX, 1000

TEST_MAIN_LOOP_DELAY:
        ; Custom delay
        ;XOR     AX, AX
        ;MOV     AH, 2CH
        ;INT     21H

        ;MOV     CL, BYTE PTR [BP + VAR_TM]
        ;CMP     CL, DL
        ;JE      TEST_MAIN_LOOP_DELAY

        ;MOV     BYTE PTR [BP + VAR_TM], DL
        
        ;XOR     AX, AX
        ;MOV     AH, 0BH
        ;INT     21H
        
        ;TEST    AL, AL
        ;JZ      TEST_MAIN_LOOP

        ;XOR     AX, AX
        ;INT     16H

        ; nop-based delay
        LOOP    TEST_MAIN_LOOP_DELAY

        XOR     AX, AX
        MOV     AH, 01H
        INT     016H

        CMP     AH, 39H
        JNE     TEST_MAIN_LOOP
        
TEST_MAIN_LOOP_END:        
        CALL    VGA_MODE_OFF
               
TEST_EXIT:
        XOR     AX, AX
        MOV     AH, 4CH
        INT     21H

VGA_MODE_ON     PROC
        ; Initializing function's stack frame
        PUSH    BP
        MOV     BP, SP

        ; Main part
        XOR     AX, AX
        MOV     AL, 013H
        INT     10H

        ; Destroying function's stack frame
        MOV     SP, BP
        POP     BP
        RET

VGA_MODE_ON     ENDP

VGA_MODE_OFF    PROC
        ; Initializing function's stack frame
        PUSH    BP
        MOV     BP, SP

        ; Main part
        XOR     AX, AX
        MOV     AL, 003H
        INT     10H

        ; Destroying function's stack frame
        MOV     SP, BP
        POP     BP
        RET

VGA_MODE_OFF    ENDP


VGA_STATUS_PORT EQU     03DAH
VGA_WAIT_FRAME  PROC
        ; Initializing function's stack frame
        PUSH    BP
        MOV     BP, SP

        ; Main part
        MOV     DX, VGA_STATUS_PORT

VGA_WAIT_FRAME_WAIT_RETRACE:
        IN      AL, DX
        TEST    AL, 08H
        JNZ     VGA_WAIT_FRAME_WAIT_RETRACE

VGA_WAIT_FRAME_END_REFRESH:
        IN      AL, DX
        TEST    AL, 08H
        JZ      VGA_WAIT_FRAME_END_REFRESH

        ; Destroying function's stack frame
        MOV     SP, BP
        POP     BP
        RET

VGA_WAIT_FRAME  ENDP

SRAND   PROC
        ; Initializing function's stack frame
        PUSH    BP
        MOV     BP, SP

        ; Initializing variables
        MOV     EAX, DWORD PTR [BP + 04H]
        MOV     RAND_SEED, EAX

        ; Destroying functon's stack frame
        MOV     SP, BP
        POP     BP
        RET

SRAND   ENDP

RAND_A  EQU     1103515245
RAND_C  EQU     12345
RAND_M  EQU     7FFFFFFFH
RAND    PROC
        ; Initializing function's stack frame
        PUSH    BP
        MOV     BP, SP

        ; Main part
        MOV     EAX, RAND_SEED
        MOV     ECX, RAND_A
        IMUL    EAX, ECX         ; RAND_A * SEED

        ADD     EAX, RAND_C      ; RAND_A * SEED + RAND_C
        XOR     EDX, EDX
        MOV     ECX, RAND_M

        IDIV    ECX
        MOV     RAND_SEED, EDX
        MOV     EAX, EDX

        ; Destroying function's stack frame
        MOV     SP, BP
        POP     BP
        RET

RAND    ENDP


CODE    ENDS
        END     START