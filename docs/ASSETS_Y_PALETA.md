# Assets: formato, conversión e integración

## Respuesta al flujo propuesto

**Sí es válido:** dibujar el asset, limitar sus colores a una paleta compartida, convertir cada píxel en un índice, guardar esos números y hacer que ASM los represente. El modo de video determina las posibilidades: este proyecto exige **VGA 13h, 320×200, 256 índices de color**. El lenguaje ensamblador por sí mismo no limita la imagen a 16 colores.

En este avance se programan 16 entradas de esos 256 índices. Todos los assets deben compartir su significado. Un píxel con valor 4 siempre toma la entrada 4 de la paleta; no puede significar rojo en una ficha y azul en otra salvo que se reprograme la paleta global, lo que cambiaría todos los píxeles que usen ese índice.

Hay tres números diferentes:

| Valor | Ejemplo | Significado |
| --- | --- | --- |
| Identificador lógico de ficha | 0 | Primer tipo de ficha, válido para el juego. |
| Índice de píxel | 4 | Elegir el color 4 de la paleta VGA. |
| Componentes del color | 58,17,20 | Cantidades R,G,B del DAC, cada una entre 0 y 63. |

Una ficha contiene muchos píxeles y puede usar varios colores. No se convierte la ficha completa en un único color ni se mezcla su identificador con los valores de la imagen.

## Qué formato se usa ahora

El camino implementado es:

```text
PNG original -> conversor Python -> tabla .inc -> TASM/TLINK -> bytes del EXE
                                                         -> DibujarSprite
```

El `.inc` contiene directivas `db` con los valores numéricos. TASM las convierte en bytes; el juego los recorre directamente. Python no se ejecuta en DOSBox ni durante la partida.

También se implementó la exportación `.txt` para inspección. Ejemplo didáctico de una matriz 2×2, no de una ficha final:

```text
VGA8 2 2
04 05
00 0F
```

Las filas se leen de izquierda a derecha, luego de arriba abajo. Los números son hexadecimales: `0F` significa índice 15. Cada byte corresponde a **un píxel**. El TXT y el INC contienen los mismos índices, con distinta representación.

**El juego actual no abre ni interpreta ese TXT.** Para hacerlo en una fase posterior se necesita abrirlo con INT 21h AH=3Dh, leer con 3Fh, interpretar la cabecera y los números, validar dimensiones/cantidad/rangos, guardar los bytes y cerrar con 3Eh en todas las rutas. También hay que gestionar archivos faltantes, lectura parcial y fin de archivo. Solo después se llama al mismo `DibujarSprite`.

Una alternativa a TXT en ejecución sería un archivo binario con ancho, alto e índices: ocuparía menos y evitaría interpretar números ASCII. En ambos casos se conserva la misma lógica gráfica. Para esta primera versión se eligió INC porque simplifica la distribución y permite comprobar el núcleo sin depender de archivos externos.

## Encargo para crear los assets en el otro chat

Prepara recursos **originales**, con una temática propia y formas diferentes, guardando los PNG fuente. El código actual acepta directamente:

| Recurso | Cantidad | Tamaño por cuadro | Orden previsto |
| --- | ---: | --- | --- |
| Fichas | 8 tipos × 2 cuadros | 16×16 píxeles | Ficha 1 A/B, ficha 2 A/B… ficha 8 A/B. |
| Mascota de presentación | 2 cuadros | 16×16 píxeles | A/B. |
| Victoria | 2 cuadros | 16×16 píxeles | A/B. |
| Derrota | 2 cuadros | 16×16 píxeles | A/B, diferentes de victoria. |

Total de esta propuesta: 22 imágenes de 16×16, 5.632 bytes de índices sin compresión. El requisito mínimo permite planificar otros tamaños; para usarlos habrá que cambiar las coordenadas y metadatos actuales. El tamaño 16×16 se eligió para permitir integrar los primeros diseños sin modificar el tablero lateral.

Cada cuadro debe tener el mismo lienzo y punto de referencia. Usa fondo transparente y bordes nítidos de pixel art; evita antialiasing o efectos que generen tonos intermedios involuntarios. Diseña las fichas para distinguirlas por su silueta, incluso sin color. Una hoja de sprites adicional ayuda a revisar los recursos y forma parte de la entrega final.

Los dos cuadros pueden cambiar pose, contorno o detalle. Una simple diferencia cromática en los marcadores actuales demuestra la alternancia de cuadros, pero las animaciones finales deben ser claras. La ayuda dentro del programa también necesita gráficos que expliquen el acierto exacto y el parcial.

## Paleta provisional compartida

La fuente editable es `sprites/paleta.json`; `src/palette.inc` contiene su tabla DAC. Estos son los valores actuales:

| Índice | Nombre | RGB DAC, 0..63 | RGB aproximado para dibujar, 0..255 |
| ---: | --- | --- | --- |
| 0 | Transparencia de sprite / negro | 0,0,0 | 0,0,0 |
| 1 | Fondo | 4,6,12 | 16,24,49 |
| 2 | Panel | 8,12,20 | 32,49,81 |
| 3 | Borde | 18,24,32 | 73,97,130 |
| 4 | Rojo | 58,17,20 | 235,69,81 |
| 5 | Verde | 17,48,30 | 69,194,121 |
| 6 | Azul | 18,32,60 | 73,130,243 |
| 7 | Texto suave | 42,47,54 | 170,190,219 |
| 8 | Morado | 44,23,58 | 178,93,235 |
| 9 | Naranja | 63,34,12 | 255,138,49 |
| 10 | Acierto exacto | 27,61,41 | 109,247,166 |
| 11 | Cian | 15,51,57 | 61,206,231 |
| 12 | Rosa | 60,28,44 | 243,113,178 |
| 13 | Derrota | 63,23,27 | 255,93,109 |
| 14 | Selección / parcial | 63,52,22 | 255,210,89 |
| 15 | Texto principal | 60,62,63 | 243,251,255 |

Se puede ajustar la paleta cuando definas la temática; habrá que regenerar la tabla y reconvertir **todos** los assets contra la nueva versión. El código actual carga 16 tripletas: aumentar su número exige actualizar también la carga y las herramientas, aunque el hardware admita 256.

El índice 0 es transparente por decisión del dibujante: ese píxel no se escribe. Por eso el conversor reserva el 0 para transparencia y busca para los píxeles opacos solo entre los índices 1..15. Si necesitas negro opaco en un asset, reserva negro en otra entrada de la paleta. No conviertas todos los píxeles negros a transparentes por su color; usa el canal alfa.

## Ejecutar el conversor

Con un Python que tenga Pillow:

```powershell
python -m pip install -r herramientas\requirements.txt
python herramientas\convertir_asset.py sprites\ficha1a.png src\f1a.inc --nombre f1a --txt sprites\f1a.txt
```

Si deseas cambiar el tamaño explícitamente:

```powershell
python herramientas\convertir_asset.py sprites\ficha1a.png src\f1a.inc --nombre f1a --ancho 16 --alto 16 --txt sprites\f1a.txt
```

En esta computadora se verificó el intérprete alternativo descrito en `README.md`; puede sustituirse `python` por `& $pythonProyecto`. No es necesario instalar dependencias si Pillow ya está disponible.

El conversor conserva el tamaño si no indicas dimensiones. Cuando redimensiona usa vecino más cercano. Los píxeles con alfa menor de 128 van a 0; los demás se asignan al color de paleta más cercano por distancia RGB, sin dithering. No admite semitransparencia real: el sprite resultante es opaco o transparente por píxel. Puedes ajustar el corte con `--umbral-alfa`.

Los índices de una imagen PNG ya indexada no se copian a ciegas: el conversor recupera sus colores y los mapea contra la paleta común. Así se evita que dos archivos asignen el mismo índice a colores diferentes.

## Integración en el ASM

Los nombres usados por DOSBox deben respetar 8.3. Por ejemplo: `F1A.INC`, `F1B.INC`, `MASCA.INC`, `GANAA.INC`. Las etiquetas internas deben ser distintas; `--nombre f1a` define el nombre de esa tabla.

La implementación actual espera dos cuadros contiguos por ficha. Para integrar los nuevos recursos se reemplaza el contenido provisional de `src/sprites.inc`, conservando los tres puntos de entrada:

```asm
sprites LABEL BYTE
INCLUDE f1a.inc
INCLUDE f1b.inc
; Fichas 2 a 8, cada una A/B, en ese orden.

mascota LABEL BYTE
INCLUDE masca.inc
INCLUDE mascb.inc

finale LABEL BYTE
INCLUDE ganaa.inc
INCLUDE ganab.inc
INCLUDE perda.inc
INCLUDE perdb.inc
```

El ejemplo abrevia la lista de fichas: en el archivo real deben estar todos los cuadros. Los INC se colocan en `src`, donde los copia `build.ps1`. Los PNG y TXT de revisión permanecen en `sprites`. No vuelvas a ejecutar `generar_base.py` después de integrar diseños definitivos: regeneraría los marcadores y sobrescribiría estas tablas.

Para cuadros de otros tamaños o cantidades se sustituirán los desplazamientos fijos por una tabla de punteros y dimensiones. Esa adaptación es parte de la integración futura; no basta con insertar datos de distinto tamaño conservando `tipo*512`.
