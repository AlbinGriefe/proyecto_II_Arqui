; Constantes propias del proyecto. Sintaxis MASM/TASM, CPU 8086.
.8086
JUMPS
MAX_N       EQU 5
MAX_C       EQU 8
MAX_TURNS   EQU 12
EMPTY       EQU 0FFh
ST_SPLASH   EQU 0
ST_MENU     EQU 1
ST_LEVEL    EQU 2
ST_HELP     EQU 3
ST_CREDITS  EQU 4
ST_GAME     EQU 5
ST_WIN      EQU 6
ST_LOSE     EQU 7
ST_SECRET   EQU 8
ST_EXIT     EQU 9
MSG_KEYS    EQU 0
MSG_HOLES   EQU 1
MSG_SAVED   EQU 2
MSG_MANUAL  EQU 3
ANIM_TICKS  EQU 3

; Conserva el contrato de DibujarTexto; usada en todas las pantallas.
TEXTO MACRO cadena, posx, posy, color
    push ax
    push bx
    push dx
    push si
    mov si, OFFSET cadena
    mov ax, posx
    mov dx, posy
    mov bl, color
    call DibujarTexto
    pop si
    pop dx
    pop bx
    pop ax
ENDM
