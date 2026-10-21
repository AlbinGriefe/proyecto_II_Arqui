.MODEL SMALL
INCLUDE common.inc
PUBLIC estado, sucio, menuSel, nivel, nFichas, nTipos, maxTurnos, repeticion
PUBLIC activo, usados, mensaje, manual, secreto, propuesta, historial
PUBLIC torosHist, vacasHist, toros, vacas, frecSec, frecProp
PUBLIC anterior, anteriorN, rng, modoPrevio, paginaPrevia
PUBLIC fuenteSeg, fuenteOff, ultimoTic, cuadro, paleta, sprites, mascota, finale
PUBLIC nivelPtrs, menuPtrs, mensajePtrs
PUBLIC txtTitle, txtSplash, txtPending, txtContinue, txtMenu, txtLevel
PUBLIC txtHelp, txtCredits, txtTeam, txtEsc, txtRules1, txtRules2
PUBLIC txtRules3, txtRules4, txtRules5, txtRules6, txtRules7, txtRules8, txtRules9
PUBLIC txtBoard, txtCatalog, txtGuess, txtTurn, txtLeft, txtWon, txtLost
PUBLIC txtAgain, txtSecret, txtDebug, txtManual, txtManual2, txtManual3
.DATA
estado db ST_SPLASH
sucio db 1
menuSel db 0
nivel db 0
nFichas db 4
nTipos db 6
maxTurnos db 12
repeticion db 0
activo db 0
usados db 0
mensaje db MSG_KEYS
manual db 0
secreto db MAX_N dup (0)
propuesta db MAX_N dup (EMPTY)
historial db MAX_TURNS*MAX_N dup (EMPTY)
torosHist db MAX_TURNS dup (0)
vacasHist db MAX_TURNS dup (0)
toros db 0
vacas db 0
frecSec db MAX_C dup (0)
frecProp db MAX_C dup (0)
anterior db MAX_N dup (0)
anteriorN db 0
rng dw 1
modoPrevio db 3
paginaPrevia db 0
fuenteSeg dw 0
fuenteOff dw 0
ultimoTic dw 0
cuadro db 0

txtTitle db 'CLAVE / PROTOTIPO',0
txtSplash db 'MASTERMIND - AVANCE 1',0
txtPending db 'Graficos y tema provisionales',0
txtContinue db 'Pulsa una tecla para continuar',0
txtTeam db 'Integrantes: pendientes de completar',0
txtMenu db 'MENU PRINCIPAL',0
txtLevel db 'DIFICULTAD (ARRIBA / ABAJO)',0
txtHelp db 'INSTRUCCIONES',0
txtCredits db 'CREDITOS',0
txtEsc db 'Flechas + ENTER / ESC: volver o salir',0
txtRules1 db 'Adivina el codigo secreto de N fichas.',0
txtRules2 db 'T: ficha y posicion correctas (toro).',0
txtRules3 db 'V: ficha correcta, otra posicion.',0
txtRules4 db 'Izq/der: posicion. Arriba/abajo: ficha.',0
txtRules5 db '1..C: ficha. BACKSPACE: vaciar casilla.',0
txtRules6 db 'ENTER: evaluar si no quedan huecos.',0
txtRules7 db 'Facil: 4/6/12, secreto sin repetidos.',0
txtRules8 db 'Normal:4/6/10. Dificil:5/8/10. N/C/I.',0
txtRules9 db 'Cada ficha cuenta una sola vez.',0
txtBoard db '#  PROPUESTA      T  V',0
txtCatalog db 'FICHAS 1..C',0
txtGuess db 'TU PROPUESTA',0
txtTurn db 'Turno:',0
txtLeft db 'Quedan:',0
txtWon db 'GANASTE           T  V',0
txtLost db 'FIN: SIN TURNOS   T  V',0
txtAgain db 'ENTER: otra partida / ESC: menu',0
txtSecret db 'SECRETO:',0
txtDebug db 'F2: ingresar secreto de prueba',0
txtManual db 'MODO DE PRUEBAS',0
txtManual2 db 'Edita el secreto en el panel derecho.',0
txtManual3 db 'ENTER lo oculta e inicia la partida.',0

nivFacil db 'Facil',0
nivNormal db 'Normal',0
nivDificil db 'Dificil',0
nivelPtrs dw OFFSET nivFacil, OFFSET nivNormal, OFFSET nivDificil
opJugar db 'Jugar',0
opNivel db 'Nivel de dificultad',0
opAyuda db 'Instrucciones',0
opCred db 'Creditos',0
opSalir db 'Salir',0
menuPtrs dw OFFSET opJugar, OFFSET opNivel, OFFSET opAyuda, OFFSET opCred, OFFSET opSalir
msgKeys db 'Flechas/1..C  ENTER  BKSP  ESC',0
msgHoles db 'Faltan fichas: no se gasto un intento.',0
msgSaved db 'Guardado. Construye el siguiente.',0
msgManual db 'Secreto manual: repetidos permitidos.',0
mensajePtrs dw OFFSET msgKeys, OFFSET msgHoles, OFFSET msgSaved, OFFSET msgManual
INCLUDE palette.inc
INCLUDE sprites.inc
END
