.MODEL SMALL
INCLUDE common.inc
INCLUDE vars.inc
PUBLIC LeerTecla, LeerTic, ActualizarReloj
.CODE
; E: ninguna. S: CF=1, AX=ASCII/scan si hay tecla; CF=0 sin tecla.
; Preserva los demas registros. Consulta y consume via BIOS, sin bloquear.
LeerTecla PROC NEAR
    mov ah, 01h
    int 16h
    jz lt_vacio
    xor ah, ah
    int 16h
    stc
    ret
lt_vacio:
    clc
    ret
LeerTecla ENDP

; E: ninguna. S: DX=palabra baja del tic BIOS. Otros registros preservados.
; Lectura atomica de 16 bits en 0040:006C; no altera bandera de medianoche.
LeerTic PROC NEAR
    push ax
    push es
    mov ax, 40h
    mov es, ax
    mov dx, es:[6Ch]
    pop es
    pop ax
    ret
LeerTic ENDP

; E: ultimoTic. S: CF=1 al cambiar cuadro; CF=0 sin vencimiento.
; Preserva registros. La resta modular tolera rollover; medianoche resincroniza.
ActualizarReloj PROC NEAR
    push ax
    push dx
    call LeerTic
    mov ax, dx
    sub ax, ultimoTic
    cmp ax, ANIM_TICKS
    jb ar_no
    mov ultimoTic, dx
    xor cuadro, 1
    stc
    jmp ar_fin
ar_no:
    clc
ar_fin:
    pop dx
    pop ax
    ret
ActualizarReloj ENDP
END
