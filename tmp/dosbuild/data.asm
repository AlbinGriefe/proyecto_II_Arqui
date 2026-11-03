.MODEL SMALL
INCLUDE common.inc
PUBLIC estado, sucio, menuSel, nivel, nFichas, nTipos, maxTurnos, repeticion
PUBLIC activo, usados, mensaje, manual, secreto, propuesta, historial
PUBLIC torosHist, vacasHist, toros, vacas, frecSec, frecProp
PUBLIC anterior, anteriorN, rng, modoPrevio, paginaPrevia
PUBLIC fuenteSeg, fuenteOff, ultimoTic, cuadro, paleta, paletaFin, sprites, mascota, finale
PUBLIC nivelPtrs, menuPtrs, mensajePtrs
PUBLIC txtTitle, txtSplash, txtPending, txtContinue, txtMenu, txtLevel
PUBLIC txtHelp, txtCredits, txtTeam, txtEsc, txtRules1, txtRules2
PUBLIC txtRules3, txtRules4, txtRules5, txtRules6, txtRules7, txtRules8, txtRules9
PUBLIC txtBoard, txtCatalog, txtGuess, txtTurn, txtLeft, txtWon, txtLost
PUBLIC txtAgain, txtSecret, txtDebug, txtManual, txtManual2, txtManual3
PUBLIC txtAgainLost, txtMiniT, txtMiniV, txtCodeLabel, txtExampleLabel
PUBLIC txtScoreExample, txtScorePartial, txtHelpFooter, txtManual4, txtManual5, txtManual6
PUBLIC nivelDescPtrs, txtCreditDesign
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

txtTitle db 'CLAVE DULCE',0
txtSplash db 'MASTERMIND DE DULCES',0
txtPending db 'Un reto de ingenio y reposteria',0
txtContinue db 'Pulsa una tecla para continuar',0
txtTeam db 'Integrantes: pendientes de completar',0
txtMenu db 'MENU PRINCIPAL',0
txtLevel db 'DIFICULTAD (ARRIBA / ABAJO)',0
txtHelp db 'INSTRUCCIONES',0
txtCredits db 'CREDITOS',0
txtEsc db 'Flechas + ENTER / ESC: volver o salir',0
txtRules1 db 'Descubre la clave de dulces.',0
txtRules2 db 'T: dulce y lugar correctos.',0
txtRules3 db 'V: dulce correcto, otro lugar.',0
txtRules4 db 'Izq/der: casilla. Arr/abajo: dulce.',0
txtRules5 db '1..C: elegir. BKSP: borrar.',0
txtRules6 db 'ENTER: evaluar. ESC: volver.',0
txtRules7 db 'Facil: el secreto no repite dulces.',0
txtRules8 db 'Normal/Dificil: admite repetidos.',0
txtRules9 db 'Cada ficha cuenta una sola vez.',0
txtBoard db 'DULCES',0
txtCatalog db 'FICHAS 1..C',0
txtGuess db 'TU PROPUESTA',0
txtTurn db 'Turno:',0
txtLeft db 'Quedan:',0
txtWon db 'GANASTE',0
txtLost db 'PERDISTE',0
txtAgain db 'GANASTE! ENTER: otra / ESC: menu',0
txtAgainLost db 'PERDISTE. ENTER: otra / ESC: menu',0
txtSecret db 'SECRETO:',0
txtDebug db 'F2: ingresar secreto de prueba',0
txtManual db 'MODO DE PRUEBAS',0
txtManual2 db 'Elige la clave a la',0
txtManual3 db 'derecha. ENTER la oculta',0
txtManual4 db 'e inicia la partida.',0
txtManual5 db 'R=1 V=2 A=3 M=4 N=5 B=6',0
txtManual6 db 'Repetidos: permitidos.',0
txtMiniT db 'T',0
txtMiniV db 'V',0
txtCodeLabel db 'SECRETO',0
txtExampleLabel db 'PROPUESTA',0
txtScoreExample db 'T=2',0
txtScorePartial db 'V=2',0
txtHelpFooter db 'Al terminar se muestra el secreto.',0
txtCreditDesign db 'Dulces, confitero y pasteles animados',0

nivFacil db 'Facil',0
nivNormal db 'Normal',0
nivDificil db 'Dificil',0
nivelPtrs dw OFFSET nivFacil, OFFSET nivNormal, OFFSET nivDificil
nivDescFacil db '4 casillas / 6 dulces / 12 intentos',0
nivDescNormal db '4 casillas / 6 dulces / 10 intentos',0
nivDescDificil db '5 casillas / 8 dulces / 10 intentos',0
nivelDescPtrs dw OFFSET nivDescFacil, OFFSET nivDescNormal, OFFSET nivDescDificil
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
