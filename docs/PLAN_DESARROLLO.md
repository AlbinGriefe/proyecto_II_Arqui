# Plan de desarrollo

La referencia normativa de trabajo es `MEMORIA_PROYECTO_II.md`, contrastada previamente con el PDF. Este plan distingue lo programado en el primer avance de lo que requiere diseño, integración o acuerdo con el docente. No asigna fechas inventadas ni registra como aprobadas decisiones pendientes.

## Fases y aceptación

| Fase | Trabajo y razón | Criterio de salida | Estado |
| --- | --- | --- | --- |
| 1. Entorno y módulos | Construir los siete ASM con TASM/TLINK y ejecutarlos en DOSBox. Permite detectar incompatibilidades antes de trabajar en los assets. | EXE reproducible, cero errores/advertencias, salida DOS correcta. | Implementada y probada. |
| 2. Núcleo gráfico | Modo 13h, paleta propia, fuente ROM, sprite transparente, framebuffer y reloj BIOS. Proporciona una base reutilizable para todas las pantallas. | Dibujo correcto dentro de límites, transparencia, restauración del modo y regiones A/B/C/D. | Implementada y probada; estética provisional. |
| 3. Juego base | Configuración de niveles, secreto, editor, evaluación, historial, turnos y resultado. Se valida con recursos simples para aislar errores de lógica. | Cuatro casos del PDF, intento incompleto sin consumo, victoria/derrota y reinicio. | Implementada y probada. |
| 4. Diseño original | Elegir temática y nombre; dibujar ocho fichas distintas por forma; mascota y secuencias de resultado. | PNG originales con tamaños y cuadros acordados, paleta compartida y hoja de sprites. | Ocho dulces integrados, selección animada y personajes temáticos de dos cuadros implementados. |
| 5. Integración gráfica | Convertir los PNG, integrar cuadros, añadir apoyo gráfico a instrucciones y resultados, revisar legibilidad e historial. | Todos los elementos se distinguen y mantienen los límites de memoria; tres animaciones completas. | Ayuda gráfica, animaciones, historial con sprites y revelación del secreto implementados y verificados. Validación del acomodo de Fácil pendiente con el docente. |
| 6. Revisión del enunciado | Resolver el acomodo de 12 intentos y la regla de propuestas repetidas en Fácil; comprobar configuración del curso. | Decisiones confirmadas y trazabilidad RF/RG/RT actualizada. | Pendiente de confirmaciones externas. |
| 7. Cierre y defensa | Revisión funcional completa, documento técnico de 8–12 páginas, bitácora semanal, hoja de sprites y entrega limpia. | Copia reconstruida desde cero; cada integrante explica y modifica sus rutinas. | Pendiente. |
| 8. Extras | Cronómetro, sonido, puntajes u otras funciones solo después de cerrar lo obligatorio. | Pruebas específicas y criterio de asignación de puntos confirmado. | Fuera de este primer avance. |

La integración de los primeros ocho dulces ya está realizada. La próxima dependencia gráfica es recibir cuadros de animación y recursos temáticos de mascota y resultados; también siguen pendientes la ayuda gráfica y la resolución del historial. Se puede continuar revisando la lógica y completar los nombres de integrantes en `src/data.asm`.

## Organización del código

Se adoptó una construcción de **varios objetos**, atendiendo la preferencia de separar archivos ASM. Cada módulo se ensambla por separado y el enlazador resuelve las llamadas externas. La memoria proponía comenzar con una unidad y varios includes; esa era una propuesta de implementación, no una restricción del PDF. Este avance sustituye esa propuesta con un script que sí construye todos los módulos.

Cada fase mantiene un contrato: el juego entrega identificadores y resultados; la interfaz decide sus coordenadas y sprites; video escribe los píxeles; entrada consulta BIOS. Así, integrar los PNG no exige reescribir el algoritmo de toros y vacas.

## Decisiones provisionales

**Historial:** se conservan los 12 intentos de Fácil visibles con filas de 13 píxeles y números de ficha. Las otras dificultades usan la misma presentación compacta. Se respetan las zonas de pantalla, pero queda pendiente la representación gráfica definitiva del historial y su compatibilidad con la maqueta. No se ocultan filas ni se reducen los intentos para forzar el acomodo.

**Repetidos en Fácil:** el secreto aleatorio nunca repite fichas. El editor permite propuestas repetidas, porque la memoria identifica que el enunciado no aclara por separado esa validación. La decisión está aislada en `ValidarIntento`; puede modificarse cuando exista una indicación del docente. El editor del secreto de prueba siempre debe admitir repetidos.

**Recursos:** se incorporan como tablas de bytes `.inc`. El TXT exportado sirve para revisión y para una posible carga futura. Un cargador externo necesita su propio formato, lector, validaciones y manejo de errores; no se considera implementado.

**Documentación:** los documentos de desarrollo están en `docs`. No reemplazan todavía el informe técnico final de 8–12 páginas ni la bitácora de todas las semanas.

## Riesgos de integración que sí afectan el siguiente paso

| Situación | Resolución prevista |
| --- | --- |
| PNG de cada ficha con una paleta automática diferente | Convertir todos contra la misma `sprites/paleta.json`. |
| Assets con cuadros o tamaños diferentes a los actuales | Ajustar la tabla de punteros y metadatos de la interfaz; evitar offsets dispersos. |
| Demasiados recursos en DGROUP | Presupuestar bytes y mover las tablas a otro segmento si se acercan a 64 KiB. |
| Nueva animación deja restos de píxeles transparentes | Restaurar la región de fondo antes del cuadro siguiente. |
| Fuente o texto no cabe en 320×200 | Ajustar longitud, coordenadas o introducir una fuente propia más pequeña. |

La evaluación de la siguiente fase debe hacerse con los recursos reales. La aprobación de los marcadores temporales no demuestra el cumplimiento de originalidad y temática de los assets finales.

## Avance de integración

El 2 de noviembre de 2026 (fecha local) se integraron los dulces entregados y se verificaron las tablas, los colores y las capturas del ASM real. Se conservan seis tipos en Fácil/Normal y ocho en Difícil; los cuatro adicionales quedan convertidos como alternativas. Véase [INTEGRACION_DULCES.md](INTEGRACION_DULCES.md).

## Cierre funcional y gráfico

Se completaron las animaciones de selección, mascota y resultados; la ayuda visual; el historial con todos los intentos en sprites; y la revelación gráfica del secreto. La verificación vigente y las decisiones externas están en [AVANCE_GRAFICO.md](AVANCE_GRAFICO.md). Por indicación del usuario, el informe de entrega y la preparación de defensa se dejan para el final.
