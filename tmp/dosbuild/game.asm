.MODEL SMALL
INCLUDE common.inc
INCLUDE vars.inc
PUBLIC ConfigurarNivel, NuevaPartida, PrepararManual, TeclaJuego
PUBLIC EvaluarIntento, ConfirmarIntento, GenerarSecreto, SembrarAzar
PUBLIC LimpiarPropuesta
.DATA
; N, C, maximos, repeticion. Una fuente de configuracion por nivel.
config db 4,6,12,0, 4,6,10,1, 5,8,10,1
.CODE
; E: nivel=0..2. S: configuracion activa. Registros preservados.
ConfigurarNivel PROC NEAR
    push ax
    push bx
    xor bx, bx
    mov bl, nivel
    shl bx, 1
    shl bx, 1
    mov al, config[bx]
    mov nFichas, al
    mov al, config[bx+1]
    mov nTipos, al
    mov al, config[bx+2]
    mov maxTurnos, al
    mov al, config[bx+3]
    mov repeticion, al
    pop bx
    pop ax
    ret
ConfigurarNivel ENDP

; E: ninguna. S: rng inicializado con CX:DX de INT 1Ah AH=00h.
; Registros preservados. La semilla se toma una vez, no por posicion.
SembrarAzar PROC NEAR
    push ax
    push cx
    push dx
    xor ah, ah
    int 1Ah
    xor dx, cx
    xor dx, 0A57Dh
    mov rng, dx
    pop dx
    pop cx
    pop ax
    ret
SembrarAzar ENDP

; E: rng. S: AX=nuevo estado LCG modulo 65536. BX/DX preservados.
; Parametros 25173 y 13849: periodo completo; usar byte alto evita ciclos bajos.
SiguienteAzar PROC NEAR
    push bx
    push dx
    mov ax, rng
    mov bx, 25173
    mul bx
    add ax, 13849
    mov rng, ax
    pop dx
    pop bx
    ret
SiguienteAzar ENDP

; E: configuracion. S: secreto valido y distinto del anterior con mismo N.
; Preserva registros. Rechazo de duplicados solo en secreto Facil.
GenerarSecreto PROC NEAR
    push ax
    push bx
    push cx
    push dx
    push si
    push di
gs_otro:
    xor si, si
gs_posicion:
    call SiguienteAzar
    mov al, ah
    xor ah, ah
    div nTipos
    mov al, ah
    cmp repeticion, 0
    jne gs_guardar
    xor di, di
gs_revisar:
    cmp di, si
    jae gs_guardar
    cmp al, secreto[di]
    je gs_posicion
    inc di
    jmp gs_revisar
gs_guardar:
    mov secreto[si], al
    inc si
    xor cx, cx
    mov cl, nFichas
    cmp si, cx
    jb gs_posicion
    mov al, anteriorN
    cmp al, nFichas
    jne gs_recordar
    xor si, si
gs_comparar:
    mov al, secreto[si]
    cmp al, anterior[si]
    jne gs_recordar
    inc si
    cmp si, cx
    jb gs_comparar
    jmp gs_otro
gs_recordar:
    mov al, nFichas
    mov anteriorN, al
    xor si, si
gs_copiar:
    mov al, secreto[si]
    mov anterior[si], al
    inc si
    cmp si, cx
    jb gs_copiar
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
GenerarSecreto ENDP

; E: ninguna. S: cinco huecos y seleccion inicial. Registros preservados.
LimpiarPropuesta PROC NEAR
    push si
    mov si, MAX_N-1
lp_bucle:
    mov propuesta[si], EMPTY
    dec si
    jns lp_bucle
    mov activo, 0
    pop si
    ret
LimpiarPropuesta ENDP

; E: ninguna. S: historial, mensajes y propuesta reiniciados.
; Registros preservados. Conserva PRNG, dificultad y secreto anterior.
ReiniciarDatos PROC NEAR
    push si
    call LimpiarPropuesta
    mov usados, 0
    mov mensaje, MSG_KEYS
    mov manual, 0
    mov cuadro, 0
    mov si, MAX_TURNS*MAX_N-1
rd_hist:
    mov historial[si], EMPTY
    dec si
    jns rd_hist
    mov si, MAX_TURNS-1
rd_result:
    mov torosHist[si], 0
    mov vacasHist[si], 0
    dec si
    jns rd_result
    pop si
    ret
ReiniciarDatos ENDP

; E: nivel. S: partida nueva aleatoria. Registros preservados.
NuevaPartida PROC NEAR
    call ConfigurarNivel
    call ReiniciarDatos
    call GenerarSecreto
    mov estado, ST_GAME
    mov sucio, 1
    ret
NuevaPartida ENDP

; E: nivel. S: editor del secreto de pruebas, admite repetidos en todo nivel.
; Registros preservados. No modifica el secreto anterior aleatorio.
PrepararManual PROC NEAR
    call ConfigurarNivel
    call ReiniciarDatos
    mov manual, 1
    mov mensaje, MSG_MANUAL
    mov estado, ST_SECRET
    mov sucio, 1
    ret
PrepararManual ENDP

; E: propuesta y nFichas/nTipos. S: CF=1 completa y dentro de rango.
; Registros preservados. No consume intentos ni impone repeticion a propuestas.
ValidarIntento PROC NEAR
    push ax
    push cx
    push si
    xor cx, cx
    mov cl, nFichas
    xor si, si
vi_bucle:
    mov al, propuesta[si]
    cmp al, nTipos
    jae vi_invalido
    inc si
    loop vi_bucle
    stc
    jmp vi_fin
vi_invalido:
    clc
vi_fin:
    pop si
    pop cx
    pop ax
    ret
ValidarIntento ENDP

; E: secreto/propuesta validos y configuracion. S: toros y vacas en memoria.
; Registros preservados. No altera entradas ni turnos; primero excluye exactos.
EvaluarIntento PROC NEAR
    push ax
    push bx
    push cx
    push si
    mov toros, 0
    mov vacas, 0
    mov si, MAX_C-1
ei_limpiar:
    mov frecSec[si], 0
    mov frecProp[si], 0
    dec si
    jns ei_limpiar
    xor si, si
    xor cx, cx
    mov cl, nFichas
ei_posicion:
    mov al, secreto[si]
    cmp al, propuesta[si]
    jne ei_parcial
    inc toros
    jmp ei_siguiente
ei_parcial:
    xor bx, bx
    mov bl, al
    inc frecSec[bx]
    mov bl, propuesta[si]
    inc frecProp[bx]
ei_siguiente:
    inc si
    loop ei_posicion
    xor si, si
    mov cl, nTipos
ei_frecuencias:
    mov al, frecSec[si]
    cmp al, frecProp[si]
    jbe ei_minimo
    mov al, frecProp[si]
ei_minimo:
    add vacas, al
    inc si
    loop ei_frecuencias
    pop si
    pop cx
    pop bx
    pop ax
    ret
EvaluarIntento ENDP

; E: propuesta. S: registra una vez o muestra aviso sin gastar turno.
; Registros preservados. Victoria se comprueba antes de agotamiento.
ConfirmarIntento PROC NEAR
    push ax
    push bx
    push cx
    push si
    push di
    call ValidarIntento
    jc ci_completo
    mov mensaje, MSG_HOLES
    jmp ci_fin
ci_completo:
    cmp estado, ST_SECRET
    jne ci_evaluar
    xor si, si
    xor cx, cx
    mov cl, nFichas
ci_secreto:
    mov al, propuesta[si]
    mov secreto[si], al
    inc si
    loop ci_secreto
    call LimpiarPropuesta
    mov estado, ST_GAME
    mov mensaje, MSG_KEYS
    jmp ci_fin
ci_evaluar:
    mov al, usados
    cmp al, maxTurnos
    jae ci_fin
    call EvaluarIntento
    xor bx, bx
    mov bl, usados
    mov al, toros
    mov torosHist[bx], al
    mov al, vacas
    mov vacasHist[bx], al
    mov ax, bx
    shl bx, 1
    shl bx, 1
    add bx, ax
    xor si, si
    mov cx, MAX_N
ci_historial:
    mov al, propuesta[si]
    mov historial[bx+si], al
    inc si
    loop ci_historial
    inc usados
    mov al, toros
    cmp al, nFichas
    je ci_victoria
    mov al, usados
    cmp al, maxTurnos
    jae ci_derrota
    call LimpiarPropuesta
    mov mensaje, MSG_SAVED
    jmp ci_fin
ci_victoria:
    mov estado, ST_WIN
    jmp ci_fin
ci_derrota:
    mov estado, ST_LOSE
ci_fin:
    mov sucio, 1
    pop di
    pop si
    pop cx
    pop bx
    pop ax
    ret
ConfirmarIntento ENDP

; E: AX=tecla BIOS en partida o editor manual. S: propuesta/estado actualizados.
; Registros preservados. Numeros y flechas no avanzan automaticamente posicion.
TeclaJuego PROC NEAR
    push ax
    push bx
    xor bx, bx
    mov bl, activo
    cmp al, 1Bh
    jne tj_enter
    mov estado, ST_MENU
    jmp tj_cambio
tj_enter:
    cmp al, 0Dh
    jne tj_borrar
    call ConfirmarIntento
    jmp tj_fin
tj_borrar:
    cmp al, 08h
    jne tj_izq
    mov propuesta[bx], EMPTY
    jmp tj_cambio
tj_izq:
    cmp ah, 4Bh
    jne tj_der
    cmp activo, 0
    je tj_cambio
    dec activo
    jmp tj_cambio
tj_der:
    cmp ah, 4Dh
    jne tj_arriba
    mov al, nFichas
    dec al
    cmp activo, al
    jae tj_cambio
    inc activo
    jmp tj_cambio
tj_arriba:
    cmp ah, 48h
    jne tj_abajo
    mov al, propuesta[bx]
    inc al
    cmp al, nTipos
    jb tj_asignar
    xor al, al
    jmp tj_asignar
tj_abajo:
    cmp ah, 50h
    jne tj_numero
    mov al, propuesta[bx]
    cmp al, EMPTY
    je tj_ultimo
    or al, al
    jz tj_ultimo
    dec al
    jmp tj_asignar
tj_ultimo:
    mov al, nTipos
    dec al
    jmp tj_asignar
tj_numero:
    cmp al, '1'
    jb tj_fin
    sub al, '1'
    cmp al, nTipos
    jae tj_fin
tj_asignar:
    mov propuesta[bx], al
tj_cambio:
    mov mensaje, MSG_KEYS
    mov sucio, 1
tj_fin:
    pop bx
    pop ax
    ret
TeclaJuego ENDP
END
