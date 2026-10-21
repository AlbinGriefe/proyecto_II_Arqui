# Memoria del Proyecto II de Arquitectura de Computadores

Referencia de desarrollo para un Mastermind en ensamblador x86 de 16 bits, ejecutado en DOSBox y construido con TASM y TLINK. Revisión realizada el 20 de octubre de 2026 UTC. El proyecto pertenece a EIF205, II Ciclo 2026, Universidad Nacional, Sede Regional Brunca, Campus Pérez Zeledón y Campus Coto; profesores Daniel Granados M. y Gabriel Núñez M. Su valor es **12 % de la nota del curso** y se realiza en pareja.

Esta memoria conserva los requisitos del enunciado, los criterios de evaluación, el entorno disponible y una propuesta de desarrollo. **Los requisitos del PDF y las propuestas de implementación se distinguen en sus secciones.** Por indicación del usuario, se excluye la normativa específica sobre uso de IA. Se mantienen las exigencias de originalidad, comprensión del código y defensa individual.

## 1. Fuentes y estado del proyecto

La fuente normativa es `proyecto_II.pdf`, de 11 páginas, ubicado en la raíz del proyecto. SHA-256 de la copia local: `9F356CDB6C75816EB9F93F88C5E154C097713C95595476E2BF5614BAF386C2E7`. Las dos copias consultadas del enunciado contienen el mismo texto. Se revisaron visualmente las páginas 7 y 8 para comprobar las maquetas y la distribución de pantalla.

Material complementario: [EduCore de Arquitectura](http://23.22.58.242/arquitectura/). Se accedió por HTTP con el navegador y se extrajo el texto de las 21 lecciones de los temas 4, 5 y EjerciciosASM. La sección 13 conserva enlaces, conceptos útiles y observaciones de los simuladores. Se incorporó también [HelpPC 2.10](https://helppc.netcore2k.net/topics), aportado posteriormente por el usuario, con referencias técnicas consultadas y resumidas en la sección 16. Ninguno de estos recursos cambia las reglas del PDF.

Directorio de trabajo:

```text
C:\Users\jcaba\OneDrive\Desktop\Stuff\U\6to cuatri\Arqui IItry\Proyecto_II_Arqui
```

En la revisión inicial, este directorio contenía el PDF; no se encontró una implementación del juego ni un repositorio Git. Esta memoria prepara el desarrollo: no representa un juego ya ensamblado, ejecutado o aprobado. No se modificaron los scripts externos ni la configuración de VS Code.

### Localización de los requisitos en el PDF

| Páginas | Contenido |
| --- | --- |
| 1 y 2 | Presentación, objetivos, dificultades y mecánica. |
| 3 | Definición de toros y vacas, cuatro pruebas obligatorias y entrada manual del secreto. |
| 4 | RF-01 a RF-14 y funcionalidades opcionales. |
| 5 y 6 | RG-01 a RG-08, formato de sprites, originalidad y RT-01 a RT-08. |
| 7 y 8 | Restricciones, maquetas, coordenadas y zonas obligatorias. |
| 9 y 10 | Entregables, rúbrica, penalizaciones y demostración práctica. |
| 11 | Condiciones de la defensa escrita individual. |

## 2. Reglas del juego

El programa genera un código secreto de N posiciones con C tipos de ficha. Cada tipo se representa mediante un sprite original; el identificador lógico de la ficha y los índices de píxel de la paleta VGA son conceptos diferentes. El jugador construye una propuesta y recibe dos conteos: **toro = ficha correcta en la posición correcta; vaca = ficha correcta en otra posición**.

### Dificultades obligatorias

| Nivel | Posiciones N | Tipos de ficha C | Repetición | Intentos |
| --- | ---: | ---: | --- | ---: |
| Fácil | 4 | 6 | No permitida | 12 |
| Normal | 4 | 6 | Permitida | 10 |
| Difícil | 5 | 8 | Permitida | 10 |

El criterio RF-05 exige explícitamente que **el secreto de Fácil no tenga repeticiones**. La tabla general no aclara de forma separada cómo se valida una propuesta repetida en Fácil; véase el pendiente de la sección 15.

### Secuencia de una jugada

1. Seleccionar una ficha para cada una de las N posiciones.
2. Confirmar con ENTER. Si falta alguna posición, mostrar un aviso y conservar el turno.
3. Evaluar el intento completo, obteniendo toros y vacas.
4. Guardar el intento y ambos conteos en el historial, que permanece visible simultáneamente.
5. Consumir exactamente un intento válido. Si los toros son N, declarar victoria. Si no hubo victoria y se agotaron los intentos, declarar derrota y revelar el secreto.

**Cada ficha del secreto puede utilizarse como máximo una vez en la evaluación.** Las coincidencias exactas tienen prioridad. Una ficha contada como toro no puede contarse otra vez como vaca, y una repetición sobrante en la propuesta no genera coincidencias adicionales.

### Controles obligatorios

| Tecla | Acción |
| --- | --- |
| Izquierda / derecha | Cambiar la posición activa. |
| Arriba / abajo o números 1..C | Cambiar la ficha de la posición activa. El enunciado ofrece estas alternativas; implementar ambas es una propuesta útil. |
| ENTER | Evaluar únicamente una propuesta completa y válida. |
| BACKSPACE | Vaciar la posición activa. |

Las teclas inválidas deben ignorarse sin bloquear el programa. Las maquetas muestran ESC para volver al menú y controles de reinicio; sus asignaciones concretas se deben explicar en pantalla y en el README. No reemplazan los controles expresamente exigidos.

## 3. Requisitos funcionales obligatorios

| ID | Requisito y aceptación |
| --- | --- |
| RF-01 | Presentación con nombre del juego, temática e integrantes; al menos un sprite animado; esperar una tecla para continuar. |
| RF-02 | Menú por teclado con Jugar, Nivel de dificultad, Instrucciones, Créditos y Salir. Resaltar la opción activa. |
| RF-03 | Instrucciones dentro del programa con reglas y significado de ambos aciertos, apoyadas por gráficos. |
| RF-04 | Secreto pseudoaleatorio con semilla obtenida mediante INT 1Ah, AH=00h. Dos partidas consecutivas no deben producir el mismo secreto. |
| RF-05 | Respetar la repetición según el nivel; el secreto de Fácil debe contener fichas diferentes. |
| RF-06 | Edición por posición mediante teclado con los controles de la sección 2. |
| RF-07 | Rechazar el intento incompleto, mostrar aviso y no consumir un turno. |
| RF-08 | Evaluación correcta, incluidos los cuatro casos de la sección 6. |
| RF-09 | Mantener visibles simultáneamente todos los intentos evaluados y su retroalimentación. |
| RF-10 | Mostrar durante la partida el intento actual, los intentos restantes y la dificultad. |
| RF-11 | Victoria con N toros; derrota al agotarse los intentos; revelar el secreto al perder. |
| RF-12 | Pantalla final con animaciones visiblemente diferentes para victoria y derrota. |
| RF-13 | Desde el final, permitir otra partida o volver al menú sin cerrar el programa. |
| RF-14 | Guardar el modo original mediante INT 10h, AH=0Fh antes de cambiarlo; restaurarlo al terminar y salir con INT 21h, AH=4Ch. |

La entrada **manual del código secreto para las pruebas del docente es obligatoria**, aunque no tenga un RF independiente. Debe existir una ruta de acceso documentada y permitir ejecutar los cuatro casos, incluidos los secretos repetidos. El mecanismo de prueba no debe quedar bloqueado por las restricciones del nivel Fácil.

## 4. Gráficos y personalización obligatorios

| ID | Requisito y aceptación |
| --- | --- |
| RG-01 | VGA modo 13h: 320 × 200, 256 colores. Activar mediante INT 10h, AH=00h, AL=13h y dibujar directamente en A000h. Prohibido INT 10h, AH=0Ch para dibujo masivo. |
| RG-02 | Un procedimiento genérico `DibujarSprite` que reciba puntero a datos, ancho, alto y coordenadas. Reutilizarlo para todas las figuras. |
| RG-03 | El índice 0 de los datos de un sprite es transparente: ese píxel no se escribe en destino. |
| RG-04 | Al menos seis fichas originales; como Difícil es obligatorio, preparar **ocho**. Cada sprite mide como mínimo 16 × 16 y se distingue por la forma, además del color. |
| RG-05 | Tres elementos animados con al menos dos cuadros: mascota de presentación, ficha seleccionada y elemento de fin de partida. |
| RG-06 | Temporización independiente de la CPU mediante tics BIOS en 0040h:006Ch o retrazo vertical en 3DAh, bit 3. |
| RG-07 | Redefinir al menos 16 entradas de la paleta mediante OUT a 3C8h y 3C9h. Entregar la tabla utilizada. |
| RG-08 | Evitar parpadeo: actualizar solo regiones modificadas o usar un búfer de 64 000 bytes copiado con REP MOVSW a A000h. |

La combinación RF-12 y RG-05 exige prever resultados animados distintos al ganar y perder. Plan de recursos propuesto: mascota de dos cuadros, estados animados de selección y dos secuencias finales diferentes, cada una de al menos dos cuadros.

### Sprites y temática

Cada sprite es una tabla de bytes por filas, de izquierda a derecha y de arriba abajo. Un sprite de 16 × 16 ocupa 256 bytes; dos cuadros de ese tamaño ocupan 512 bytes. Una ficha puede usar varios colores VGA; no tiene que ser de un solo tono.

No se aceptan cuadrados o círculos de color plano como fichas. Tampoco sprites de videojuegos comerciales, personajes protegidos o imágenes descargadas de Internet. La pareja debe diseñar sus recursos y elegir una temática distinta a la referencia de Toros y Vacas y a la de las otras parejas. Debe quedar clara la equivalencia entre ficha, acierto exacto, acierto parcial y mascota.

Python o JavaScript pueden convertir los diseños originales en tablas `.inc`; esa herramienta auxiliar debe adjuntarse en `/herramientas`. La conversión ocurre durante el diseño. La lógica, el dibujo y la animación del juego entregado se ejecutan en ensamblador.

### Coordenadas y zonas de pantalla

```text
offset = y * 320 + x
0 <= x <= 319
0 <= y <= 199
0 <= offset <= 63999 = F9FFh
```

El píxel (30, 24) corresponde al offset 7710. Con ES=A000h se accede al destino mediante ES:DI. El área visible ocupa A000h:0000h hasta A000h:F9FFh.

| Zona exigida | Origen | Tamaño | Contenido |
| --- | --- | --- | --- |
| A. Encabezado | (0, 0) | 320 × 20 | Título y dificultad activa. |
| B. Tablero | (4, 22) | 196 × 168 | Historial. La tabla del PDF especifica 10 filas de 16 píxeles. |
| C. Panel lateral | (204, 22) | 112 × 168 | Catálogo de fichas, intento en construcción, contadores e imagen animada. |
| D. Estado | (0, 190) | 320 × 10 | Ayuda de teclas y mensajes de validación. |

El estilo es libre; la organización de estas zonas es obligatoria. El tiempo mostrado en la imagen del PDF pertenece a una funcionalidad opcional, no convierte el cronómetro en requisito básico.

**Conflicto por resolver:** doce filas de 16 píxeles requieren 192 píxeles y no caben en los 168 disponibles. Reducir Fácil a diez intentos viola su tabla; ocultar filas mediante desplazamiento o páginas viola la visibilidad simultánea de RF-09. Debe acordarse con el docente una adaptación, por ejemplo un acomodo de dos columnas para las doce propuestas, si lo autoriza. No registrar esa adaptación como aprobada sin confirmación.

### Propuesta de dibujo y animación

Comenzar con redibujo de las regiones que cambian: selección anterior, selección nueva, mensaje y nueva fila del historial. Antes de pintar otro cuadro transparente, restaurar el fondo de la región anterior; omitir los ceros del nuevo cuadro no borra sus píxeles anteriores.

El procedimiento genérico debe avanzar al siguiente renglón destino con el ancho de pantalla, no con el ancho del sprite. Comprobar que x+ancho <= 320 e y+alto <= 200, o implementar recorte. Evitar que un sprite se continúe en la fila siguiente por un offset incorrecto.

Si se adopta un búfer completo, requiere 64 000 bytes; `REP MOVSW` copia **32 000 palabras**, con DF limpio mediante CLD, fuente DS:SI y destino ES:DI. El búfer debe ubicarse en un segmento cuya capacidad se haya calculado: 64 000 bytes dejan solo 1 536 bytes de un segmento de 64 KiB. No reservar además todos los sprites y variables en ese mismo espacio sin revisar los límites.

La paleta usa índices de píxel de 0 a 255. En VGA clásico, sus componentes RGB se programan en el rango 0..63. Reservar el índice 0 para transparencia del sprite no impide que el fondo de pantalla utilice un color oscuro. Guardar las entradas elegidas en una tabla central y documentar índice, nombre, RGB y uso.

## 5. Requisitos técnicos y restricciones

| ID | Requisito y aceptación |
| --- | --- |
| RT-01 | Al menos 12 procedimientos con responsabilidad única; ninguno supera 200 líneas. |
| RT-02 | Cada PROC documenta entradas, salidas y registros que destruye. Conviene indicar también registros preservados, segmentos y uso de FLAGS. |
| RT-03 | Preservar con PUSH/POP los registros modificados que no constituyan salidas; mantener balanceada la pila. |
| RT-04 | Definir al menos una macro con MACRO/ENDM y utilizarla más de una vez. |
| RT-05 | Secreto, propuesta e historial en arreglos, recorridos mediante direccionamiento indexado o base más índice. |
| RT-06 | Comentar intención y decisiones; evitar comentarios que solo repiten el mnemónico. |
| RT-07 | Ensamblar y enlazar sin errores ni advertencias usando los comandos documentados en README. |
| RT-08 | Sin código C incrustado ni bibliotecas gráficas externas. Las macros o bibliotecas del curso requieren autorización escrita del docente. |

La lógica y el dibujo deben estar en ensamblador. No entregar código descargado de proyectos Mastermind. El programa debe funcionar en DOSBox con la configuración estándar del curso, todavía pendiente de obtener. Las rutinas propias deben poder explicarse y modificarse durante la defensa.

**Decisión técnica propuesta:** sintaxis MASM compatible con TASM, ejecutable DOS de 16 bits `.EXE` y modelo SMALL mientras las tablas y recursos quepan. El PDF permite `.EXE` o `.COM`, pero no exige NASM ni exige enlazar varios `.OBJ`. No mezclar directivas NASM (`section`, `%macro`, `BITS 16`) con `.MODEL`, PROC/ENDP y MACRO/ENDM de TASM.

Separar rutinas en archivos `.inc` incluidos desde una unidad principal permite modularizar sin incorporar inicialmente un enlace de varios objetos. Los nombres usados dentro de DOS deben respetar 8.3; los nombres simbólicos de procedimientos no están sujetos al límite de ocho caracteres de los archivos.

## 6. Algoritmo de toros y vacas y pruebas obligatorias

### Cuatro casos del PDF

| Secreto | Propuesta | Toros | Vacas |
| --- | --- | ---: | ---: |
| RVAM | RAVM | 2 | 2 |
| RRVA | RVRR | 1 | 2 |
| RVAM | NBNB | 0 | 0 |
| AAAA | AARR | 2 | 0 |

Los cuatro se ejecutan durante la revisión. **Fallar el segundo o el cuarto elimina los 15 puntos completos del criterio de corrección del algoritmo**, no solo una fracción por ese caso. Las letras son etiquetas de tipos de ficha; debe documentarse su equivalencia con los sprites de la temática propia.

### Propuesta de solución por frecuencias

Usar dos tablas de C contadores para las posiciones que no sean toros. Esta alternativa se relaciona con el ejercicio 7.5 de EduCore sobre histogramas. Su costo es O(N+C) y no modifica el secreto ni la propuesta.

```text
toros = 0
vacas = 0
vaciar frecuenciaSecreto[0..C-1]
vaciar frecuenciaIntento[0..C-1]

para i = 0..N-1:
    si secreto[i] == intento[i]:
        toros = toros + 1
    si no:
        frecuenciaSecreto[secreto[i]] += 1
        frecuenciaIntento[intento[i]] += 1

para tipo = 0..C-1:
    vacas += minimo(frecuenciaSecreto[tipo], frecuenciaIntento[tipo])

devolver toros, vacas
```

El mínimo limita las coincidencias a las fichas realmente disponibles. Como los toros no entran en estas frecuencias, no vuelven a contarse como vacas. Otra solución válida consiste en marcar posiciones usadas en dos recorridos, primero exactos y después parciales; no combinar ambas estrategias sin necesidad.

En `RRVA / RVRR`, la primera R es toro. Quedan R,V,A frente a V,R,R: solo una R y una V pueden producir vacas. En `AAAA / AARR`, tras retirar dos toros quedan A,A frente a R,R y no hay vacas.

### Pruebas adicionales propuestas

| Prueba | Resultado esperado |
| --- | --- |
| RVAM / RVAM | 4 toros, 0 vacas. |
| RVAM / VAMR | 0 toros, 4 vacas. |
| RRRR / RRRR | 4 toros, 0 vacas. |
| RRRR / VVVV | 0 toros, 0 vacas. |
| RRVVA / VVRRA | 1 toro, 4 vacas en N=5. |
| ENTER con un hueco | Mensaje; historial e intentos consumidos sin cambios. |
| Acierto en el último turno | Victoria, aunque ya no queden intentos para otro turno. |
| Último turno incorrecto | Derrota y revelación del secreto. |

Invariantes: 0 <= toros <= N, 0 <= vacas <= N, toros+vacas <= N; el evaluador no consume turnos ni altera los arreglos de entrada. La gestión de partida decide cuándo registrar el resultado.

## 7. Datos y arquitectura propuestos

### Tablas y variables

Usar identificadores lógicos 0..C-1 y un centinela como FFh para una posición vacía. **La ficha lógica 0 es válida y no debe confundirse con un hueco ni con la transparencia de los píxeles.** El teclado 1..C se convierte al identificador 0..C-1.

| Dato | Reserva sugerida | Observación |
| --- | --- | --- |
| secreto | 5 bytes | Usar solo las N posiciones del nivel. |
| intentoActual | 5 bytes | Inicializar las posiciones activas a FFh. |
| historial | 12 × 5 = 60 bytes | Paso fijo de cinco bytes por intento. |
| torosHistorial | 12 bytes | Un conteo por intento guardado. |
| vacasHistorial | 12 bytes | Un conteo por intento guardado. |
| frecuenciaSecreto e Intento | 8 bytes cada tabla | Limpiar antes de cada evaluación. |
| ultimoSecreto | 5 bytes, más nivel y bandera | Comparación entre partidas consecutivas. |
| configuración | Tabla de N, C, repetición e intentos | No dispersar números por las rutinas. |
| estado y selección | Bytes o palabras según su uso | Pantalla, posición activa, opción de menú, resultado. |
| tiempo y PRNG | Palabras o pares de palabras | Semilla, último tic y cuadro de animación. |

Con paso fijo de cinco: `offsetHistorial = fila * 5 + columna`; dibujar solo N columnas. Al reiniciar, limpiar propuesta, historial lógico, conteos, mensajes, selección y estado de animación. Mantener el estado necesario del generador y del secreto anterior.

### Módulos y procedimientos

Los siguientes nombres son una propuesta; superan el mínimo de doce y dividen el trabajo en responsabilidades comprobables.

| Área | Procedimientos propuestos |
| --- | --- |
| Arranque y salida | GuardarModoVideo, IniciarVideo, RestaurarVideo, SalirDOS. |
| Pantallas | MostrarPresentacion, MostrarMenu, MostrarInstrucciones, MostrarCreditos, SeleccionarNivel, MostrarFinal. |
| Partida | IniciarPartida, ProcesarTeclaJuego, CambiarPosicion, CambiarFicha, BorrarPosicion, ValidarIntento, RegistrarIntento. |
| Algoritmo | EvaluarIntento, GenerarSecreto, SiguienteAleatorio, IngresarSecretoPrueba. |
| Gráficos | CargarPaleta, DibujarSprite, DibujarTablero, DibujarPanel, DibujarTexto, RestaurarRegion. |
| Servicios | LeerTeclaNoBloqueante, LeerTics, ActualizarAnimacion, ActualizarIndicadores. |

Cada encabezado PROC debe especificar sus contratos. Por ejemplo, `DibujarSprite` puede recibir datos por DS:SI, ancho en CX, alto en DX y coordenadas por registros o pila según un convenio único documentado. Debe indicar el segmento destino y qué preserva. No improvisar convenios diferentes en cada llamada.

Para llamadas NEAR con `PUSH BP / MOV BP,SP`, el primer parámetro más próximo está en [BP+4]. Para FAR, está en [BP+6], porque se guarda también CS. Depende del tipo de llamada y del orden de apilado. Elegir **una sola** limpieza: el llamador ajusta SP o el procedimiento usa `RET n`; nunca ambas.

### Organización de pantallas y bucle principal

Estados propuestos: presentación, menú, selección de nivel, instrucciones, créditos, partida, victoria, derrota y salida. La entrada manual puede ser un estado de prueba documentado. Cambiar de estado redibuja la pantalla correspondiente y reinicializa sus selecciones necesarias.

En cada vuelta del bucle: consultar tics, actualizar cuadros vencidos, comprobar si hay tecla, consumirla si existe y procesarla según la pantalla. Así las animaciones siguen ejecutándose mientras el jugador piensa. No encadenar llamadas recursivas al menú o a una nueva partida: regresar a un coordinador para que la pila no crezca en cada reinicio.

La propuesta de teclado es INT 16h, AH=01h para comprobar disponibilidad y AH=00h para consumir la tecla cuando ZF=0. Una comprobación sin consumo deja la misma tecla pendiente. Interpretar ASCII en AL y scan code en AH según corresponda; no esperar el prefijo de un flujo de caracteres DOS al utilizar directamente la interfaz BIOS.

| Tecla | Código útil |
| --- | --- |
| Arriba | Scan code 48h. |
| Abajo | Scan code 50h. |
| Izquierda | Scan code 4Bh. |
| Derecha | Scan code 4Dh. |
| ENTER | ASCII 0Dh. |
| BACKSPACE | ASCII 08h. |
| ESC | ASCII 1Bh. |

### Aleatoriedad y temporización

Inicializar el generador con CX:DX de INT 1Ah, AH=00h. Mantener un estado pseudoaleatorio y avanzarlo por ficha; releer el mismo tic para cada posición no produce una secuencia adecuada. Reducir cada resultado al rango 0..C-1. En Fácil, rechazar tipos ya utilizados o extraerlos de una tabla sin reemplazo.

La semilla temporal no garantiza por sí sola que el secreto siguiente sea distinto. RF-04 exige comparar con el secreto anterior y regenerar si coinciden. Si ambas partidas tienen N=4, comparar aunque se cambie entre Fácil y Normal; si N cambia, los códigos ya difieren en longitud. El modo de pruebas manuales debe ser explícito y separado del generador normal.

La temporización de cuadros debe medirse con tics BIOS o retrazos, como exige RG-06. Evitar retardos basados únicamente en decrementar un registro. Si se lee el contador de 32 bits directamente en dos mitades, evitar una lectura inconsistente durante su actualización. Prever desbordamientos del contador usado y el reinicio diario de los tics. No deshabilitar permanentemente las interrupciones: el reloj y el teclado dependen de ellas.

## 8. Herramientas locales verificadas

| Componente | Estado y función |
| --- | --- |
| VS Code | Editor del fuente y punto de acceso a tareas de construcción. |
| NASM Code Lens 3.0.8 | Extensión `maziac.asm-code-lens`; admite NASM, MASM y otras sintaxis. No sustituye TASM. |
| Go Asm 0.0.5 | Extensión `quillaja.goasm`; resalta y autocompleta ensamblador de Go. No es el ensamblador DOS de este proyecto. |
| DOSBox 0.74-3 | Ejecutable en `C:\Program Files (x86)\DOSBox-0.74-3\DOSBox.exe`. |
| TASM | `C:\TASM\TASM.EXE`, ensamblador. |
| TLINK | `C:\TASM\TLINK.EXE`, enlazador. |
| Turbo Debugger | `C:\TASM\TD.EXE`, depuración de registros, memoria, pila y flujo. |
| Python | `python.exe` localizado en `C:\msys64\mingw64\bin\python.exe` durante la revisión. No se encontró `py` en PATH. |

Configuración **propuesta**, todavía no aplicada, para archivos `.asm` y `.inc`:

```json
{
  "files.associations": {
    "*.asm": "asm-x86-masm",
    "*.inc": "asm-x86-masm"
  },
  "asm-code-lens.assembler": "masm (x86)"
}
```

Estas claves y valores se comprobaron en el manifiesto de la extensión instalada. El dialecto lo determina el ensamblador real y la tarea de construcción. Usar NASM Code Lens como editor no obliga a construir con NASM. Windows de 64 bits no ejecuta directamente estas herramientas DOS de 16 bits; TASM, TLINK, TD y el juego se ejecutan dentro de DOSBox.

### Scripts de automatización existentes

```text
C:\Users\jcaba\OneDrive\Desktop\Stuff\U\6to cuatri\Arqui IItry\ASM\practicas\TASM_asistance.py
C:\Users\jcaba\OneDrive\Desktop\Stuff\U\6to cuatri\Arqui IItry\ASM\practicas\TASM_asistance_C_TASM.py
```

También hay lanzadores `.bat` y una copia de la variante C_TASM en `C:\TASM`.

| Variante | Comportamiento del menú sin archivo explícito |
| --- | --- |
| TASM_asistance.py | Busca `.asm` en la carpeta donde está el propio script. |
| TASM_asistance_C_TASM.py | Busca `.asm` en `C:\TASM`. |

Ambas variantes aceptan un archivo explícito y `--modo ensamblar`, `--modo ejecutar`, `--modo depurar`, además de `--tasm`, `--dosbox` y `--debug-mode`.

Flujo observado: valida el fuente y herramientas; crea una carpeta temporal; copia el principal como PROG.ASM; copia `.inc`, `.mac`, `.h` y `.lib` de la misma carpeta; genera BUILD.BAT y dosbox.conf; monta el trabajo como C: y TASM como T:; ejecuta `TASM /zi` y `TLINK /v`; opcionalmente ejecuta PROG.EXE o TD; conserva el registro `.build.log` y copia los resultados junto al fuente al cerrar DOSBox.

El marcador SUCCESS.OK permite distinguir un ensamblado/enlace completado de uno fallido. El script es una base útil, con estas limitaciones para el juego:

| Observación | Consecuencia y adaptación propuesta |
| --- | --- |
| Ensambla únicamente PROG.ASM. | No procesa automáticamente varios `.asm` con PUBLIC/EXTRN. Empezar con principal más includes o añadir construcción de todos los módulos. |
| Copia dependencias solo de la carpeta inmediata. | No conserva subcarpetas, includes anidados ni nombres de dependencias largos bajo una política 8.3. Definir una preparación reproducible. |
| Ejecuta desde una carpeta temporal. | Recursos o archivos de puntajes externos deben copiarse; guardar un puntaje allí lo pierde al borrar el temporal si no se devuelve a su ubicación persistente. |
| Devuelve resultados al lado del fuente. | Adaptar el destino a `/bin` al preparar la entrega. |
| Espera cierre de DOSBox y contiene PAUSE. | Es interactivo; no sirve por sí solo como verificación desatendida. |
| Comprueba códigos de error, pero no rechaza avisos de TASM. | Revisar BUILD.LOG para satisfacer el requisito de cero advertencias. |

El ejercicio local `ej1.asm` no debe copiarse como plantilla completa: no inicializa DS, no prepara correctamente la salida por INT 21h y no contiene una terminación DOS correcta. Para acceder a `.DATA`, inicializar DS; para terminar, usar la función 4Ch tras restaurar video.

## 9. Construcción y estructura de entrega propuestas

| Carpeta o archivo | Contenido previsto |
| --- | --- |
| `/src/main.asm` | Punto de entrada y coordinación. Nombre MAIN cumple 8.3. |
| `/src/*.inc` | Constantes, tablas, macros y procedimientos agrupados, con nombres cortos. |
| `/bin` | Ejecutable probado y archivos de construcción necesarios. |
| `/sprites` | Diseños originales, hoja de sprites y cuadros. |
| `/herramientas` | Conversor de sprites y automatización auxiliar. |
| `/doc` | Documento técnico, bitácora, tabla de paleta y pruebas. |
| `README.md` | Comandos exactos, controles, modo de prueba y configuración utilizada. |

Los siguientes comandos son un **modelo pendiente de validación con el juego real**. Suponen MAIN.ASM e includes en `/src`, una sola unidad de ensamblado y `/bin` ya creado. Se ejecutan dentro de DOSBox:

```dos
mount c "C:\Users\jcaba\OneDrive\Desktop\Stuff\U\6to cuatri\Arqui IItry\Proyecto_II_Arqui"
mount t "C:\TASM"
c:
cd \src
t:\tasm.exe /zi main.asm
t:\tlink.exe /v main.obj,\bin\juego.exe
cd \bin
juego.exe
```

Para depurar, desde C:\SRC, después del enlace:

```dos
t:\td.exe c:\bin\juego.exe
```

Como base de prueba de la automatización externa, este comando PowerShell ensamblará un fuente cuando exista; aún no se ejecutó con el juego:

```powershell
python "C:\Users\jcaba\OneDrive\Desktop\Stuff\U\6to cuatri\Arqui IItry\ASM\practicas\TASM_asistance.py" ".\src\main.asm" --modo ensamblar --tasm "C:\TASM" --dosbox "C:\Program Files (x86)\DOSBox-0.74-3\DOSBox.exe"
```

El mismo comando admite `--modo ejecutar` o `--modo depurar`. Su comportamiento sigue sujeto a las limitaciones de la sección 8. El README final debe contener comandos realmente probados desde una copia limpia y la configuración estándar del curso, no conservar estos ejemplos como si ya estuvieran verificados.

## 10. Entregables obligatorios y opcionales

| ID | Entrega | Condición |
| --- | --- | --- |
| E1 | Fuentes `.asm` y `.inc` comentados, en repositorio o comprimido con `/src`, `/bin`, `/sprites`, `/herramientas`, `/doc`. | Obligatoria. |
| E2 | `.exe` o `.com` probado en DOSBox y `.conf` o script de arranque usado. | Obligatoria. |
| E3 | README con ensamblado, enlace y ejecución reproducibles copiando y pegando los comandos. | Obligatoria. |
| E4 | Documento técnico de **8 a 12 páginas**. | Obligatoria. |
| E5 | Hoja de todos los sprites y cuadros, más las tablas de bytes correspondientes. | Obligatoria. |
| E6 | Bitácora de **una página por semana** con el aporte de cada integrante. | Obligatoria. |
| E7 | Video de **3 a 5 minutos**, con una partida ganada y una perdida. | Opcional, recomendado. |

El documento técnico E4 debe incluir diseño de la solución, diagrama de módulos, algoritmo de toros y vacas, mapa de memoria de video, tabla de paleta, hoja de sprites, dificultades y sus soluciones. Esta memoria es una referencia de planificación; el E4 final debe describir y demostrar la implementación terminada.

### Funcionalidades extra del PDF

1. Cronómetro de partida con tics BIOS.
2. Mejores puntajes persistidos mediante INT 21h: 3Ch, 3Dh, 3Fh, 40h y 3Eh.
3. Sonido con altavoz interno, puerto 61h y temporizador 8253/8254, con control en 43h.
4. Modo inverso: el programa deduce el secreto del jugador mediante descarte.
5. Dos jugadores por turnos en la misma máquina.
6. Transiciones mediante cambios progresivos de paleta.

El extra se anuncia como **+5 %** y el texto relaciona su concesión con completar las tareas. No asumir que una sola función obtiene el total: confirmar cómo se reparte. Priorizar primero todos los requisitos básicos. La introducción manual del secreto para pruebas es obligatoria y no equivale por sí sola al extra de dos jugadores.

## 11. Evaluación y defensa

| Rubro | Peso interno del proyecto | Evaluación |
| --- | ---: | --- |
| A. Lógica y funcionamiento | 50 % | Ejecución guiada y preguntas sobre el código. |
| B. Gráficos, sprites y personalización | 20 % | Revisión visual y de código. |
| C. Defensa escrita | 25 % | Prueba individual. |
| D. Documentación y proceso | 5 % | Entregables E3 a E6. |
| Extras | +5 % | Funcionalidades opcionales según criterio del docente. |

### Desglose de A

| Criterio | Puntos |
| --- | ---: |
| Algoritmo correcto en los cuatro casos, con repetidos. | 15 |
| Generación pseudoaleatoria y conforme al nivel. | 5 |
| Ciclo completo: turnos, validación, historial, victoria, derrota y reinicio. | 12 |
| Teclado robusto y sin cuelgues. | 6 |
| Menú y navegación entre pantallas en cualquier orden. | 5 |
| Modularidad, pila, macros y tablas. | 5 |
| Salida y restauración de video. | 2 |
| Total | 50 |

### Desglose de B y D

| Rubro | Criterio | Puntos |
| --- | --- | ---: |
| B | Rutina genérica de sprites con transparencia, utilizada por el juego. | 5 |
| B | Sprites originales y distinguibles para fichas e iconos. | 5 |
| B | Tres elementos animados con temporización independiente de CPU. | 4 |
| B | Paleta por puertos y documentada. | 3 |
| B | Sin parpadeo y con coherencia temática. | 3 |
| D | Documento técnico completo. | 2 |
| D | README reproducible. | 1 |
| D | Hoja de sprites y tabla de paleta. | 1 |
| D | Bitácora verificable con reparto de trabajo. | 1 |

### Penalizaciones que deben conservarse

| Situación | Consecuencia del PDF |
| --- | --- |
| Entrega tardía | -10 % por día natural, hasta tres días; después no se recibe. |
| No ensambla con el README | Se evalúa lo que el docente consiga ejecutar; A depende de lo demostrado. |
| Ausencia injustificada a la defensa | Cero en C para el estudiante ausente. |
| Código que los autores no pueden explicar | Se anula el rubro correspondiente y se abre proceso por integridad académica. |
| Copia entre parejas o código ajeno sin declarar | Cero en el proyecto para las partes involucradas. |

### Defensa práctica y escrita

La demostración conjunta dura **10 minutos**. Alimenta A y B, sin nota separada, y puede incluir cambios en vivo: índice transparente, ubicación de una zona o velocidad de animación.

La prueba escrita dura **50 minutos**, es individual, sin computadora ni apuntes, salvo **una hoja de referencia de una cara, escrita a mano por el estudiante**. El PDF plantea inicialmente diez preguntas de selección y una de desarrollo, con estructura y secciones definitivas por anunciar. Las preguntas se basan en el código entregado y pueden producir calificaciones distintas para los integrantes.

Preparación propuesta: ambos deben explicar la evaluación con repetidos, índices de los arreglos, fórmula del píxel, paleta, DS/ES, lectura del teclado, temporización, pila, macro frente a PROC y secuencia TASM/TLINK/DOSBox. Practicar los cambios pequeños que el docente puede solicitar y llevar un reparto de trabajo real en la bitácora.

## 12. Ruta de desarrollo y comprobaciones

| Etapa | Resultado comprobable |
| --- | --- |
| 1. Acuerdos | Temática e integrantes definidos; resolver las doce filas; obtener configuración DOSBox y fecha de entrega. |
| 2. Construcción mínima | Inicialización DS, guardado de modo, entrada en 13h, dibujo directo y salida con restauración. Ensamblado limpio. |
| 3. Núcleo lógico | Evaluador separado de la interfaz y ruta de secreto manual. Superar los cuatro casos antes de integrar efectos. |
| 4. Datos y generador | Configuración por tablas; secretos correctos en los tres niveles y comparación entre consecutivos. |
| 5. Entrada y partida | Selección, borrado, validación, consumo de turno e historial, con victoria prioritaria en el último intento. |
| 6. Recursos originales | Ocho fichas de al menos 16 × 16, transparencia, paleta programada y tabla documentada. |
| 7. Interfaz completa | Presentación, menú, dificultad, instrucciones gráficas, créditos, indicadores y final. |
| 8. Animación | Mascota, selección y resultados diferenciados; siguen activos sin pulsar teclas y sin parpadeo. |
| 9. Integración | Múltiples partidas y navegación sin fuga de pila ni residuos de estado. |
| 10. Entrega y defensa | Construcción desde copia limpia, E1 a E6, video si se decide y preparación individual. |

### Lista de aceptación para la implementación futura

- [ ] Están los 14 RF, los 8 RG y los 8 RT, sin sustituirlos por decisiones estéticas.
- [ ] La entrada manual permite los cuatro casos del PDF y los resultados son exactos.
- [ ] Fácil usa N=4, C=6, 12 intentos y secreto sin repetidos; Normal 4/6/10; Difícil 5/8/10.
- [ ] Se resolvió la contradicción de filas y el historial entero queda visible simultáneamente.
- [ ] ENTER incompleto, BACKSPACE y teclas inválidas no consumen turnos indebidamente.
- [ ] El último intento puede ganar; perder revela el secreto.
- [ ] Hay ocho fichas originales, formas distinguibles y tamaños mínimos cumplidos.
- [ ] DibujarSprite es genérico; el píxel cero es transparente; no hay rastros entre cuadros.
- [ ] Se redefinen al menos 16 entradas VGA y se entrega su tabla.
- [ ] Las animaciones funcionan durante la espera del usuario y a distintas configuraciones de ciclos DOSBox.
- [ ] Todos los PROC documentan contratos, quedan bajo el límite y preservan registros correctamente.
- [ ] Una macro propia se utiliza más de una vez y no causa etiquetas duplicadas.
- [ ] Repetir menú, partida y reinicio mantiene SP balanceado; DS/ES no se corrompen.
- [ ] El modo original se guarda antes del cambio y se restaura en toda salida normal.
- [ ] El README construye una copia limpia sin depender de ejecutables anteriores ni rutas personales de recursos.
- [ ] Están E1 a E6 y cada integrante puede defender el código entregado.

## 13. Material de EduCore para este desarrollo

Esta sección resume el material leído; no reproduce íntegramente el sitio. Los ejemplos de consola sirven para aprender mecanismos, mientras que la interfaz final debe cumplir el modo gráfico y el acceso directo a video del PDF. Las restricciones de un ejercicio, como prohibir macros en el nivel inicial, no se trasladan al proyecto.

### Tema 4 Lenguaje ensamblador

| Lección | Conceptos y aplicación |
| --- | --- |
| [1. Introducción](http://23.22.58.242/arquitectura/topic/topic4/introduccion-ensamblador) | Relación entre instrucciones, hardware y estructuras de memoria; control de bajo nivel. Justifica los accesos a VGA y BIOS. |
| [2. Registros](http://23.22.58.242/arquitectura/topic/topic4/registros) | AX/BX/CX/DX y mitades, índices SI/DI, SP/BP, segmentos y FLAGS. Definir qué guarda cada rutina y qué registros devuelve. |
| [3. Sintaxis y direccionamiento](http://23.22.58.242/arquitectura/topic/topic4/sintaxis-direccionamiento) | Inmediatos, registros, memoria, OFFSET, PTR, SEG, DUP y EQU. Aplicación directa a tablas, punteros y constantes. Incluye constructor y validador de instrucciones. |
| [4. Instrucciones](http://23.22.58.242/arquitectura/topic/topic4/instrucciones-fundamentales) | Transferencias, aritmética, bits y desplazamientos; simuladores aritmético y lógico. Usar MUL para offsets o DIV para rangos cuidando sus registros implícitos. |
| [5. Flujo y pila](http://23.22.58.242/arquitectura/topic/topic4/control-flujo-pila) | CMP/TEST, saltos con y sin signo, LOOP, PUSH/POP y CALL/RET. Base de validación, histogramas y contratos de procedimientos. |
| [6. Segmentos](http://23.22.58.242/arquitectura/topic/topic4/segmentos) | Dirección física = segmento × 16 + desplazamiento; directivas simplificadas y diferencias entre COM/EXE. Inicializar DS y reservar ES para el destino requerido. |
| [7. Interrupciones](http://23.22.58.242/arquitectura/topic/topic4/interrupciones) | Funciones BIOS/DOS y parámetros en registros. Priorizar INT 10h para modo, INT 16h para teclado e INT 21h para salida; INT 1Ah se exige además en el PDF. |

### Tema 5 Del fuente al ejecutable

| Lección | Conceptos y aplicación |
| --- | --- |
| [1. Ensamblado y enlace](http://23.22.58.242/arquitectura/topic/topic5/proceso-ensamblado) | Montaje DOSBox, nombres 8.3 y transformación ASM → OBJ → EXE. Incluye terminal simulado y rastreo de registros. Base del README. |
| [2. Depuración](http://23.22.58.242/arquitectura/topic/topic5/debug) | Construcción con TASM /zi y TLINK /v; CPU, registros, memoria y pila en TD. F7 entra en llamadas, F8 las ejecuta sin entrar, F9 continúa, F2 fija breakpoint y Alt+X sale. |
| [3. Macros](http://23.22.58.242/arquitectura/topic/topic5/macros) | Expansión durante ensamblado, argumentos, LOCAL e INCLUDE. Una macro corta puede reducir repetición; DibujarSprite debe seguir siendo un procedimiento genérico. |
| [4. Subprogramas](http://23.22.58.242/arquitectura/topic/topic5/enlace-subprogramas) | PUBLIC/EXTRN, objetos enlazados, NEAR/FAR y parámetros por registros o pila. Útil si después se adopta construcción de varios módulos. |
| [5. Memoria DOS](http://23.22.58.242/arquitectura/topic/topic5/administracion-memoria) | PSP, memoria convencional, carga EXE y bloques. Relevante para DS inicial y presupuesto de recursos; los TSR no son necesarios. |
| [6. Interoperabilidad](http://23.22.58.242/arquitectura/topic/topic5/compiladores) | Convenios de llamada y enlace con C como contexto conceptual. **No aplicar la integración con C al juego**, porque RT-08 la prohíbe. |
| [7. Integrador](http://23.22.58.242/arquitectura/topic/topic5/proyecto) | Separación entre coordinación, lectura, procesamiento y presentación. Su ordenamiento de números es un ejercicio diferente a Mastermind. |

### EjerciciosASM

| Nivel | Conceptos y relación con el proyecto |
| --- | --- |
| [1. Iniciales](http://23.22.58.242/arquitectura/topic/topic6/nivel1) | Datos predefinidos, registros, comparaciones, bucles, cadenas y arreglos. Practicar el núcleo antes de mezclar entrada y gráficos. |
| [2. Teclado e IDE](http://23.22.58.242/arquitectura/topic/topic6/nivel2) | ASCII frente a binario, lectura de caracteres y búferes, automatización de TASM/TLINK. El juego usará la interfaz BIOS exigida por RF-06. |
| [3. Datos y cadenas](http://23.22.58.242/arquitectura/topic/topic6/nivel3) | Un byte adquiere significado por su uso. Separar caracteres ASCII, tipos de ficha, centinelas e índices de píxel. |
| [4. Procedimientos y macros](http://23.22.58.242/arquitectura/topic/topic6/nivel4) | Parámetros, preservación de registros, reutilización y archivos compartidos. Preparación directa para RT-01 a RT-05. |
| [5. Archivos](http://23.22.58.242/arquitectura/topic/topic6/nivel5) | Crear, abrir, leer, escribir y cerrar con handles; CF y códigos de error. Necesario solo si se elige persistencia opcional o recursos externos. |
| [6. Arreglos y búsqueda](http://23.22.58.242/arquitectura/topic/topic6/nivel6) | Índices, límites, recorridos y bucles anidados. No ordenar el secreto o el intento para evaluarlos: se perdería su información posicional. |
| [7. Integradores](http://23.22.58.242/arquitectura/topic/topic6/nivel7) | Descomposición del problema y combinación de técnicas. El ejercicio 7.5, histograma por valor usado como índice, inspira las dos tablas del evaluador. |

### Simulaciones comprobadas durante la revisión

| Simulación | Entrada o acción | Observación |
| --- | --- | --- |
| Pila, tema 4 lección 5 | PUSH de 1234h desde SP=FFFEh. | SP pasa a FFFCh y aparece el valor apilado. |
| Misma pila | POP del valor anterior. | Se extrae 1234h, queda vacía y SP regresa a FFFEh. |
| CMP, tema 4 lección 5 | AX=3, BX=5. | Resultado interno -2; CF=1, ZF=0, SF=1 y OF=0. Los operandos no se sustituyen por la resta. |

También se identificaron los visualizadores de registros, direccionamiento y segmentación, los simuladores aritméticos y lógicos, la expansión de macros y las secuencias de ensamblado y depuración. Se revisó su contenido, pero no se probaron todas sus combinaciones. Son apoyos conceptuales y no sustituyen ejecutar el ASM real en DOSBox.

## 14. Errores de ejemplo y precauciones concretas

Estas observaciones se deducen al revisar el código mostrado; no modifican las instrucciones de entrega.

1. **Resultado sobrescrito en AH.** En el ejemplo `act1.asm` de proceso de ensamblado, DIV deja las unidades en AH, pero luego se carga AH=02h para imprimir las decenas antes de preservar las unidades. Guardar cada resultado antes de preparar una interrupción que reutilice el mismo registro.
2. **Limpieza doble de pila.** El ejemplo por pila de enlace de subprogramas muestra tanto `ADD SP,4` en el llamador como `RET 4` en el procedimiento. Elegir solo una limpieza. Además, ajustar los offsets según el CALL sea NEAR o FAR.
3. **Archivo no equivale a segmento.** Dos fuentes distintos no obligan por sí solos a usar FAR. La distancia de llamada depende de los segmentos y del convenio de enlace. Las directivas simplificadas también pueden utilizarse en proyectos con varios objetos si se organizan consistentemente.
4. **Sintaxis de memoria.** La última línea del ejemplo de píxel del PDF solo es ensamblable como MOV directo si el origen es inmediato o registro. Si `indiceColor` se declara como variable de memoria, cargar primero su byte en un registro y luego escribirlo a ES:[DI]. El MOV ordinario del 8086 no copia memoria a memoria.
5. **Búferes y contadores.** Extender un byte usado como índice limpiando la mitad alta del registro. No usar LOOP con CX=0 esperando cero iteraciones: primero decrementa y pasa a FFFFh. Preparar todo CX si se utilizará como contador de palabra.
6. **Instrucciones compatibles.** Para una base 8086, usar BX/BP/SI/DI y combinaciones válidas de direccionamiento. No escribir [AX], [CX] ni escalas de índice de 32 bits. Elegir instrucciones acordes con la CPU declarada.
7. **Segmentos y límites.** Los 64 000 bytes de pantalla no convierten todo A000h en área visible. El último offset visible es F9FFh. Una rutina que usa temporalmente DS o ES debe restaurarlos según su contrato.
8. **Generalizaciones del sitio.** Un EXE DOS no tiene memoria ilimitada ni un encabezado fijo de 512 bytes en todos los casos. La ausencia de símbolos afecta la depuración por fuente; no basta para diagnosticar por sí sola todo error de carga en TD. Usar los ejemplos para estudiar y comprobar sus supuestos con el ejecutable real.

## 15. Decisiones pendientes y continuidad

| Pendiente | Estado o criterio de resolución |
| --- | --- |
| Nombre, temática y diseños | No definidos por el usuario en esta solicitud. Deben ser originales y distintos a otras parejas. |
| Integrantes y reparto | Confirmar nombres y registrar aportes reales semanalmente. |
| Doce intentos dentro de la maqueta | Conflicto expreso del PDF. Acordar una adaptación antes del diseño final. |
| Propuestas repetidas en Fácil | El secreto sin repetidos es indiscutible. Confirmar si se debe rechazar también una propuesta repetida; mientras tanto, no afirmar que el PDF lo resuelve de forma explícita. |
| Configuración DOSBox del curso | Se verificó una instalación local 0.74-3; falta la configuración concreta exigida por el docente. |
| Fecha de entrega y defensa | No aparecen en el PDF consultado. Obtenerlas del docente o del aula virtual. |
| Acceso al secreto manual | Definir tecla, menú de pruebas o parámetro y documentar la correspondencia entre letras y fichas. |
| Reparto del +5 % extra | Confirmar si exige todas las funciones y cómo se asigna. |
| Diseño de construcción | Propuesta inicial: una unidad ASM con includes. Adaptar el script solo si la estructura lo requiere. |
| Fuentes y recursos definitivos | Aún no implementados; los comandos de la sección 9 se validarán con ellos. |

Para continuar el trabajo, leer primero esta memoria y contrastar cualquier cambio con la página correspondiente del PDF. Conservar separados requisitos, propuestas y acuerdos confirmados. Actualizar los pendientes al tomar decisiones y mantener la trazabilidad RF/RG/RT en las comprobaciones. La primera prioridad de programación será un entorno mínimo que entre y salga correctamente de modo 13h, seguido del evaluador y sus cuatro pruebas obligatorias.

## 16. Recursos técnicos de HelpPC

El [índice de HelpPC](https://helppc.netcore2k.net/topics) reúne instrucciones, interrupciones, tablas BIOS/DOS y hardware. Usarlo como consulta de registros, banderas y formatos. Contiene instrucciones de varias generaciones de x86: que aparezcan en el índice no significa que todas existan en un 8086.

### Video, reloj, teclado y salida

| Referencia consultada | Datos que necesita el juego |
| --- | --- |
| [INT 10h, AH=00h](https://helppc.netcore2k.net/interrupt/int-10-0) | AL=13h selecciona 320 × 200 con 256 colores. El bit 7 de AL afecta el borrado en adaptadores compatibles; para el arranque normal del juego usar el modo solicitado por el PDF. |
| [INT 10h, AH=0Fh](https://helppc.netcore2k.net/interrupt/int-10-f) | Devuelve AL=modo, AH=columnas y BH=página activa. Guardar el modo antes del cambio; conservar también la página si se desea restaurarla. No equivale a capturar todo el contenido previo de pantalla. |
| [INT 16h, AH=00h](https://helppc.netcore2k.net/interrupt/int-16-0) | Espera y consume una tecla; devuelve scan code en AH y ASCII en AL, con cero para teclas especiales de la interfaz clásica. |
| [INT 16h, AH=01h](https://helppc.netcore2k.net/interrupt/int-16-1) | ZF=0 indica tecla pendiente; consultar no la retira del búfer. Decidir por ZF y luego consumir, permitiendo animación durante la espera. |
| [Tabla de scan codes](https://helppc.netcore2k.net/table/scan-codes) | AX típico: arriba 4800h, abajo 5000h, izquierda 4B00h, derecha 4D00h, ENTER 1C0Dh, BACKSPACE 0E08h y ESC 011Bh. Probar teclado numérico y teclas dedicadas en el DOSBox elegido. |
| [INT 1Ah, AH=00h](https://helppc.netcore2k.net/interrupt/int-1a-0) | CX:DX contiene los tics; AL informa del cambio diario. Frecuencia aproximada: 18,206 tics/s; el contador vuelve a cero a medianoche. Es la fuente exigida para la semilla. |
| [BIOS Data Area](https://helppc.netcore2k.net/table/bda) | 0040h:006Ch es un contador de cuatro bytes actualizado por INT 08h; 0040h:0070h contiene la indicación de cambio diario. El contador ocupa dos palabras en código de 16 bits. |
| [INT 21h, AH=4Ch](https://helppc.netcore2k.net/interrupt/int-21-4c) | AL es el código devuelto a DOS. Propuesta: AX=4C00h en una salida normal, después de restaurar video y cerrar recursos propios. |

A partir de la frecuencia documentada, un tic representa aproximadamente 54,9 ms. **Cálculo propuesto:** cambiar de cuadro cada tres tics da aproximadamente 164,8 ms por cuadro, unas 6,1 actualizaciones por segundo. Elegir el intervalo por tabla o constante para poder cambiarlo durante la defensa. El reloj del juego y el intervalo de la animación son usos distintos del mismo contador.

### Puertos VGA e instrucciones de transferencia

| Referencia consultada | Aplicación y decisión |
| --- | --- |
| [Direcciones de puertos](https://helppc.netcore2k.net/hardware/hardware-ports) | 3C8h selecciona la entrada del DAC, 3C9h transmite los componentes y 3DAh es un registro de estado. El PDF identifica el bit 3 de 3DAh para el retrazo. |
| [OUT](https://helppc.netcore2k.net/asm/out) | La forma con puerto inmediato solo admite 0..255. Para 3C8h y 3C9h cargar DX y usar `OUT DX,AL`; **no escribir `OUT 3C8h,AL`**. OUT no modifica FLAGS. |
| [MOVSW](https://helppc.netcore2k.net/asm/movsw) | Copia una palabra desde DS:SI hacia ES:DI; ambos índices avanzan o retroceden según DF. Sirve para el búfer opcional; MOVSD no pertenece al 8086. |
| [REP](https://helppc.netcore2k.net/asm/rep) | Para `REP MOVSW`, CX es el número de palabras y se repite hasta agotarlo. Usar CX=32000 para una pantalla completa. No confundirlo con REPE/REPNE de comparaciones. |
| [CALL](https://helppc.netcore2k.net/asm/call) y [RET](https://helppc.netcore2k.net/asm/ret) | CALL guarda IP y, en FAR, también CS. El operando de RET libera bytes adicionales; confirma por qué no debe duplicarse la limpieza de parámetros. |
| [Paleta por BIOS](https://helppc.netcore2k.net/interrupt/int-10-10) | HelpPC también documenta servicios de paleta de INT 10h. Son contexto; **RG-07 exige OUT a puertos**, por lo que no sustituyen esa implementación. |

Secuencia de paleta propuesta: elegir el primer índice mediante 3C8h y transmitir R, G, B por 3C9h para cada entrada. Mantener componentes en 0..63 y los datos de la paleta en una tabla. No confundir el índice de una entrada con el valor de sus componentes.

### Archivos si se implementan mejores puntajes

| Función consultada | Entradas y resultado útil |
| --- | --- |
| [3Ch crear](https://helppc.netcore2k.net/interrupt/int-21-3c) | DS:DX apunta al nombre terminado en cero y CX a atributos. Con éxito devuelve handle en AX. Si el archivo existe, lo trunca: no usarla indiscriminadamente al cargar puntajes. |
| [3Dh abrir](https://helppc.netcore2k.net/interrupt/int-21-3d) | DS:DX nombre ASCIIZ; AL=0 lectura, 1 escritura, 2 lectura/escritura. Devuelve handle en AX o un código de error si CF=1. |
| [3Fh leer](https://helppc.netcore2k.net/interrupt/int-21-3f) | BX=handle, CX=bytes solicitados y DS:DX=búfer. AX informa los bytes realmente leídos; cero indica fin de archivo para una lectura de tamaño positivo. |
| [40h escribir](https://helppc.netcore2k.net/interrupt/int-21-40) | BX=handle, CX=longitud y DS:DX=datos. Comprobar CF y que AX coincida con la longitud esperada. Escribir cero bytes tiene efectos sobre el tamaño del archivo. |
| [3Eh cerrar](https://helppc.netcore2k.net/interrupt/int-21-3e) | BX=handle. Cerrar todos los archivos abiertos también en las rutas de error. |
| [Handles predeterminados](https://helppc.netcore2k.net/table/default-handles) | 0=entrada, 1=salida, 2=error, 3=auxiliar y 4=impresora. **Usar el handle devuelto por DOS**, no suponer que el primer archivo recibe 3. |

La última referencia corrige una simplificación del nivel 5 de EduCore. Para los nombres DOS usar cadenas terminadas en cero; el terminador `$` pertenece a otra interfaz de impresión. Si se usa el asistente temporal existente, devolver el archivo de puntajes a una ubicación persistente antes de que se borre el directorio de trabajo.

### Sonido y formato ejecutable

El [temporizador 8253/8254](https://helppc.netcore2k.net/hardware/8253) documenta el puerto 42h como datos del canal 2, asociado al altavoz, y 43h como control. Esto completa la mención de 43h y 61h del PDF: programar un tono requiere también cargar el divisor del canal. Si se incorpora el extra, mantener intacto el canal 0 que alimenta los tics BIOS y apagar/restaurar el altavoz al terminar.

La [estructura del EXE DOS](https://helppc.netcore2k.net/table/exe-file-header) incluye el tamaño del encabezado en párrafos de 16 bytes y campos iniciales de CS:IP y SS:SP. La unidad de 512 bytes corresponde a otros campos de longitud; no implica que todos los encabezados midan exactamente 512 bytes. Esta referencia respalda la observación de la sección 14.

HelpPC es una referencia histórica útil, pero algunos textos contienen simplificaciones o erratas. En particular, no trasladar la mención genérica a ZF en la página REP al comportamiento de `REP MOVSW`: ese caso se controla mediante CX. Contrastar la instrucción concreta, la CPU objetivo y los requisitos del proyecto antes de reutilizar un ejemplo.
