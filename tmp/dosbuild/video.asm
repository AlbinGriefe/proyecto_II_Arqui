.MODEL SMALL
INCLUDE common.inc
INCLUDE vars.inc
PUBLIC IniciarVideo, RestaurarVideo, CargarPaleta, LimpiarPantalla
PUBLIC Rectangulo, DibujarSprite, DibujarTexto, DibujarNumero
PUBLIC Presentar
; Segmento independiente: el framebuffer no consume los 64 KiB de DGROUP.
SCREEN SEGMENT PARA PUBLIC 'SCREEN'
screenBuf db 64000 dup (?)
SCREEN ENDS
.DATA
spriteW dw 0
textoX dw 0
textoColor db 0
textoChar db 0, 0, 0
.CODE
; E: ninguna. S: modo 13h y fuente ROM localizada. Registros preservados.
IniciarVideo PROC NEAR
    push ax
    push bx
    push cx
    push dx
    push bp
    push es
    mov ah, 0Fh
    int 10h
    and al, 7Fh
    mov modoPrevio, al
    mov paginaPrevia, bh
    mov ax, 0013h
    int 10h
    mov ax, 1130h
    mov bh, 3
    int 10h
    mov fuenteOff, bp
    mov ax, es
    mov fuenteSeg, ax
    pop es
    pop bp
    pop dx
    pop cx
    pop bx
    pop ax
    ret
IniciarVideo ENDP

; E: modoPrevio/paginaPrevia. S: modo y pagina restaurados, no su contenido.
; Registros preservados; FLAGS destruidos.
RestaurarVideo PROC NEAR
    push ax
    push bx
    xor ah, ah
    mov al, modoPrevio
    int 10h
    mov ah, 05h
    mov al, paginaPrevia
    int 10h
    pop bx
    pop ax
    ret
RestaurarVideo ENDP

; E: paleta con 16 tripletas DAC 0..63. S: entradas VGA 0..15 programadas.
; Registros preservados; FLAGS destruidos.
CargarPaleta PROC NEAR
    push ax
    push cx
    push dx
    push si
    mov dx, 3C8h
    xor al, al
    out dx, al
    inc dx
    mov si, OFFSET paleta
    mov cx, 48
cp_bucle:
    lodsb
    out dx, al
    loop cp_bucle
    pop si
    pop dx
    pop cx
    pop ax
    ret
CargarPaleta ENDP

; E: AL=indice de fondo. S: 64000 bytes escritos. Registros preservados.
LimpiarPantalla PROC NEAR
    push ax
    push cx
    push di
    push es
    mov ah, al
    mov cx, SEG screenBuf
    mov es, cx
    xor di, di
    mov cx, 32000
    cld
    rep stosw
    pop es
    pop di
    pop cx
    pop ax
    ret
LimpiarPantalla ENDP

; E: AX=x, DX=y, CX=ancho, BP=alto, BL=color; rectangulo dentro de pantalla.
; S: region rellenada. Registros preservados, FLAGS destruidos.
Rectangulo PROC NEAR
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp
    push es
    or cx, cx
    jz rect_fin
    or bp, bp
    jz rect_fin
    mov di, ax
    mov ax, 320
    mul dx
    add di, ax
    mov ax, SEG screenBuf
    mov es, ax
    mov al, bl
    mov si, cx
    cld
rect_fila:
    mov cx, si
    rep stosb
    add di, 320
    sub di, si
    dec bp
    jnz rect_fila
rect_fin:
    pop es
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
Rectangulo ENDP

; E: DS:SI=bytes por filas, AX=x, DX=y, CX=ancho, BP=alto.
; S: sprite en framebuffer SCREEN; 0 transparente; CF=1 si no cabe/tamano cero.
; Registros preservados; FLAGS salvo CF destruidos. No recorta parcialmente.
DibujarSprite PROC NEAR
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp
    push es
    or cx, cx
    jz spr_error
    or bp, bp
    jz spr_error
    cmp ax, 320
    jae spr_error
    cmp dx, 200
    jae spr_error
    mov bx, 320
    sub bx, ax
    cmp cx, bx
    ja spr_error
    mov bx, 200
    sub bx, dx
    cmp bp, bx
    ja spr_error
    mov spriteW, cx
    mov di, ax
    mov ax, 320
    mul dx
    add di, ax
    mov ax, SEG screenBuf
    mov es, ax
    cld
spr_fila:
    mov cx, spriteW
spr_pixel:
    lodsb
    or al, al
    jz spr_transp
    mov es:[di], al
spr_transp:
    inc di
    loop spr_pixel
    add di, 320
    sub di, spriteW
    dec bp
    jnz spr_fila
    clc
    jmp spr_fin
spr_error:
    stc
spr_fin:
    pop es
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
DibujarSprite ENDP

; E: DS:SI=ASCII terminado en 0, AX=x, DX=y, BL=color.
; S: glifos ROM 8x8 en framebuffer; corta al borde derecho/inferior.
; Registros preservados, FLAGS destruidos. Sin INT 10h por pixel.
DibujarTexto PROC NEAR
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp
    push es
    cmp dx, 192
    ja dt_fin
    mov textoColor, bl
    mov textoX, ax
    mov di, ax
    mov ax, 320
    mul dx
    add di, ax
dt_caracter:
    cmp textoX, 312
    ja dt_fin
    lodsb
    or al, al
    jz dt_fin
    push si
    xor ah, ah
    mov cl, 3
    shl ax, cl
    add ax, fuenteOff
    mov si, ax
    mov ax, fuenteSeg
    mov es, ax
    mov bp, 8
dt_fila:
    mov bl, es:[si]
    inc si
    push es
    mov ax, SEG screenBuf
    mov es, ax
    mov cx, 8
    mov al, textoColor
dt_bit:
    shl bl, 1
    jnc dt_fondo
    mov es:[di], al
dt_fondo:
    inc di
    loop dt_bit
    pop es
    add di, 312
    dec bp
    jnz dt_fila
    sub di, 2560
    add di, 8
    add textoX, 8
    pop si
    jmp dt_caracter
dt_fin:
    pop es
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
DibujarTexto ENDP

; E: CL=0..99, AX=x, DX=y, BL=color. S: numero de dos cifras.
; Registros preservados; FLAGS destruidos.
DibujarNumero PROC NEAR
    push ax
    push cx
    push si
    push ax
    mov al, cl
    xor ah, ah
    mov cl, 10
    div cl
    add ax, 3030h
    mov textoChar, al
    mov textoChar+1, ah
    pop ax
    mov si, OFFSET textoChar
    ; El cero de terminacion sigue a los dos caracteres.
    call DibujarTexto
    pop si
    pop cx
    pop ax
    ret
DibujarNumero ENDP

; E: framebuffer SCREEN. S: imagen completa en A000h, 32000 palabras.
; Registros/segmentos preservados. Sin borrado visible entre dibujos.
Presentar PROC NEAR
    push ax
    push cx
    push si
    push di
    push ds
    push es
    mov ax, SEG screenBuf
    mov ds, ax
    xor si, si
    mov ax, 0A000h
    mov es, ax
    xor di, di
    mov cx, 32000
    cld
    rep movsw
    pop es
    pop ds
    pop di
    pop si
    pop cx
    pop ax
    ret
Presentar ENDP
END
