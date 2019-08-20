        PAGE    55, 132
        .386

STACK	SEGMENT	'STACK' STACK
        DQ      100 DUP(?)
STACK 	ENDS
         
                                 ; Constants
        ; Audio device
        wSBCBaseAddx    EQU     220h

        ; .wav file
        WAV_HEADER_SIZE EQU     44

        ; Type sizes
        SIZEOF_WORD     EQU     2
        SIZEOF_PTR      EQU     2
        SIZEOF_DWORD    EQU     4
        SIZEOF_EPTR     EQU     4

        ; Function's arguments
        FIRST_ARG       EQU     SIZEOF_PTR + SIZEOF_PTR
        SECOND_ARG      EQU     FIRST_ARG + SIZEOF_WORD
        THIRD_ARG       EQU     SECOND_ARG + SIZEOF_WORD
        FOURTH_ARG      EQU     THIRD_ARG + SIZEOF_WORD

        ; EFunction's arguments
        EFIRST_ARG      EQU     SIZEOF_PTR + SIZEOF_EPTR
        ESECOND_ARG     EQU     EFIRST_ARG + SIZEOF_DWORD
        ETHIRD_ARG      EQU     ESECOND_ARG + SIZEOF_DWORD
        EFOURTH_ARG     EQU     ETHIRD_ARG + SIZEOF_DWORD

        ; Standard files
        STDIN           EQU     00H
        STDOUT          EQU     01H
        STDERR          EQU     02H

        ; File access modes
        O_RDONLY        EQU     00H
        O_WRONLY        EQU     01H
        O_RDWR          EQU     02H

        ; lseek(1) whences
        SEEK_SET        EQU     00H
        SEEK_CURR       EQU     01H
        SEEK_END        EQU     02H

DATA	SEGMENT	para

                                ; WAVP.ASM
HELLO           DB      '| This is the simplest .wav player ever possible!'
                DB      0AH, 0DH, '| Enjoy your shitty music :)'
		DB	0AH, 0DH
LEN_HELLO	EQU	$ - HELLO

WAV_FILE        DB      'C:\ASM\exp\wavp\KINGSV.WAV', 00H

UN_ERR          DB      0AH, 0DH, '| wavp: unexpected error occurs!', 0AH, 0DH
LEN_UN_ERR      EQU     $ - UN_ERR

ERROR_MSG       DB      '| wavp: error! Argument problem! Consider using only .wav filename', 0AH, 0DH
LEN_ERROR_MSG   EQU     $ - ERROR_MSG

CONST_PROD      DQ      0

SOUND           DB      0

WAV_INFO_BUF    DB      WAV_HEADER_SIZE DUP(0)

                               ; ROUTINES.ASM
PLAY_AGAIN      DB      0AH, 0DH, '| Do you want to play this file again? [y/N]: '
LEN_PLAY_AGAIN  EQU     $ - PLAY_AGAIN

PLAY_AGAIN_ERR  DB      '| wavp: error! No such command!', 0AH, 0DH
LEN_PLAY_AGAIN_ERR      EQU     $ - PLAY_AGAIN_ERR

MENUBUF_LEN     EQU     100
MENUBUF         DB      MENUBUF_LEN DUP(0)

NUM_BUF_LEN     EQU     100
NUM_BUF         DB      NUM_BUF_LEN DUP(0)

                                  ; PI.ASM
INFO_RATE       DB      0AH, 0DH, '| Device sampling rate: '
LEN_INFO_RATE   EQU     $ - INFO_RATE

INFO_SIZE       DB      '| Device sample size: '
LEN_INFO_SIZE   EQU     $ - INFO_SIZE

INFO_CHANNELS_STEREO    DB      '| Device channels: stereo', 0AH, 0DH
LEN_INFO_CHANNELS_STEREO        EQU     $ - INFO_CHANNELS_STEREO

INFO_CHANNELS_MONO    DB      '| Device channels: mono', 0AH, 0DH
LEN_INFO_CHANNELS_MONO        EQU     $ - INFO_CHANNELS_MONO

INFO_FILE_SIZE  DB      '| File size: '
LEN_INFO_FILE_SIZE      EQU     $ - INFO_FILE_SIZE

INFO_FILE_DURATION      DB      '| File duration: '
LEN_INFO_FILE_DURATION  EQU     $ - INFO_FILE_DURATION

CURRENTLY_PLAYING       DB      0AH, 0DH, '| Currently playing: '
LEN_CURRENTLY_PLAYING   EQU     $ - CURRENTLY_PLAYING

INFO_HZ         DB      ' Hz', 0AH, 0DH
LEN_INFO_HZ     EQU     $ - INFO_HZ

INFO_BITS       DB      ' bits', 0AH, 0DH
LEN_INFO_BITS   EQU     $ - INFO_BITS

INFO_BYTE       DB      ' B', 0AH, 0DH
LEN_INFO_BYTE   EQU     $ - INFO_BYTE

HASH            DB      '='
HASH2           DB      '-'

INFO_KIB        DB      ' xiB ('
LEN_INFO_KIB    EQU     $ - INFO_KIB

PROG_BAR        DB      0DH, '| Progress: [------------------------------] '
LEN_PROG_BAR    EQU     $ - PROG_BAR

DATA	ENDS
