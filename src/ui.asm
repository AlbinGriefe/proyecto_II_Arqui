.MODEL SMALL
INCLUDE common.inc
INCLUDE vars.inc
INCLUDE video.inc
INCLUDE game.inc
PUBLIC DibujarPantalla, ProcesarTecla, DibujarAnimacion
.DATA
uiChar db 0, 0
uiFila dw 0
uiCol dw 0
uiX dw 0
uiY dw 0
uiFrame db 0
uiBase dw 0
uiExactX dw 0
uiPartialX dw 0
uiPaso dw 0
uiEjemplo db 0,1,2,3,0,2,1,3
.CODE
; E: estado y datos del juego. S: framebuffer completo. Registros preservados.
DibujarPantalla PROC NEAR
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp
    mov al, 1
    mov uiFrame, 0
    call LimpiarPantalla
    xor ax, ax
    xor dx, dx
    mov cx, 320
    mov bp, 20
    mov bl, 2
    call Rectangulo
    TEXTO txtTitle, 8, 6, 15
    cmp estado, ST_SPLASH
    je dp_splash
    cmp estado, ST_MENU
    je dp_menu
    cmp estado, ST_LEVEL
    je dp_nivel
    cmp estado, ST_HELP
    je dp_ayuda
    cmp estado, ST_CREDITS
    je dp_creditos
    call DibujarTablero
    jmp dp_fin
dp_splash:
    TEXTO txtSplash, 40, 46, 14
    TEXTO txtPending, 24, 64, 7
    TEXTO txtTeam, 24, 142, 7
    TEXTO txtContinue, 32, 174, 15
    jmp dp_fin
dp_menu:
    TEXTO txtMenu, 24, 30, 14
    xor di, di
    mov dx, 54
dp_opcion:
    mov bx, di
    shl bx, 1
    mov si, menuPtrs[bx]
    mov bl, 7
    mov ax, di
    cmp al, menuSel
    jne dp_optexto
    mov bl, 14
dp_optexto:
    mov ax, 48
    call DibujarTexto
    add dx, 20
    inc di
    cmp di, 5
    jb dp_opcion
    TEXTO txtDebug, 16, 170, 10
    TEXTO txtEsc, 16, 190, 7
    jmp dp_fin
dp_nivel:
    TEXTO txtLevel, 24, 30, 14
    xor di, di
    mov dx, 66
dp_nivop:
    mov bx, di
    shl bx, 1
    mov si, nivelPtrs[bx]
    mov bl, 7
    mov ax, di
    cmp al, nivel
    jne dp_nivtexto
    mov bl, 14
dp_nivtexto:
    mov ax, 48
    call DibujarTexto
    add dx, 24
    inc di
    cmp di, 3
    jb dp_nivop
    xor bx, bx
    mov bl, nivel
    shl bx, 1
    mov si, nivelDescPtrs[bx]
    mov ax, 24
    mov dx, 148
    mov bl, 7
    call DibujarTexto
    TEXTO txtEsc, 16, 190, 7
    jmp dp_fin
dp_ayuda:
    call DibujarAyuda
    jmp dp_fin
dp_creditos:
    TEXTO txtCredits, 16, 30, 14
    TEXTO txtTeam, 16, 64, 7
    TEXTO txtCreditDesign, 16, 88, 7
    TEXTO txtEsc, 16, 190, 7
dp_fin:
    call DibujarAnimacion
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
DibujarPantalla ENDP

; E: datos del juego. S: zonas A/B/C/D. Preserva registros salvo FLAGS.
DibujarTablero PROC NEAR
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp
    mov ax, 4
    mov dx, 22
    mov cx, 196
    mov bp, 168
    mov bl, 2
    call Rectangulo
    mov ax, 204
    mov cx, 112
    call Rectangulo
    xor bx, bx
    mov bl, nivel
    shl bx, 1
    mov si, nivelPtrs[bx]
    mov ax, 216
    mov dx, 6
    mov bl, 14
    call DibujarTexto
    cmp estado, ST_SECRET
    jne dt_historial
    call DibujarManual
    jmp dt_panel
dt_historial:
    call DibujarCabeceraHistorial
    call DibujarHistorial
dt_panel:
    TEXTO txtCatalog, 208, 24, 7
    call DibujarCatalogo
    TEXTO txtGuess, 208, 94, 7
    call DibujarPropuesta
    TEXTO txtTurn, 208, 132, 7
    mov cl, usados
    inc cl
    cmp estado, ST_WIN
    jb dt_turno
    cmp estado, ST_LOSE
    ja dt_turno
    dec cl
dt_turno:
    mov ax, 280
    mov dx, 132
    mov bl, 15
    call DibujarNumero
    TEXTO txtLeft, 208, 144, 7
    mov cl, maxTurnos
    sub cl, usados
    mov ax, 280
    mov dx, 144
    call DibujarNumero
dt_resultado:
    cmp estado, ST_WIN
    je dt_gano
    cmp estado, ST_LOSE
    jne dt_mensaje
    TEXTO txtAgainLost, 8, 191, 13
    jmp dt_revelar
dt_gano:
    TEXTO txtAgain, 8, 191, 10
dt_revelar:
    TEXTO txtSecret, 208, 158, 7
    xor di, di
    mov uiX, 208
    mov uiY, 172
    mov uiFrame, 0
dt_codigo:
    mov al, secreto[di]
    call FichaEnCoordenada
    add uiX, 20
    inc di
    xor cx, cx
    mov cl, nFichas
    cmp di, cx
    jb dt_codigo
    jmp dt_fin
dt_mensaje:
    xor bx, bx
    mov bl, mensaje
    shl bx, 1
    mov si, mensajePtrs[bx]
    mov ax, 4
    mov dx, 191
    mov bl, 14
    call DibujarTexto
dt_fin:
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
DibujarTablero ENDP

; E: nivel. S: cabeceras dentro del panel A. Registros preservados.
DibujarCabeceraHistorial PROC NEAR
    cmp nivel, 0
    jne dch_simple
    TEXTO txtBoard, 18, 24, 7
    TEXTO txtMiniT, 86, 24, 10
    TEXTO txtMiniV, 94, 24, 14
    TEXTO txtBoard, 116, 24, 7
    TEXTO txtMiniT, 184, 24, 10
    TEXTO txtMiniV, 192, 24, 14
    ret
dch_simple:
    TEXTO txtBoard, 32, 22, 7
    TEXTO txtMiniT, 156, 22, 10
    TEXTO txtMiniV, 180, 22, 14
    ret
DibujarCabeceraHistorial ENDP

; E: editor manual. S: ayuda acotada al panel izquierdo. Registros preservados.
DibujarManual PROC NEAR
    TEXTO txtManual, 8, 32, 14
    TEXTO txtManual2, 8, 54, 7
    TEXTO txtManual3, 8, 66, 7
    TEXTO txtManual4, 8, 78, 7
    TEXTO txtManual5, 8, 110, 15
    TEXTO txtManual6, 8, 132, 10
    ret
DibujarManual ENDP

; E: ninguna. S: ejemplo 0123/0213 con dos exactos y dos parciales.
; Usa datos privados de interfaz; nunca expone el secreto de una partida.
DibujarAyuda PROC NEAR
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    TEXTO txtHelp, 8, 26, 14
    TEXTO txtRules1, 8, 40, 7
    TEXTO txtCodeLabel, 8, 54, 15
    TEXTO txtExampleLabel, 144, 54, 15
    xor di, di
    mov uiX, 8
    mov uiY, 66
    mov uiFrame, 0
day_ficha:
    mov al, uiEjemplo[di]
    call FichaEnCoordenada
    add uiX, 20
    inc di
    cmp di, 4
    jne day_limite
    mov uiX, 144
day_limite:
    cmp di, 8
    jb day_ficha
    TEXTO txtScoreExample, 224, 70, 10
    TEXTO txtScorePartial, 280, 70, 14
    TEXTO txtRules2, 8, 88, 10
    TEXTO txtRules3, 8, 100, 14
    TEXTO txtRules9, 8, 112, 7
    TEXTO txtRules4, 8, 128, 7
    TEXTO txtRules5, 8, 140, 7
    TEXTO txtRules6, 8, 152, 7
    TEXTO txtRules7, 8, 166, 7
    TEXTO txtRules8, 8, 178, 7
    TEXTO txtHelpFooter, 8, 191, 7
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
DibujarAyuda ENDP

; E: CL=0..9, AX/DX=coordenadas, BL=color. S: un digito. Preserva registros.
Digito PROC NEAR
    push cx
    push si
    add cl, '0'
    mov uiChar, cl
    mov si, OFFSET uiChar
    call DibujarTexto
    pop si
    pop cx
    ret
Digito ENDP

; E: historial y conteos. S: todos los intentos con sprites 16x16, T y V.
; Facil: dos columnas de seis. Normal/Dificil: diez filas de 16 pixeles.
; Preserva registros. No hay paginacion, escalado ni filas ocultas.
DibujarHistorial PROC NEAR
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    mov uiFila, 0
    mov uiFrame, 0
dh_fila:
    xor cx, cx
    mov cl, maxTurnos
    cmp uiFila, cx
    jae dh_fin
    call CoordenadaHistorial
    mov cx, uiFila
    inc cl
    mov ax, uiBase
    mov dx, uiY
    add dx, 5
    mov bl, 7
    call DibujarNumeroMini
    xor cx, cx
    mov cl, usados
    cmp uiFila, cx
    jae dh_siguiente
    mov bx, uiFila
    mov si, bx
    shl bx, 1
    shl bx, 1
    add si, bx
    mov uiCol, 0
dh_col:
    mov al, historial[si]
    call FichaEnCoordenada
    mov ax, uiPaso
    add uiX, ax
    inc si
    inc uiCol
    xor cx, cx
    mov cl, nFichas
    cmp uiCol, cx
    jb dh_col
    mov si, uiFila
    mov cl, torosHist[si]
    mov ax, uiExactX
    mov dx, uiY
    add dx, 6
    mov bl, 10
    call DibujarDigitoMini
    mov cl, vacasHist[si]
    mov ax, uiPartialX
    mov bl, 14
    call DibujarDigitoMini
dh_siguiente:
    inc uiFila
    jmp dh_fila
dh_fin:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
DibujarHistorial ENDP

; E: uiFila/nivel. S: origen, paso, etiquetas y conteos de esa fila.
; Preserva registros. Cada cuadro 16x16 queda dentro de (4,22)-(199,189).
CoordenadaHistorial PROC NEAR
    push ax
    push bx
    push dx
    mov ax, uiFila
    mov uiBase, 8
    mov uiX, 32
    mov uiPaso, 20
    mov uiExactX, 158
    mov uiPartialX, 182
    cmp nivel, 0
    je coh_facil
    mov bx, 16
    mul bx
    add ax, 30
    mov uiY, ax
    jmp coh_fin
coh_facil:
    mov uiX, 18
    mov uiPaso, 16
    mov uiExactX, 88
    mov uiPartialX, 96
    cmp ax, 6
    jb coh_izquierda
    sub ax, 6
    mov uiBase, 106
    mov uiX, 116
    mov uiExactX, 186
    mov uiPartialX, 194
coh_izquierda:
    mov bx, 24
    mul bx
    add ax, 38
    mov uiY, ax
coh_fin:
    pop dx
    pop bx
    pop ax
    ret
CoordenadaHistorial ENDP

; E: AL=tipo 0..7, AX ya no es coordenada; uiX/uiY=destino.
; S: sprite 16x16, dos cuadros contiguos por ficha. Preserva registros.
FichaEnCoordenada PROC NEAR
    push ax
    push bx
    push cx
    push dx
    push si
    push bp
    xor ah, ah
    mov cl, 9
    shl ax, cl
    mov si, OFFSET sprites
    add si, ax
    cmp uiFrame, 0
    je fec_cuadro
    add si, 256
fec_cuadro:
    mov ax, uiX
    mov dx, uiY
    mov cx, 16
    mov bp, 16
    call DibujarSprite
    pop bp
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
FichaEnCoordenada ENDP

; E: nTipos. S: catalogo de simbolos y teclas 1..C. Registros preservados.
DibujarCatalogo PROC NEAR
    push ax
    push bx
    push cx
    push dx
    push di
    xor di, di
    mov uiFrame, 0
    mov uiX, 208
    mov uiY, 36
dc_ficha:
    mov ax, di
    call FichaEnCoordenada
    mov ax, uiX
    add ax, 4
    mov dx, uiY
    add dx, 16
    mov cx, di
    inc cl
    mov bl, 7
    call Digito
    add uiX, 26
    inc di
    cmp di, 4
    jne dc_limite
    mov uiX, 208
    mov uiY, 62
dc_limite:
    xor cx, cx
    mov cl, nTipos
    cmp di, cx
    jb dc_ficha
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
DibujarCatalogo ENDP

; E: propuesta/activo. S: cinco celdas como maximo, borde de seleccion.
; Registros preservados. El vacio usa '-' y no el identificador cero.
DibujarPropuesta PROC NEAR
    push ax
    push bx
    push cx
    push dx
    push di
    push bp
    xor di, di
    mov uiX, 208
    mov uiY, 108
dpr_celda:
    mov uiFrame, 0
    cmp estado, ST_GAME
    je dpr_animable
    cmp estado, ST_SECRET
    jne dpr_estatico
dpr_animable:
    xor ax, ax
    mov al, activo
    cmp di, ax
    jne dpr_estatico
    mov al, cuadro
    mov uiFrame, al
dpr_estatico:
    mov ax, uiX
    mov dx, uiY
    dec ax
    dec dx
    mov cx, 18
    mov bp, 18
    mov bl, 3
    xor ax, ax
    mov al, activo
    cmp di, ax
    jne dpr_fondo
    mov bl, 14
dpr_fondo:
    mov ax, uiX
    dec ax
    call Rectangulo
    mov ax, uiX
    mov dx, uiY
    mov cx, 16
    mov bp, 16
    mov bl, 1
    call Rectangulo
    mov al, propuesta[di]
    cmp al, EMPTY
    je dpr_vacia
    call FichaEnCoordenada
    jmp dpr_siguiente
dpr_vacia:
    mov uiChar, '-'
    push si
    mov si, OFFSET uiChar
    mov ax, uiX
    add ax, 4
    mov dx, 112
    mov bl, 7
    call DibujarTexto
    pop si
dpr_siguiente:
    add uiX, 20
    inc di
    xor cx, cx
    mov cl, nFichas
    cmp di, cx
    jb dpr_celda
    pop bp
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
DibujarPropuesta ENDP

; E: estado/cuadro. S: solo region animada del framebuffer actualizada.
; Preserva registros. Restaura fondo para que los ceros no dejen rastros.
DibujarAnimacion PROC NEAR
    push ax
    push bx
    push cx
    push dx
    push si
    push bp
    cmp estado, ST_GAME
    je da_juego
    cmp estado, ST_SECRET
    je da_juego
    cmp estado, ST_SPLASH
    je da_mascota
    cmp estado, ST_WIN
    je da_final
    cmp estado, ST_LOSE
    je da_final
    jmp da_fin
da_juego:
    call DibujarPropuesta
    jmp da_fin
da_mascota:
    mov ax, 144
    mov dx, 100
    mov si, OFFSET mascota
    mov bl, 1
    jmp da_pintar
da_final:
    mov ax, 292
    mov dx, 154
    mov si, OFFSET finale
    cmp estado, ST_WIN
    je da_colorfinal
    add si, 512
da_colorfinal:
    mov bl, 2
da_pintar:
    mov cx, 16
    mov bp, 16
    call Rectangulo
    cmp cuadro, 0
    je da_sprite
    add si, 256
da_sprite:
    call DibujarSprite
da_fin:
    pop bp
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
DibujarAnimacion ENDP

; E: AX=tecla BIOS. S: transicion de estado o edicion. Preserva registros.
; Un coordinador retorna siempre al bucle principal, sin menus recursivos.
ProcesarTecla PROC NEAR
    push ax
    push bx
    cmp estado, ST_GAME
    je pt_juego
    cmp estado, ST_SECRET
    je pt_juego
    cmp estado, ST_SPLASH
    je pt_menu
    cmp estado, ST_WIN
    je pt_final
    cmp estado, ST_LOSE
    je pt_final
    cmp estado, ST_LEVEL
    je pt_nivel
    cmp estado, ST_MENU
    je pt_opciones
    cmp al, 1Bh
    je pt_menu
    cmp al, 0Dh
    je pt_menu
    jmp pt_fin
pt_juego:
    call TeclaJuego
    jmp pt_fin
pt_final:
    cmp al, 1Bh
    je pt_menu
    cmp al, 0Dh
    jne pt_fin
    call NuevaPartida
    jmp pt_fin
pt_menu:
    mov estado, ST_MENU
    jmp pt_cambio
pt_nivel:
    cmp al, 1Bh
    je pt_menu
    cmp al, 0Dh
    je pt_menu
    cmp ah, 48h
    jne pt_nivabajo
    cmp nivel, 0
    je pt_fin
    dec nivel
    jmp pt_conf
pt_nivabajo:
    cmp ah, 50h
    jne pt_fin
    cmp nivel, 2
    jae pt_fin
    inc nivel
pt_conf:
    call ConfigurarNivel
    jmp pt_cambio
pt_opciones:
    cmp ah, 3Ch
    jne pt_escape
    call PrepararManual
    jmp pt_fin
pt_escape:
    cmp al, 1Bh
    jne pt_arriba
    mov estado, ST_EXIT
    jmp pt_fin
pt_arriba:
    cmp ah, 48h
    jne pt_abajo
    cmp menuSel, 0
    je pt_fin
    dec menuSel
    jmp pt_cambio
pt_abajo:
    cmp ah, 50h
    jne pt_enter
    cmp menuSel, 4
    jae pt_fin
    inc menuSel
    jmp pt_cambio
pt_enter:
    cmp al, 0Dh
    jne pt_fin
    cmp menuSel, 0
    jne pt_sel1
    call NuevaPartida
    jmp pt_fin
pt_sel1:
    cmp menuSel, 1
    jne pt_sel2
    mov estado, ST_LEVEL
    jmp pt_cambio
pt_sel2:
    cmp menuSel, 2
    jne pt_sel3
    mov estado, ST_HELP
    jmp pt_cambio
pt_sel3:
    cmp menuSel, 3
    jne pt_sel4
    mov estado, ST_CREDITS
    jmp pt_cambio
pt_sel4:
    mov estado, ST_EXIT
pt_cambio:
    mov sucio, 1
pt_fin:
    pop bx
    pop ax
    ret
ProcesarTecla ENDP
END
