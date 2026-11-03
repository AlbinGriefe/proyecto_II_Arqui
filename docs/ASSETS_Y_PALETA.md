# Assets: formato, conversión e integración

**Actualización:** ya se añadieron selección animada, confitero, resultados temáticos, ayuda e historial con sprites. Véase [AVANCE_GRAFICO.md](AVANCE_GRAFICO.md). La descripción de cuadros estáticos que sigue corresponde a la primera integración; el integrador actual genera dos cuadros diferentes por ficha y `sprites/hoja_animaciones.png`.

## Estado actual

Ya están integrados los dulces recibidos en `sprites/sprites_dulces_16x16.zip`. Se validaron sus doce PNG de 16×16, se prepararon todos para VGA y se incorporaron los primeros ocho al catálogo y a la propuesta del juego. Fácil/Normal usan los seis primeros y Difícil los ocho. Los cuatro restantes quedan como alternativas.

La selección, las decisiones y las pruebas se explican en [INTEGRACION_DULCES.md](INTEGRACION_DULCES.md). La paleta actual tiene **256 colores compartidos**, con las 16 entradas originales de interfaz y 240 entradas para dulces. Los PNG fuente están en `sprites/png_16x16`; el ZIP original se conserva.

## Flujo de datos

El flujo propuesto es válido:

```text
PNG -> paleta compartida -> índices numéricos -> tabla INC -> TASM/TLINK -> EXE
                                             -> matriz TXT para inspección
```

Cada byte representa un píxel. La ficha completa tiene un identificador lógico diferente del índice de color de cada uno de sus píxeles:

| Valor | Ejemplo | Significado |
| --- | --- | --- |
| Identificador de ficha | 0 | Bollo glaseado; selección lógica del juego. |
| Índice de píxel | 16..255 | Una entrada de color de la paleta compartida. Puede usar también 1..15. |
| RGB DAC | 63,34,12 | Componentes del color de hardware, cada uno entre 0 y 63. |

Los datos se ordenan por filas: izquierda a derecha y después arriba abajo. El índice 0 indica transparencia: `DibujarSprite` conserva el píxel previo en ese punto. El conversor usa el canal alfa, no el color blanco o negro, para decidirla. Los glaseados blancos no desaparecen.

El juego actual utiliza los bytes incluidos en el EXE. **No abre ni interpreta los TXT durante la partida.** Para añadir esa opción se necesita un lector con INT 21h: abrir con 3Dh, leer con 3Fh, interpretar y validar cabecera/números/dimensiones/cantidad y cerrar con 3Eh en todas las rutas. El formato binario sería otra opción más compacta. Esa carga sigue pendiente.

## Regenerar el paquete de dulces

Con Python y Pillow:

```powershell
python herramientas\integrar_dulces.py
```

El argumento opcional permite elegir un ZIP o un directorio con los doce nombres conocidos:

```powershell
python herramientas\integrar_dulces.py sprites\png_16x16
```

La herramienta conserva los 16 colores de interfaz, construye una paleta común con hasta 240 colores adicionales y convierte los doce originales contra ella. Se usa MAXCOVERAGE sobre componentes DAC, sin dithering. Los píxeles opacos se asignan a la entrada más cercana entre 1 y 255; el 0 queda reservado. El error de color por archivo se registra en `sprites/dulces.json`.

| Salida | Uso |
| --- | --- |
| `sprites/png_16x16/*.png` | Copias sin modificar de las fuentes del paquete. |
| `sprites/convertidos/*.inc` | Una tabla de 256 bytes por dulce, para inspección o reutilización. |
| `sprites/convertidos/*.txt` | Una matriz hexadecimal por dulce con cabecera `VGA8 16 16`. |
| `sprites/hoja_dulces_vga.png` | Hoja convertida de 64×48, cuatro columnas y tres filas. |
| `sprites/dulces.json` | IDs activos, hashes de fuentes y mediciones de conversión. |
| `sprites/paleta.json` | Fuente editable de la paleta global. |
| `src/palette.inc` | Tripletas VGA y etiqueta `paletaFin`. |
| `src/sprites.inc` | Fichas y marcadores que se enlazan en el ejecutable. |

Después ejecuta `build.ps1 -Test` para actualizar el EXE. La reconstrucción normal no ejecuta el conversor: usa las tablas ya generadas. El juego no necesita Python, PNG ni ZIP durante la partida.

## Convertir una imagen individual

El conversor original sigue disponible:

```powershell
python herramientas\convertir_asset.py sprites\png_16x16\01_bollo_glaseado.png tmp\BOLLO.INC --nombre bollo --txt tmp\bollo.txt
```

Conserva el tamaño si no se indican dimensiones. Para redimensionar explícitamente:

```powershell
python herramientas\convertir_asset.py entrada.png tmp\FICHA.INC --nombre ficha --ancho 16 --alto 16
```

Usa vecino más cercano. Por defecto alfa menor de 128 se vuelve transparente; el resto es opaco. Se puede cambiar con `--umbral-alfa`. Un PNG indexado se convierte primero a sus colores reales para evitar confundir paletas diferentes.

Ejemplo de TXT didáctico, de 2×2:

```text
VGA8 2 2
04 05
00 0F
```

Los valores son hexadecimales. INC y TXT representan los mismos índices. El conversor individual utiliza la paleta existente y no añade colores ni inserta por sí solo su tabla en el juego.

## Contrato con el ASM

`src/sprites.inc` mantiene tres etiquetas:

| Etiqueta | Contenido | Bytes |
| --- | --- | ---: |
| `sprites` | Ocho fichas, dos cuadros de 16×16 por tipo. | 4.096 |
| `mascota` | Dos cuadros provisionales de presentación. | 512 |
| `finale` | Victoria A/B seguida de derrota A/B, provisionales. | 1.024 |

El desplazamiento de ficha es `tipo*512 + cuadro*256`. **Los dulces recibidos tienen un solo cuadro: A y B son copias idénticas.** Esto respeta las direcciones existentes, pero no constituye una animación final. Se necesitan cuadros propios con cambio visible de pose, contorno o detalle para completar ese requisito.

Las tablas de paleta delimitan sus datos con `paleta` y `paletaFin`. La carga calcula su tamaño en lugar de asumir 16 colores. Todos los recursos comparten esa misma paleta; cambiar el significado de un índice afecta a todos los píxeles que lo usan. Al modificarla hay que reconvertir todos los assets.

Los nombres consumidos por TASM/DOSBox, `sprites.inc` y `palette.inc`, respetan 8.3. Los PNG y exportaciones descriptivas permanecen fuera del directorio de ensamblado. `build.ps1` copia las fuentes ASM e INC de `src` al directorio de construcción.

`generar_base.py` genera los marcadores del avance original y ahora protege las fichas integradas: si detecta la integración, termina sin sobrescribirla. Para actualizar los dulces utiliza `integrar_dulces.py`.

## Recursos todavía pendientes

- Dos cuadros distintos por ficha, con el mismo lienzo y punto de referencia.
- Mascota temática y animaciones temáticas diferentes para victoria y derrota.
- Ayuda con ejemplos gráficos de acierto exacto y parcial.
- Resolución del historial: sigue mostrando todos los intentos con números para conservar las doce filas de Fácil.

Otros tamaños o cantidades de cuadros requieren ajustar metadatos y coordenadas; no basta con cambiar los bytes conservando los desplazamientos actuales. La documentación del juego y los requisitos del enunciado siguen siendo la referencia para esas fases.
