# Arquitectura y lógica del primer avance

## Qué hace cada archivo

| Módulo | Responsabilidad | Por qué se separa |
| --- | --- | --- |
| `main.asm` | Inicializa DS, elige modo de pruebas o juego, coordina reloj/teclado/dibujo y termina en DOS. | Mantiene visible el ciclo de vida completo sin mezclar reglas del juego. |
| `data.asm` | Reserva estado, arreglos y mensajes; incorpora paleta y sprites. | Evita reservar dos copias de una variable compartida. |
| `video.asm` | Modo de video, fuente, paleta, rectángulos, sprites, texto y presentación del framebuffer. | Centraliza los accesos a memoria y puertos VGA. |
| `input.asm` | Consulta/consumo de teclas y temporización BIOS. | Permite animación durante la espera del jugador. |
| `game.asm` | Dificultades, PRNG, secreto, propuesta, evaluación, historial y resultado. | Puede probarse sin depender de la estética de la pantalla. |
| `ui.asm` | Compone pantallas y convierte teclas en acciones según el estado. | Un mismo dato lógico puede representarse con otros sprites posteriormente. |
| `tests.asm` | Pruebas ejecutadas por `/T`, incluidos recorridos gráficos y capturas VGA. | Verifica las mismas rutinas enlazadas en el juego. |

`common.inc` contiene constantes y la macro `TEXTO`. `vars.inc` declara variables externas. `video.inc`, `game.inc`, `input.inc`, `ui.inc` y `tests.inc` declaran los procedimientos públicos. Los includes no se ejecutan: TASM incorpora su texto al ensamblar.

## Cómo un ASM llama a otro

En `game.asm`:

```asm
PUBLIC NuevaPartida
.CODE
NuevaPartida PROC NEAR
    ; Preparar datos y secreto...
    ret
NuevaPartida ENDP
```

En `game.inc`, que incluye `ui.asm`:

```asm
EXTRN NuevaPartida:NEAR
```

En `ui.asm`:

```asm
call NuevaPartida
```

Primero TASM genera `GAME.OBJ` y `UI.OBJ`. Después TLINK encuentra la definición pública y resuelve la dirección de la llamada. **El programa llama a un procedimiento, no abre otro archivo ASM en ejecución.** Todos los módulos usan `.MODEL SMALL`; el mapa de enlace confirma que sus rutinas se combinan en `_TEXT`, por lo que las llamadas son NEAR. Separar fuentes no obliga a usar FAR.

Las rutinas documentan entradas, salidas y registros. Los registros que no representan resultados se preservan con PUSH/POP. FLAGS se considera destruido salvo los contratos que devuelven CF. La directiva `JUMPS` permite a TASM expandir saltos condicionales largos en secuencias compatibles con 8086. No se incorporan instrucciones de 32 bits ni bibliotecas gráficas.

## Estados y ciclo principal

`estado` identifica presentación, menú, dificultad, instrucciones, créditos, partida, victoria, derrota, editor de secreto o salida. `ProcesarTecla` despacha la entrada según esa variable. Una transición cambia `estado`, marca `sucio=1` y retorna al coordinador; no llama recursivamente al menú ni a `main`.

En cada iteración:

1. Si `sucio` está activo, dibujar la pantalla completa en el framebuffer y presentarla.
2. Consultar el reloj. Si vencieron tres tics, alternar el cuadro de animación, restaurar su región, dibujar y presentar.
3. Consultar el teclado. Si existe una tecla, consumirla y procesarla; si no, continuar el ciclo.

`LeerTecla` usa INT 16h AH=01h para consultar y AH=00h para consumir. CF=1 indica una tecla disponible en AX; AL contiene ASCII y AH el scan code. La consulta sin consumo dejaría la misma tecla pendiente. Las teclas sin acción reconocida retornan sin cambiar el juego.

`LeerTic` lee la palabra baja de 0040h:006Ch. La resta modular contra `ultimoTic` admite el desbordamiento de 16 bits; si ocurre el reinicio diario, se resincroniza en una actualización. No se usa un contador de bucles para decidir la velocidad. La animación alterna cuadros cada tres tics, aproximadamente 165 ms.

## Datos y dificultades

| Dato | Tamaño | Uso |
| --- | ---: | --- |
| `secreto`, `propuesta`, `anterior` | 5 bytes cada uno | Longitud activa determinada por N. |
| `historial` | 60 bytes | 12 filas con paso fijo de cinco bytes. |
| `torosHist`, `vacasHist` | 12 bytes cada uno | Retroalimentación independiente de la propuesta actual. |
| `frecSec`, `frecProp` | 8 bytes cada uno | Frecuencias de las posiciones que no fueron exactas. |
| `rng` | 2 bytes | Estado del generador. |
| `SCREEN` | 64.000 bytes | Framebuffer en segmento independiente de DGROUP. |
| Pila | 512 bytes | Llamadas y registros temporales. |

`offsetHistorial = fila*5 + columna`. El paso permanece fijo aunque el nivel utilice cuatro fichas. Las posiciones no utilizadas se mantienen como huecos.

| Nivel | N | C | Turnos | Secreto repetido |
| --- | ---: | ---: | ---: | --- |
| Fácil | 4 | 6 | 12 | No. |
| Normal | 4 | 6 | 10 | Sí. |
| Difícil | 5 | 8 | 10 | Sí. |

`ConfigurarNivel` lee una tabla con esos cuatro parámetros por nivel. El identificador de ficha es 0..C−1; FFh significa vacío. El número visible y la tecla son identificador+1. El valor de ficha 0 es válido y **no tiene relación** con el índice de píxel 0 transparente.

## Generación del secreto

`SembrarAzar` obtiene CX:DX mediante INT 1Ah AH=00h y combina las palabras para inicializar el estado. `SiguienteAzar` actualiza:

```text
estado = (estado * 25173 + 13849) mod 65536
```

Se toma el byte alto del estado y se reduce al rango 0..C−1. Usar directamente los bits bajos de un generador congruencial produciría patrones especialmente cortos en ciertos rangos. La reducción módulo C no pretende proporcionar una distribución perfectamente uniforme; es suficiente para este generador de juego y queda aislada si se desea mejorar.

En Fácil se compara cada candidato con las posiciones ya elegidas y se rechaza si existe. Tras completar N posiciones se compara con `anterior`, incluso al alternar Fácil y Normal porque tienen igual longitud. Si el código completo coincide, se genera otro. El nivel anterior con N diferente ya representa otro código por longitud.

La entrada manual no pasa por el generador y no modifica el registro del último secreto aleatorio. Permite introducir los cuatro casos del docente sin quedar bloqueada por la prohibición de repetir en el secreto aleatorio de Fácil.

## Evaluación y turnos

`EvaluarIntento` trabaja con entradas ya validadas:

```text
toros = vacas = 0
vaciar ambas tablas de frecuencias
para cada posicion i:
    si secreto[i] == propuesta[i]:
        toros += 1
    en otro caso:
        frecuenciaSecreto[secreto[i]] += 1
        frecuenciaPropuesta[propuesta[i]] += 1
para cada tipo de ficha:
    vacas += min(frecuenciaSecreto[tipo], frecuenciaPropuesta[tipo])
```

Los exactos quedan excluidos de las frecuencias; el mínimo impide contar fichas sobrantes. El evaluador no consume turnos ni altera las entradas. Por ejemplo, `RRVA / RVRR` deja un exacto y dos parciales, aunque la propuesta tenga una R adicional.

`ConfirmarIntento` valida primero todas las posiciones. Un hueco o un identificador fuera de rango produce aviso y conserva el turno. En una partida válida evalúa, copia propuesta y conteos al historial, incrementa `usados` y comprueba victoria **antes** de comprobar agotamiento. Por eso un acierto en el último intento gana. Si la partida continúa, vacía las cinco posiciones y vuelve a la primera.

`ReiniciarDatos` borra historial, mensajes y propuesta, pero mantiene la configuración y el estado que necesita el generador entre partidas. Así, regresar al menú e iniciar otra partida no deja resultados antiguos.

## Video y representación

Antes de entrar en 13h se guarda el modo con INT 10h AH=0Fh; al terminar se restaura ese modo y su página. Esto no captura ni reconstruye el contenido anterior de la pantalla. La salida normal usa INT 21h AH=4Ch.

La fuente ROM 8×8 se localiza mediante INT 10h AX=1130h BH=3. Cada glifo se dibuja recorriendo sus bits en el framebuffer; no se usa INT 10h AH=0Ch para píxeles. Los textos del programa usan ASCII sin tildes para mantener una representación consistente con esa fuente.

La dirección de un píxel es `y*320+x`. `DibujarSprite` recibe DS:SI, AX=x, DX=y, CX=ancho y BP=alto. Rechaza tamaño cero o un rectángulo que no cabe; no realiza recorte parcial. Recorre filas de izquierda a derecha y omite el índice 0. Devuelve CF=1 al rechazarlo y preserva los registros. Se presupone que el llamador proporciona al menos ancho×alto bytes válidos.

El destino de rectángulos, texto y sprites es `SCREEN`. `Presentar` copia 32.000 palabras con `CLD` y `REP MOVSW` hacia A000h. Componer la imagen fuera de VGA evita mostrar las etapas de borrado y dibujo. La copia no está sincronizada con el retrazo vertical: queda pendiente comprobar desgarro visual en la configuración final del curso.

La paleta se programa con OUT en 3C8h/3C9h a partir de 16 tripletas RGB 0..63. Los sprites actuales tienen dos cuadros de 256 bytes: `tipo*512 + cuadro*256`. Mascota, victoria y derrota también tienen dos cuadros; sus diseños son marcadores temporales. Antes de cambiar un cuadro se restaura el fondo para eliminar los píxeles de la imagen anterior.

El historial usa números de ficha de 8×8, en filas de 13 píxeles, para mantener 12 intentos dentro del tablero de 168 píxeles de alto. El catálogo y la propuesta usan los sprites de 16×16. Esta decisión tiene que revisarse con los diseños definitivos y el conflicto de la maqueta.

## Referencias técnicas consultadas

La memoria y el PDF definen los requisitos. Para confirmar las interfaces se consultó HelpPC: [fuente ROM](https://helppc.netcore2k.net/interrupt/int-10-11), [teclado no bloqueante](https://helppc.netcore2k.net/interrupt/int-16-1), [reloj para la semilla](https://helppc.netcore2k.net/interrupt/int-1a-0) y [modo y página de video](https://helppc.netcore2k.net/interrupt/int-10-f). Estas referencias no sustituyen los resultados de la ejecución en DOSBox.
