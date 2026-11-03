# Integración de los dulces

**Actualización:** ya se añadieron selección animada, confitero, resultados temáticos, ayuda e historial con sprites. Véase [AVANCE_GRAFICO.md](AVANCE_GRAFICO.md). La descripción de cuadros estáticos que sigue corresponde a la primera integración; el integrador actual genera dos cuadros diferentes por ficha y `sprites/hoja_animaciones.png`.

Actualización del 2 de noviembre de 2026, hora local. Fuente recibida: `sprites/sprites_dulces_16x16.zip`, carpeta interna `png_16x16`. Este documento describe la sustitución de las fichas provisionales y complementa la guía de assets del primer avance.

## Recursos recibidos y selección

El paquete contiene doce PNG RGBA de exactamente 16×16 píxeles. Su canal alfa usa únicamente 0 y 255: los huecos son transparentes y los glaseados claros son opacos. Los archivos se conservaron sin redimensionar ni cambiar sus bytes; los hashes están registrados en `sprites/dulces.json`.

Se integraron los primeros ocho en el orden del ZIP. Esto mantiene los seis tipos de Fácil/Normal y los ocho de Difícil que exige la configuración actual. Los otros cuatro quedan convertidos como alternativas; recibir doce imágenes no cambia automáticamente las reglas del nivel.

| Tecla | Identificador interno | Dulce |
| --- | ---: | --- |
| 1 | 0 | Bollo glaseado |
| 2 | 1 | Cupcake de crema |
| 3 | 2 | Waffle |
| 4 | 3 | Dona glaseada |
| 5 | 4 | Pretzel |
| 6 | 5 | Tarta de frutos rojos |
| 7 | 6 | Rebanada de pastel |
| 8 | 7 | Muffin de chocolate |
| Reserva | — | Pudín de caramelo |
| Reserva | — | Rosquilla de crema |
| Reserva | — | Dulce redondo |
| Reserva | — | Rollo de canela |

El título de trabajo es `CLAVE DULCE`. La evaluación sigue utilizando identificadores numéricos, por lo que los nuevos dibujos no cambian el algoritmo de toros y vacas ni las pruebas obligatorias.

## Conversión y colores

La paleta inicial de 16 colores era suficiente para los símbolos de prueba, pero no para conservar los tonos de los postres. El integrador analiza los doce PNG conjuntamente y obtiene hasta 240 colores adicionales. Los ajusta a RGB DAC de seis bits por componente y conserva intactas las primeras 16 entradas de la interfaz. La conversión actual produce una paleta compartida de **256 entradas**, dentro de la capacidad de VGA 13h.

Se asigna a cada píxel opaco el índice de la paleta compartida más cercano a su RGB. El índice 0 se reserva para alfa transparente; un color oscuro opaco nunca se elimina por parecer negro. La conversión no usa dithering ni cambia las dimensiones. El informe incluye el error RGB de cada sprite para poder revisar la pérdida de color.

`CargarPaleta` ahora calcula cuántos bytes hay entre `paleta` y `paletaFin`. Ya no carga solamente 48 bytes: recorre toda la tabla generada y la transmite por los puertos VGA. Así, cambiar el número de colores no requiere mantener un contador independiente en el ASM.

## Archivos y reconstrucción

| Ruta | Función |
| --- | --- |
| `sprites/sprites_dulces_16x16.zip` | Paquete recibido, conservado. |
| `sprites/png_16x16` | Copias verificadas de los doce PNG fuente. |
| `sprites/convertidos` | Doce tablas INC y doce matrices TXT para revisar o reutilizar. |
| `sprites/hoja_dulces_vga.png` | Hoja de los doce dulces después de la conversión. |
| `sprites/paleta.json` | Paleta compartida del juego. |
| `sprites/dulces.json` | Correspondencia, hashes, cantidad de colores y métricas. |
| `src/palette.inc` | Tabla DAC incluida en el ejecutable. |
| `src/sprites.inc` | Ocho fichas activas, mascota y resultados. |
| `herramientas/integrar_dulces.py` | Conversión e integración reproducibles. |

Desde la raíz, con un Python que tenga Pillow:

```powershell
python herramientas\integrar_dulces.py
.\build.ps1 -Test
.\run.ps1
```

También puede proporcionarse al integrador la ruta de la carpeta PNG o del ZIP. En este equipo se puede utilizar el intérprete alternativo indicado en el README:

```powershell
$pythonProyecto = Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
& $pythonProyecto herramientas\integrar_dulces.py
```

`generar_base.py` incorpora una protección para que no reemplace accidentalmente los dulces por los antiguos símbolos. Para regenerar estos recursos se usa el integrador de dulces.

El juego **utiliza las tablas INC enlazadas en el EXE**. Los TXT se entregan para inspección y para el posible lector externo de una fase posterior; no se leen durante la partida. Los nombres largos de los doce archivos de revisión no afectan a DOSBox, porque el código de ejecución utiliza `src/sprites.inc` y `src/palette.inc`, con nombres compatibles con 8.3.

## Cuadros y memoria

Cada PNG recibido tiene un solo cuadro. Para conservar el contrato de direccionamiento existente, el cuadro A y el cuadro B de cada ficha contienen actualmente los mismos 256 bytes. Esto mantiene correcto el desplazamiento `tipo*512 + cuadro*256`, pero **todavía no representa una animación del dulce**.

Las ocho fichas ocupan 4.096 bytes. La mascota y los dos resultados provisionales suman 1.536 bytes, de modo que las tablas de sprites ocupan 5.632 bytes en total. El framebuffer continúa en su segmento separado de 64.000 bytes.

La mascota y los resultados conservan los marcadores animados del primer avance. La siguiente integración requiere un segundo cuadro distinto para las fichas y los diseños temáticos de mascota, victoria y derrota. El historial numérico compacto también sigue pendiente del diseño final acordado para los doce intentos de Fácil.

## Verificaciones realizadas

- Los doce PNG extraídos coinciden byte por byte con sus entradas del ZIP.
- Todas las matrices contienen 256 índices, respetan el orden por filas y conservan exactamente la máscara transparente.
- Los ocho pares de cuadros se encuentran en el orden y con los offsets que utiliza el ASM.
- Las primeras 16 entradas de la paleta coinciden con las del primer avance.
- Se revisó una captura real de Difícil con el catálogo de ocho dulces y una propuesta de cinco posiciones.
- La construcción y el conjunto actual del ASM completaron **12.081 comprobaciones con cero fallos**, incluidas las 768 componentes de la paleta leídas desde el DAC de VGA.

La prueba del DAC utiliza 3C7h para seleccionar el índice de lectura y 3C9h para recuperar sus componentes RGB. La referencia técnica consultada es [FreeVGA: Color Registers](https://www.scs.stanford.edu/10wi-cs140/pintos/specs/freevga/vga/colorreg.htm). La revisión por capturas comprueba el dibujo; la fluidez percibida y las animaciones definitivas deben revisarse en la sesión interactiva al incorporar sus cuadros.
