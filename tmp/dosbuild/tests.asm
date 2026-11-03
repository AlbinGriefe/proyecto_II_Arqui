.MODEL SMALL
INCLUDE common.inc
INCLUDE vars.inc
INCLUDE game.inc
INCLUDE video.inc
INCLUDE ui.inc
INCLUDE input.inc
PUBLIC EjecutarPruebas
.DATA
; Cada fila: secreto[5], propuesta[5], N, C, toros, vacas.
casos db 0,1,2,3,0, 0,2,1,3,0, 4,6,2,2
      db 0,0,1,2,0, 0,1,0,0,0, 4,6,1,2
      db 0,1,2,3,0, 4,5,4,5,0, 4,6,0,0
      db 2,2,2,2,0, 2,2,0,0,0, 4,6,2,0
      db 0,1,2,3,0, 0,1,2,3,0, 4,6,4,0
      db 0,1,2,3,0, 1,2,3,0,0, 4,6,0,4
      db 0,0,1,1,2, 1,1,0,0,2, 5,8,1,4
      db 0,0,0,0,0, 1,1,1,1,0, 4,6,0,0
fallos dw 0
comprobaciones dw 0
reporte db 'Pruebas del ASM real: evaluador, turnos, teclado y PRNG.',13,10,'$'
todoOk db 'PASS: todas las comprobaciones superadas.',13,10,'$'
hayError db 'FAIL: una o mas comprobaciones fallaron.',13,10,'$'
snapSplash db 'SPLASH.RAW',0
snapMenu db 'MENU.RAW',0
snapGame db 'GAME.RAW',0
snapWin db 'WIN.RAW',0
snapLose db 'LOSE.RAW',0
snapHard db 'HARD.RAW',0
snapHardB db 'HARDB.RAW',0
snapHelp db 'HELP.RAW',0
snapSecret db 'SECRET.RAW',0
snapSplashB db 'SPLASHB.RAW',0
snapWinB db 'WINB.RAW',0
snapLoseB db 'LOSEB.RAW',0
snapNormal db 'NORMAL.RAW',0
snapFullHard db 'FULLHARD.RAW',0
snapLevel db 'LEVEL.RAW',0
snapCredits db 'CREDITS.RAW',0
probeSprite db 0,4,0,5
countLabel db 'Comprobaciones: $'
errorLabel db ' Fallos: $'
crlf db 13,10,'$'
.CODE
; E: ZF=1 indica igualdad esperada. S: contadores incrementados.
; Preserva registros, destruye FLAGS.
Afirmar PROC NEAR
    jz af_correcto
    inc fallos
af_correcto:
    inc comprobaciones
    ret
Afirmar ENDP

; E: ninguna. S: 8 casos incluyendo los cuatro del enunciado; 16 aserciones.
; Preserva registros. Usa exactamente EvaluarIntento del ejecutable jugable.
ProbarEvaluador PROC NEAR
    push ax
    push cx
    push si
    push di
    push bp
    mov si, OFFSET casos
    mov bp, 8
pe_caso:
    xor di, di
    mov cx, MAX_N
pe_copiar:
    mov al, [si]
    mov secreto[di], al
    mov al, [si+5]
    mov propuesta[di], al
    inc si
    inc di
    loop pe_copiar
    add si, 5
    mov al, [si]
    mov nFichas, al
    mov al, [si+1]
    mov nTipos, al
    call EvaluarIntento
    mov al, [si+2]
    cmp toros, al
    call Afirmar
    mov al, [si+3]
    cmp vacas, al
    call Afirmar
    add si, 4
    dec bp
    jnz pe_caso
    pop bp
    pop di
    pop si
    pop cx
    pop ax
    ret
ProbarEvaluador ENDP

; E: ninguna. S: comprueba validacion, turno final, historial y modo manual.
; Preserva registros. No requiere inicializar VGA.
ProbarPartida PROC NEAR
    push ax
    push cx
    push si
    mov nivel, 0
    call NuevaPartida
    call ConfirmarIntento
    cmp usados, 0
    call Afirmar
    cmp mensaje, MSG_HOLES
    call Afirmar
    ; Teclado: numeros, mover, borrar e ignorar ficha fuera del rango.
    mov ax, 0231h
    call TeclaJuego
    cmp propuesta, 0
    call Afirmar
    mov ax, 4D00h
    call TeclaJuego
    cmp activo, 1
    call Afirmar
    mov ax, 0938h
    call TeclaJuego
    cmp propuesta+1, EMPTY
    call Afirmar
    mov ax, 0332h
    call TeclaJuego
    mov ax, 0E08h
    call TeclaJuego
    cmp propuesta+1, EMPTY
    call Afirmar
    ; Entrada manual permite repetir incluso usando configuracion Facil.
    call PrepararManual
    mov propuesta, 0
    mov propuesta+1, 0
    mov propuesta+2, 1
    mov propuesta+3, 2
    call ConfirmarIntento
    cmp estado, ST_GAME
    call Afirmar
    cmp secreto+1, 0
    call Afirmar
    cmp usados, 0
    call Afirmar
    ; Se guarda un fallo y se limpia la propuesta del turno siguiente.
    mov propuesta, 5
    mov propuesta+1, 5
    mov propuesta+2, 5
    mov propuesta+3, 5
    call ConfirmarIntento
    cmp usados, 1
    call Afirmar
    cmp historial, 5
    call Afirmar
    cmp propuesta, EMPTY
    call Afirmar
    ; El ultimo intento correcto gana, aunque ya no queden turnos.
    mov usados, 11
    xor si, si
    mov cx, 4
pp_acierto:
    mov al, secreto[si]
    mov propuesta[si], al
    inc si
    loop pp_acierto
    call ConfirmarIntento
    cmp estado, ST_WIN
    call Afirmar
    cmp usados, 12
    call Afirmar
    cmp torosHist+11, 4
    call Afirmar
    call NuevaPartida
    mov usados, 11
    ; Facil nunca genera el secreto 5,5,5,5.
    mov propuesta, 5
    mov propuesta+1, 5
    mov propuesta+2, 5
    mov propuesta+3, 5
    call ConfirmarIntento
    cmp estado, ST_LOSE
    call Afirmar
    cmp usados, 12
    call Afirmar
    call NuevaPartida
    cmp usados, 0
    call Afirmar
    cmp historial, EMPTY
    call Afirmar
    cmp estado, ST_GAME
    call Afirmar
    pop si
    pop cx
    pop ax
    ret
ProbarPartida ENDP

; E: ninguna. S: prueba 512 secretos en los 3 niveles, rangos y no repeticion.
; Preserva registros. Compara contra copia anterior independiente del generador.
ProbarAzar PROC NEAR
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp
    mov nivel, 0
    mov rng, 1234h
pa_nivel:
    call ConfigurarNivel
    call GenerarSecreto
    mov bp, 512
pa_partida:
    ; La copia previa se guarda en propuesta; no en 'anterior' que actualiza GS.
    xor si, si
    xor cx, cx
    mov cl, nFichas
pa_prev:
    mov al, secreto[si]
    mov propuesta[si], al
    inc si
    loop pa_prev
    call GenerarSecreto
    xor si, si
    xor dx, dx
pa_pos:
    mov al, secreto[si]
    cmp al, nTipos
    jb pa_rango_ok
    inc fallos
pa_rango_ok:
    inc comprobaciones
    cmp al, propuesta[si]
    je pa_igual
    inc dx
pa_igual:
    cmp repeticion, 0
    jne pa_siguiente
    xor di, di
pa_unico:
    cmp di, si
    jae pa_siguiente
    cmp al, secreto[di]
    jne pa_unico_ok
    inc fallos
pa_unico_ok:
    inc comprobaciones
    inc di
    jmp pa_unico
pa_siguiente:
    inc si
    xor cx, cx
    mov cl, nFichas
    cmp si, cx
    jb pa_pos
    cmp dx, 0
    jne pa_distinto
    inc fallos
pa_distinto:
    inc comprobaciones
    dec bp
    jnz pa_partida
    inc nivel
    cmp nivel, 3
    jb pa_nivel
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
ProbarAzar ENDP

; E: DS:DX=archivo de captura en directorio de pruebas. S: VGA de 64000 bytes.
; Registros preservados. Los errores de archivo incrementan fallos.
CapturarPantalla PROC NEAR
    push ax
    push bx
    push cx
    push dx
    push ds
    xor cx, cx
    mov ah, 3Ch
    int 21h
    jc cap_error
    mov bx, ax
    mov ax, 0A000h
    mov ds, ax
    xor dx, dx
    mov cx, 64000
    mov ah, 40h
    int 21h
    pop ds
    push ds
    jc cap_cerrar_error
    cmp ax, 64000
    jne cap_cerrar_error
    mov ah, 3Eh
    int 21h
    jc cap_error
    jmp cap_fin
cap_cerrar_error:
    mov ah, 3Eh
    int 21h
cap_error:
    pop ds
    push ds
    inc fallos
cap_fin:
    pop ds
    pop dx
    pop cx
    pop bx
    pop ax
    ret
CapturarPantalla ENDP

; E: estado. S: dibuja, presenta y preserva todos los registros.
RenderPrueba PROC NEAR
    call DibujarPantalla
    call Presentar
    ret
RenderPrueba ENDP

; E: DX=archivo B. S: captura el segundo cuadro sin redibujar el fondo completo.
; Preserva registros; permite detectar restos de los cuadros transparentes.
CapturarAnimacionB PROC NEAR
    mov cuadro, 1
    call DibujarAnimacion
    call Presentar
    call CapturarPantalla
    mov cuadro, 0
    ret
CapturarAnimacionB ENDP

; E: ninguna. S: dos partidas perdidas de diez intentos con propuestas variadas.
; Preserva registros. Usa ConfirmarIntento real para llenar todas las filas.
ProbarHistoriasLlenas PROC NEAR
    push ax
    push bx
    push cx
    push dx
    push si
    push bp
    mov nivel, 1
phl_nivel:
    call NuevaPartida
    xor si, si
    mov al, nTipos
    dec al
    mov cx, MAX_N
phl_secreto:
    mov secreto[si], al
    inc si
    loop phl_secreto
    xor bp, bp
phl_turno:
    xor si, si
phl_casilla:
    mov ax, bp
    add ax, si
    xor dx, dx
    xor bx, bx
    mov bl, nTipos
    div bx
    mov propuesta[si], dl
    inc si
    xor cx, cx
    mov cl, nFichas
    cmp si, cx
    jb phl_casilla
    call ConfirmarIntento
    inc bp
    cmp bp, 10
    jb phl_turno
    cmp estado, ST_LOSE
    call Afirmar
    cmp usados, 10
    call Afirmar
    call RenderPrueba
    mov dx, OFFSET snapNormal
    cmp nivel, 1
    je phl_captura
    mov dx, OFFSET snapFullHard
phl_captura:
    call CapturarPantalla
    inc nivel
    cmp nivel, 3
    jb phl_nivel
    pop bp
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
ProbarHistoriasLlenas ENDP

; E: AX=tecla BIOS. S: tecla insertada, leida por BIOS y enviada al coordinador.
; Preserva registros. Se comprueban cola, disponibilidad y valor leido.
InyectarTeclaPrueba PROC NEAR
    push ax
    push bx
    push cx
    mov bx, ax
    mov cx, ax
    mov ah, 05h
    int 16h
    cmp al, 0
    call Afirmar
    call LeerTecla
    jc itp_disponible
    inc fallos
itp_disponible:
    inc comprobaciones
    cmp ax, bx
    call Afirmar
    call ProcesarTecla
    pop cx
    pop bx
    pop ax
    ret
InyectarTeclaPrueba ENDP

; E: ninguna. S: prueba BIOS de editar/borrar/mover/salir y reloj de animacion.
; Preserva registros. Espera tres tics BIOS, aproximadamente 165 ms.
ProbarEntradaYReloj PROC NEAR
    push ax
    push bx
    push dx
    mov nivel, 0
    call NuevaPartida
    mov ax, 0231h
    call InyectarTeclaPrueba
    cmp propuesta, 0
    call Afirmar
    mov ax, 4D00h
    call InyectarTeclaPrueba
    cmp activo, 1
    call Afirmar
    mov ax, 0332h
    call InyectarTeclaPrueba
    cmp propuesta+1, 1
    call Afirmar
    mov ax, 0E08h
    call InyectarTeclaPrueba
    cmp propuesta+1, EMPTY
    call Afirmar
    mov ax, 1C0Dh
    call InyectarTeclaPrueba
    cmp usados, 0
    call Afirmar
    cmp mensaje, MSG_HOLES
    call Afirmar
    mov ax, 4B00h
    call InyectarTeclaPrueba
    cmp activo, 0
    call Afirmar
    mov ax, 4800h
    call InyectarTeclaPrueba
    cmp propuesta, 1
    call Afirmar
    mov ax, 5000h
    call InyectarTeclaPrueba
    cmp propuesta, 0
    call Afirmar
    mov ax, 0938h
    call InyectarTeclaPrueba
    cmp propuesta, 0
    call Afirmar
    mov ax, 011Bh
    call InyectarTeclaPrueba
    cmp estado, ST_MENU
    call Afirmar
    mov menuSel, 1
    mov ax, 1C0Dh
    call InyectarTeclaPrueba
    cmp estado, ST_LEVEL
    call Afirmar
    mov ax, 5000h
    call InyectarTeclaPrueba
    cmp nivel, 1
    call Afirmar
    cmp maxTurnos, 10
    call Afirmar
    mov ax, 1C0Dh
    call InyectarTeclaPrueba
    cmp estado, ST_MENU
    call Afirmar
    mov menuSel, 2
    call InyectarTeclaPrueba
    cmp estado, ST_HELP
    call Afirmar
    mov ax, 011Bh
    call InyectarTeclaPrueba
    cmp estado, ST_MENU
    call Afirmar
    mov menuSel, 4
    mov ax, 1C0Dh
    call InyectarTeclaPrueba
    cmp estado, ST_EXIT
    call Afirmar
    call LeerTic
    mov ultimoTic, dx
    mov bx, dx
    mov cuadro, 0
peyr_espera:
    call LeerTic
    sub dx, bx
    cmp dx, ANIM_TICKS
    jb peyr_espera
    call ActualizarReloj
    jc peyr_cambio
    inc fallos
peyr_cambio:
    inc comprobaciones
    cmp cuadro, 1
    call Afirmar
    pop dx
    pop bx
    pop ax
    ret
ProbarEntradaYReloj ENDP

; E: paleta VGA cargada. S: compara cada componente del DAC con la tabla del EXE.
; Preserva registros; detecta cargas truncadas al ampliar la paleta de los sprites.
ProbarPaleta PROC NEAR
    push ax
    push cx
    push dx
    push si
    mov dx, 3C7h
    xor al, al
    out dx, al
    mov dx, 3C9h
    mov si, OFFSET paleta
    mov cx, OFFSET paletaFin
    sub cx, si
ppal_componente:
    in al, dx
    cmp al, [si]
    call Afirmar
    inc si
    loop ppal_componente
    pop si
    pop dx
    pop cx
    pop ax
    ret
ProbarPaleta ENDP

; E: ninguna. S: verifica transparencia, limites y rutas de pantallas en VGA.
; Preserva registros. Captura imagenes de diagnostico y restaura el modo previo.
ProbarVideo PROC NEAR
    push ax
    push bx
    push cx
    push dx
    push si
    push bp
    push es
    call IniciarVideo
    call CargarPaleta
    call ProbarPaleta
    mov al, 14
    call LimpiarPantalla
    mov si, OFFSET probeSprite
    mov ax, 318
    mov dx, 198
    mov cx, 2
    mov bp, 2
    call DibujarSprite
    call Presentar
    mov ax, 0A000h
    mov es, ax
    cmp BYTE PTR es:[63678], 14
    call Afirmar
    cmp BYTE PTR es:[63679], 4
    call Afirmar
    cmp BYTE PTR es:[63999], 5
    call Afirmar
    ; Un sprite que cruza el borde debe rechazarse, sin escribir.
    mov ax, 319
    call DibujarSprite
    jc pv_rechazado
    inc fallos
pv_rechazado:
    inc comprobaciones
    mov estado, ST_SPLASH
    call RenderPrueba
    mov dx, OFFSET snapSplash
    call CapturarPantalla
    mov dx, OFFSET snapSplashB
    call CapturarAnimacionB
    mov ax, 1C0Dh
    call ProcesarTecla
    cmp estado, ST_MENU
    call Afirmar
    call RenderPrueba
    mov dx, OFFSET snapMenu
    call CapturarPantalla
    mov nivel, 0
    mov ax, 3C00h
    call ProcesarTecla
    cmp estado, ST_SECRET
    call Afirmar
    call RenderPrueba
    mov dx, OFFSET snapSecret
    call CapturarPantalla
    mov propuesta, 0
    mov propuesta+1, 0
    mov propuesta+2, 1
    mov propuesta+3, 2
    mov ax, 1C0Dh
    call ProcesarTecla
    mov propuesta, 0
    mov propuesta+1, 1
    mov propuesta+2, 0
    mov propuesta+3, 0
    call ProcesarTecla
    call RenderPrueba
    mov dx, OFFSET snapGame
    call CapturarPantalla
    mov propuesta, 0
    mov propuesta+1, 0
    mov propuesta+2, 1
    mov propuesta+3, 2
    mov ax, 1C0Dh
    call ProcesarTecla
    cmp estado, ST_WIN
    call Afirmar
    call RenderPrueba
    mov dx, OFFSET snapWin
    call CapturarPantalla
    mov dx, OFFSET snapWinB
    call CapturarAnimacionB
    call PrepararManual
    mov propuesta, 0
    mov propuesta+1, 0
    mov propuesta+2, 1
    mov propuesta+3, 2
    mov ax, 1C0Dh
    call ProcesarTecla
    mov bp, 12
pv_agotar:
    mov propuesta, 5
    mov propuesta+1, 5
    mov propuesta+2, 5
    mov propuesta+3, 5
    mov ax, 1C0Dh
    call ProcesarTecla
    dec bp
    jnz pv_agotar
    cmp estado, ST_LOSE
    call Afirmar
    call RenderPrueba
    mov dx, OFFSET snapLose
    call CapturarPantalla
    mov dx, OFFSET snapLoseB
    call CapturarAnimacionB
    mov nivel, 2
    call NuevaPartida
    ; Capturar fichas distintas en propuesta y ambos cuadros para revisar offsets.
    mov propuesta, 0
    mov propuesta+1, 3
    mov propuesta+2, 5
    mov propuesta+3, 6
    mov propuesta+4, 7
    mov cuadro, 0
    call RenderPrueba
    mov dx, OFFSET snapHard
    call CapturarPantalla
    mov cuadro, 1
    call DibujarAnimacion
    call Presentar
    mov dx, OFFSET snapHardB
    call CapturarPantalla
    ; Vuelve al menu y comprueba el resto de pantallas y seleccion de nivel.
    mov ax, 011Bh
    call ProcesarTecla
    mov menuSel, 1
    mov ax, 1C0Dh
    call ProcesarTecla
    cmp estado, ST_LEVEL
    call Afirmar
    mov ax, 4800h
    call ProcesarTecla
    cmp nivel, 1
    call Afirmar
    call RenderPrueba
    mov dx, OFFSET snapLevel
    call CapturarPantalla
    mov ax, 1C0Dh
    call ProcesarTecla
    mov menuSel, 2
    call ProcesarTecla
    cmp estado, ST_HELP
    call Afirmar
    call RenderPrueba
    mov dx, OFFSET snapHelp
    call CapturarPantalla
    mov ax, 011Bh
    call ProcesarTecla
    mov menuSel, 3
    mov ax, 1C0Dh
    call ProcesarTecla
    cmp estado, ST_CREDITS
    call Afirmar
    call RenderPrueba
    mov dx, OFFSET snapCredits
    call CapturarPantalla
    call ProbarHistoriasLlenas
    call ProbarEntradaYReloj
    call RestaurarVideo
    mov ah, 0Fh
    int 10h
    and al, 7Fh
    cmp al, modoPrevio
    call Afirmar
    pop es
    pop bp
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
ProbarVideo ENDP

; E: AX=palabra sin signo. S: decimal en stdout DOS. Preserva registros.
ImprimirEntero PROC NEAR
    push ax
    push bx
    push cx
    push dx
    xor cx, cx
    mov bx, 10
ip_dividir:
    xor dx, dx
    div bx
    push dx
    inc cx
    or ax, ax
    jnz ip_dividir
ip_digito:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop ip_digito
    pop dx
    pop cx
    pop bx
    pop ax
    ret
ImprimirEntero ENDP

; E: ninguna. S: AL=0 exito, AL=1 fallo; reporte DOS en stdout.
; Destruye AX/DX/FLAGS. Restaura video y guarda capturas RAW de diagnostico.
EjecutarPruebas PROC NEAR
    mov dx, OFFSET reporte
    mov ah, 09h
    int 21h
    call ProbarEvaluador
    call ProbarPartida
    call ProbarAzar
    call ProbarVideo
    mov dx, OFFSET countLabel
    mov ah, 09h
    int 21h
    mov ax, comprobaciones
    call ImprimirEntero
    mov dx, OFFSET errorLabel
    mov ah, 09h
    int 21h
    mov ax, fallos
    call ImprimirEntero
    mov dx, OFFSET crlf
    mov ah, 09h
    int 21h
    cmp fallos, 0
    jne ep_error
    mov dx, OFFSET todoOk
    mov ah, 09h
    int 21h
    xor al, al
    ret
ep_error:
    mov dx, OFFSET hayError
    mov ah, 09h
    int 21h
    mov al, 1
    ret
EjecutarPruebas ENDP
END
