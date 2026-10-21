# Proyecto II — Primera versión ejecutable

Avance del 20 de octubre de 2026 UTC, basado en `../MEMORIA_PROYECTO_II.md`. Se implementó un Mastermind DOS de 16 bits con TASM/TLINK, interfaz VGA y recursos provisionales. Esta versión permite jugar; todavía requiere la temática, los assets y la revisión de los requisitos gráficos finales.

## Iniciar desde PowerShell

Abre una terminal en la raíz `Proyecto_II_Arqui` y ejecuta:

```powershell
.\build.ps1 -Test
.\run.ps1
```

El primer comando ensambla **siete módulos**, los enlaza y ejecuta las pruebas del propio ASM dentro de DOSBox. Produce `bin/JUEGO.EXE`, `bin/JUEGO.MAP`, `bin/BUILD.LOG` y `bin/TESTS.TXT`. El segundo abre el juego. No abras `JUEGO.EXE` directamente en Windows: es un ejecutable DOS.

Las rutas predeterminadas son `C:\TASM` y `C:\Program Files (x86)\DOSBox-0.74-3\DOSBox.exe`. Se pueden cambiar con `-Tasm` y `-Dosbox`. Los scripts calculan la ruta del proyecto desde su propia ubicación y generan la configuración en `tmp`; no necesitas introducir manualmente la ruta larga con espacios.

Para depurar:

```powershell
.\run.ps1 -Debug
```

Se incluyeron símbolos mediante `TASM /zi` y `TLINK /v`. En Turbo Debugger: F7 entra en una rutina; F8 pasa sobre la llamada; F9 continúa; Alt+X sale. Las fuentes preparadas para la construcción están en `tmp/dosbuild`.

## Construcción manual en DOSBox

Monta la raíz del proyecto como C: y TASM como T:. Desde `C:\SRC`:

```dos
t:\tasm /zi /m2 main.asm
t:\tasm /zi /m2 data.asm
t:\tasm /zi /m2 video.asm
t:\tasm /zi /m2 input.asm
t:\tasm /zi /m2 game.asm
t:\tasm /zi /m2 ui.asm
t:\tasm /zi /m2 tests.asm
t:\tlink /v main+data+video+input+game+ui+tests,\bin\juego.exe,\bin\juego.map
cd \bin
juego.exe
```

Para las pruebas, usa `juego.exe /T > TESTS.TXT` en un directorio de construcción. Este modo también genera capturas `*.RAW` de 64.000 bytes; no necesita assets externos. La automatización lo ejecuta en `tmp/dosbuild` para mantener los diagnósticos fuera de `bin`.

## Controles

| Pantalla | Teclas |
| --- | --- |
| Presentación | Cualquier tecla abre el menú. |
| Menú | Arriba/abajo seleccionan; ENTER abre; ESC sale. |
| Dificultad | Arriba/abajo cambian el nivel inmediatamente; ENTER o ESC vuelve al menú. |
| Partida o secreto manual | Izquierda/derecha cambia de posición; arriba/abajo cambia de ficha; 1..C asigna una ficha; BACKSPACE vacía; ENTER confirma; ESC vuelve al menú. |
| Victoria/derrota | ENTER inicia una partida aleatoria nueva; ESC vuelve al menú. |
| Instrucciones/créditos | ENTER o ESC vuelve al menú. |

La posición **no avanza automáticamente** al elegir una ficha. Los números 1..C son las teclas visibles; internamente se guardan valores 0..C−1. Un hueco usa FFh.

F2 en el menú abre la entrada manual del secreto. Para los casos del PDF: R=1, V=2, A=3, M=4, N=5, B=6. Ejemplo: `RRVA` se introduce como 1,1,2,3, moviéndose con derecha entre posiciones. ENTER oculta el código y abre la partida. Este acceso admite secretos repetidos incluso en Fácil, para permitir las pruebas obligatorias.

## Qué contiene el avance

Presentación con animación, menú, dificultades, instrucciones y créditos provisionales; tablero con todos los intentos visibles; edición y validación; evaluación con repetidos; secreto pseudoaleatorio; victoria, derrota, reinicio y retorno al menú. Se usan una paleta propia de 16 entradas, sprites de prueba con transparencia y un framebuffer separado para componer la imagen antes de copiarla a VGA.

Fácil conserva 12 intentos; Normal y Difícil conservan 10. El historial compacto muestra **identificadores numéricos** de fichas, con T y V para la retroalimentación. Los sprites de 16×16 se usan en el catálogo y en la propuesta. Este acomodo es provisional: no equivale a tener aprobada una modificación de la maqueta del docente.

Faltan los diseños definitivos, nombres de integrantes y personalización de la ayuda y resultados. La guía gráfica dentro del juego todavía debe completarse con los assets. No se implementó lectura de TXT durante la partida ni funcionalidades extra como sonido o puntajes.

## Documentación

| Archivo | Contenido |
| --- | --- |
| [PLAN_DESARROLLO.md](PLAN_DESARROLLO.md) | Fases, dependencias, criterios y pendientes. |
| [ARQUITECTURA_Y_LOGICA.md](ARQUITECTURA_Y_LOGICA.md) | Módulos ASM, datos, flujo, algoritmo, video y decisiones. |
| [ASSETS_Y_PALETA.md](ASSETS_Y_PALETA.md) | Reglas para crear los assets en el otro chat y convertirlos. |
| [PRUEBAS_Y_ESTADO.md](PRUEBAS_Y_ESTADO.md) | Evidencia reproducible y límites de la validación. |
| [BITACORA.md](BITACORA.md) | Registro de este avance y contribuciones pendientes. |

Toda la documentación nueva se mantiene aquí, en `docs`, según la ubicación solicitada. La entrega final deberá ajustar su estructura si el docente exige específicamente `/doc` y un README en la raíz.

## VS Code y Python

Se añadieron tareas para construir/verificar y ejecutar. `Ctrl+Shift+B` selecciona la construcción. NASM Code Lens se configura para MASM; la herramienta que produce el ejecutable sigue siendo TASM. Go Asm no interviene en el ensamblado. La selección de tareas en la interfaz de VS Code debe comprobarse en tu sesión.

**Python no es necesario para ejecutar ni reconstruir el juego con las tablas actuales.** Solo se usa al convertir o regenerar recursos. El Python de MSYS2 localizado en PATH fue bloqueado por el control de aplicaciones durante esta sesión. Se pudo usar este intérprete ya disponible, sin modificar la seguridad de Windows:

```powershell
$pythonProyecto = Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
& $pythonProyecto herramientas\generar_base.py
& $pythonProyecto -m unittest discover -s herramientas -p test_conversion.py
```

Si utilizas tu propia instalación de Python, puedes sustituir `& $pythonProyecto` por `python`. El conversor de PNG requiere Pillow; las dependencias están en `herramientas/requirements.txt`. `generar_base.py` usa únicamente la biblioteca estándar y **sobrescribe** `src/sprites.inc` y `src/palette.inc` con los recursos provisionales; deja de ejecutarlo cuando se integren los definitivos.
