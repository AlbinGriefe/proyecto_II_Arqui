# Estado del juego tras completar la interfaz

**Apariencia aprobada:** Chocolate oscuro, opción 1 elegida por el usuario. Fondo, paneles y bordes usan tonos café; los textos secundarios y principales usan tonos crema. La selección se aplicó a `sprites/paleta.json` y a la tabla VGA de `src/palette.inc`; los PNG fuente y las tablas de píxeles de los dulces conservan sus datos. El integrador mantiene las 16 entradas de interfaz de la paleta activa al regenerar recursos.

Se completó la parte funcional y gráfica de este avance. El informe de entrega, la bitácora final y la preparación de la defensa quedan para el cierre, por indicación del usuario.

## Cambios implementados y su motivo

- **Selección animada:** el cuadro A conserva el dulce recibido; el B comprime su silueta de 16 a 14 filas dentro del mismo lienzo. Solo se anima la casilla activa. El catálogo, el historial y el secreto revelado mantienen sus cuadros originales para facilitar la comparación.
- **Mascota y resultados:** tablas propias de pixel art para un confitero que mueve los brazos, un cupcake ganador con destellos y un pastel quemado con lágrimas. Cada elemento tiene dos cuadros distintos. El reloj BIOS conserva el intervalo de tres tics; el dibujo restaura el fondo antes de cada cuadro.
- **Historial con dulces:** Fácil muestra dos columnas de seis propuestas. Normal y Difícil muestran diez filas de 16 píxeles. Todos los intentos y ambos conteos permanecen visibles, sin desplazamiento ni reducción de los sprites. Una fuente propia de 3×5 permite colocar números legibles junto a las fichas.
- **Ayuda gráfica:** ejemplo de secreto 1,2,3,4 y propuesta 1,3,2,4, con dos toros y dos vacas. El ejemplo usa datos privados de interfaz y no revela el secreto de la partida.
- **Pantallas:** el selector de dificultad muestra casillas, tipos e intentos. El editor manual mantiene sus instrucciones dentro del panel izquierdo. Al terminar, el secreto se revela con sprites y el resultado se muestra en la barra inferior, sin tapar las cabeceras del historial.

## Verificación realizada

`build.ps1 -Test` ensambla y enlaza sin errores ni advertencias. El ejecutable real supera **12.153 comprobaciones con cero fallos**. Las **siete pruebas Python** también pasan, sin omisiones tras la construcción.

Se verifican entrada por la cola BIOS con INT 16h, números, flechas, borrado, intento incompleto, dificultad, ayuda, regreso al menú y salida. El temporizador se comprueba esperando tres tics reales. Las pruebas existentes conservan los cuatro casos obligatorios del evaluador, victoria, derrota, reinicio y restauración del modo de video.

Las capturas VGA comprueban el catálogo, la selección, los doce intentos de Fácil, las diez filas de Normal/Difícil, el secreto revelado y los dos cuadros de las tres animaciones temáticas. Los tests comparan píxeles y comprueban que al cambiar un cuadro no se altere el exterior de su región. Se revisaron visualmente todas las pantallas de juego capturadas, su legibilidad, los bordes y la separación de los elementos.

**Límite de la revisión:** el acceso al escritorio de Windows está restringido en esta sesión. Esta revisión visual de capturas y las pruebas de teclado BIOS no equivalen a jugar físicamente mediante la ventana de DOSBox. La prueba interactiva del usuario sigue siendo necesaria para confirmar sensación de fluidez, teclado del equipo y cambios rápidos.

## Ejecutar y revisar

```powershell
.\run.ps1
```

F2 en el menú permite introducir un secreto conocido y probar resultados. Las flechas izquierda/derecha cambian de casilla; arriba/abajo o 1..C eligen el dulce; BACKSPACE borra; ENTER confirma y ESC vuelve al menú. Desde victoria/derrota, ENTER inicia otra partida.

Para reproducir las imágenes de diagnóstico después de construir:

```powershell
python herramientas\revisar_vga.py
```

Se generan 16 capturas ampliadas y cuatro GIF de comparación en `tmp/revision`. Los GIF representan los cuadros con una duración de 165 ms; la prueba del reloj verifica por separado el intervalo del programa.

## Decisiones todavía externas

El acomodo de dos columnas de Fácil conserva los doce intentos y las zonas exigidas, pero adapta la maqueta del PDF; debe validarse con el docente. Se conserva la lectura de RF-05 que prohíbe repetidos en el secreto de Fácil y permite propuestas repetidas. El modo manual admite repetidos para las pruebas obligatorias.

Los créditos y la presentación incluyen Arwee Granados y Albin Greife, según los nombres confirmados por el usuario. Se definen en `txtTeam`, dentro de `src/data.asm`. La carga de TXT durante la partida y los extras de sonido, cronómetro y puntajes no forman parte del cierre obligatorio implementado: el EXE utiliza sus tablas INC.
