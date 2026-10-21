# Pruebas y estado del avance

Verificación realizada el 20 de octubre de 2026 UTC con DOSBox 0.74-3, Turbo Assembler 3.2 y Turbo Link 3.01 ya instalados en el equipo. El archivo `bin/BUILD.LOG` conserva el resultado del ensamblado de cada módulo. `bin/TESTS.TXT` conserva el resultado del ejecutable DOS, no de una reimplementación en Python.

## Cómo reproducir

Desde la raíz:

```powershell
.\build.ps1 -Test
```

Resultado verificado del conjunto actual:

```text
Pruebas del ASM real: evaluador, turnos, teclado y PRNG.
Comprobaciones: 11313 Fallos: 0
PASS: todas las comprobaciones superadas.
```

Los siete módulos ensamblaron sin errores ni advertencias y TLINK completó el enlace. Se revisó el mapa de segmentos y el tamaño de los procedimientos: hay 45 procedimientos; ninguno supera 200 líneas, contando desde PROC hasta ENDP.

## Cobertura

| Área | Comprobación | Resultado |
| --- | --- | --- |
| Evaluador | Cuatro casos obligatorios y cuatro adicionales, incluyendo N=5. | Correcto. |
| Entrada incompleta | Confirmar con huecos no incrementa `usados` y muestra aviso. | Correcto. |
| Edición | Asignar, mover, borrar y rechazar una ficha fuera del rango del nivel. | Correcto en el procesador de teclas. |
| Secreto manual | Entrada con repetidos en configuración Fácil, sin consumir turno. | Correcto. |
| Historial | Conserva la propuesta evaluada y vacía la siguiente. | Correcto. |
| Último intento | Acierto produce victoria; fallo produce derrota; conserva el conteo final. | Correcto. |
| Reinicio | Limpia propuesta, resultados e historial; retorna a partida. | Correcto. |
| Generador | 512 secretos por nivel, 1.536 comprobados: rango, unicidad de Fácil y diferencia con el anterior. | Correcto. |
| Sprite | Píxel transparente conserva fondo; píxeles opacos se escriben en offsets esperados. | Correcto, incluyendo offset 63.999. |
| Límites | Un sprite que rebasa el borde derecho se rechaza con CF. | Correcto. |
| Pantallas | Presentación, menú, secreto, partida, victoria, derrota, dificultad, instrucciones y créditos. | Rutas de estado y dibujo ejecutadas en VGA. |
| Salida gráfica | Después de las pruebas, INT 10h informa el modo original. | Correcto. |
| Conversión PNG | Alfa, colores exactos, orden por filas, negro opaco y equivalencia INC/TXT. | Dos pruebas Python superadas. |

### Casos del evaluador

La equivalencia utilizada es R=1, V=2, A=3, M=4, N=5 y B=6 en el teclado. Internamente se resta uno.

| Secreto | Propuesta | Toros | Vacas |
| --- | --- | ---: | ---: |
| RVAM | RAVM | 2 | 2 |
| RRVA | RVRR | 1 | 2 |
| RVAM | NBNB | 0 | 0 |
| AAAA | AARR | 2 | 0 |
| RVAM | RVAM | 4 | 0 |
| RVAM | VAMR | 0 | 4 |
| RRVVA | VVRRA | 1 | 4 |
| RRRR | VVVV | 0 | 0 |

El conjunto no agota todas las combinaciones posibles del juego. Comprueba los casos de aceptación y situaciones concretas de límites y repetidos.

## Revisión visual realizada

El modo `/T` usa las rutinas gráficas reales, presenta el framebuffer en A000h y guarda seis capturas de 64.000 bytes en `tmp/dosbuild`: presentación, menú, partida, Difícil, victoria y derrota. Esas capturas se convirtieron temporalmente a imágenes con la misma paleta para inspeccionar el contenido. Se corrigió la superposición del encabezado de resultado y se comprobó la visibilidad simultánea de los 12 intentos de Fácil.

Las capturas son diagnósticos de desarrollo, no assets del juego ni evidencia de aprobación por el docente. La navegación automatizada llama al mismo procesador de teclas con códigos BIOS; no equivale a verificar físicamente todas las teclas en una sesión interactiva. El acceso al control de ventanas no estuvo disponible en esta sesión. Queda pendiente la revisión manual en DOSBox, especialmente animación percibida, teclado numérico, cambios rápidos y posibles desgarros de imagen.

## Revisión manual recomendada antes de integrar assets

1. Ejecutar `run.ps1`, pasar de la presentación al menú y recorrer sus cinco opciones.
2. Probar Fácil, Normal y Difícil: N, C y turnos deben ser 4/6/12, 4/6/10 y 5/8/10.
3. En F2 introducir cada secreto obligatorio y comprobar el resultado correspondiente.
4. Confirmar una propuesta incompleta y verificar que no se consuma el intento.
5. Dejar el juego esperando: el cuadro de la ficha debe seguir cambiando sin presionar teclas.
6. Ganar, reiniciar, perder y volver al menú; salir y comprobar el retorno a DOS.

## Pruebas de las herramientas

```powershell
python -m unittest discover -s herramientas -p test_conversion.py
```

Puede usarse el intérprete alternativo del README. La prueba crea sus archivos temporales bajo `tmp` del proyecto y los elimina al terminar. El ejecutable del juego no depende de Python.

## Requisitos todavía parciales

| Requisito | Estado real |
| --- | --- |
| RF-01/RF-03 | Presentación y ayuda existentes; nombres, temática y explicación gráfica final pendientes. |
| RF-09 y maqueta | Todos los intentos visibles mediante números; diseño con sprites y conflicto de las 12 filas pendientes. |
| RG-04/RG-05 y RF-12 | Dibujante y cuadros de prueba funcionan; deben sustituirse por diseños originales definitivos y revisar que las animaciones finales sean claras. |
| RG-07 | Las 16 entradas se programan por puertos; la paleta definitiva aún puede cambiar. |
| RG-08 | Composición en framebuffer implementada; percepción de fluidez y desgarro pendiente en el entorno final. |
| E4/E5/E6 | Guías de desarrollo y primer registro disponibles; informe final, hoja de sprites y bitácora semanal completa pendientes. |
| Entorno final | Falta confirmar configuración de DOSBox del curso y hacer una reconstrucción de la entrega definitiva. |

No se interpreta que este avance cumpla por completo la rúbrica final. La próxima verificación debe repetirse después de integrar los recursos reales, porque cambiarán datos, tamaños y presentación.
