.MODEL SMALL
.STACK 512
INCLUDE common.inc
INCLUDE vars.inc
INCLUDE video.inc
INCLUDE game.inc
INCLUDE input.inc
INCLUDE ui.inc
INCLUDE tests.inc
.CODE
; Entrada DOS EXE: DS se inicializa antes de acceder a datos propios.
main PROC
    mov ax, @data
    mov ds, ax
    cld
    call EsModoPrueba
    jnc main_grafico
    call EjecutarPruebas
    mov ah, 4Ch
    int 21h
main_grafico:
    call IniciarVideo
    call CargarPaleta
    call SembrarAzar
    call ConfigurarNivel
    call LeerTic
    mov ultimoTic, dx
main_bucle:
    cmp estado, ST_EXIT
    je main_salir
    cmp sucio, 0
    je main_reloj
    call DibujarPantalla
    call Presentar
    mov sucio, 0
main_reloj:
    call ActualizarReloj
    jnc main_tecla
    call DibujarAnimacion
    call Presentar
main_tecla:
    call LeerTecla
    jnc main_bucle
    call ProcesarTecla
    jmp main_bucle
main_salir:
    call RestaurarVideo
    mov ax, 4C00h
    int 21h
main ENDP

; E: PSP de DOS. S: CF=1 si primer argumento es /T (o /t).
; Preserva registros; destruye FLAGS. No modifica el modo de video.
EsModoPrueba PROC NEAR
    push ax
    push bx
    push si
    push es
    mov ah, 62h
    int 21h
    mov es, bx
    xor bx, bx
    mov bl, es:[80h]
    mov si, 81h
emp_siguiente:
    or bx, bx
    jz emp_no
    mov al, es:[si]
    inc si
    dec bx
    cmp al, ' '
    je emp_siguiente
    cmp al, '/'
    jne emp_no
    cmp bx, 1
    jne emp_no
    mov al, es:[si]
    and al, 0DFh
    cmp al, 'T'
    jne emp_no
    stc
    jmp emp_fin
emp_no:
    clc
emp_fin:
    pop es
    pop si
    pop bx
    pop ax
    ret
EsModoPrueba ENDP
END main
