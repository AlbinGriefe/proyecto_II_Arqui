from pathlib import Path
import re
root = Path.cwd()
p = root / 'docs/README.md'
s = p.read_text(encoding='utf-8')
pos = s.index('## Iniciar desde PowerShell')
s = ('# Proyecto II — Clave Dulce\n\n'
     'Mastermind DOS de 16 bits con TASM/TLINK e interfaz VGA. El avance inicial del 20 de octubre '
     'se amplió el 2 de noviembre de 2026 (fecha local) con los sprites de dulces recibidos. '
     'El catálogo y la propuesta usan ocho fichas reales, una paleta compartida de 256 colores '
     'y transparencia. Consulta [INTEGRACION_DULCES.md](INTEGRACION_DULCES.md) para ver la selección, '
     'la conversión y sus pruebas.\n\n' + s[pos:])
s = s.replace('Se usan una paleta propia de 16 entradas, sprites de prueba con transparencia',
              'Se usan una paleta compartida de 256 entradas, ocho dulces con transparencia')
s = s.replace('Faltan los diseños definitivos, nombres de integrantes y personalización de la ayuda y resultados.',
              'Faltan los cuadros de animación propios de cada dulce, la mascota y los resultados temáticos, los nombres de integrantes y la ayuda gráfica.')
s = s.replace('| [ASSETS_Y_PALETA.md](ASSETS_Y_PALETA.md) | Reglas para crear los assets en el otro chat y convertirlos. |',
              '| [ASSETS_Y_PALETA.md](ASSETS_Y_PALETA.md) | Formatos, paleta compartida y regeneración de los assets. |\n'
              '| [INTEGRACION_DULCES.md](INTEGRACION_DULCES.md) | Fichas incorporadas, decisiones, datos y pruebas de integración. |')
s = s.replace('& $pythonProyecto herramientas\\generar_base.py', '& $pythonProyecto herramientas\\integrar_dulces.py')
s = s.replace('& $pythonProyecto -m unittest discover -s herramientas -p test_conversion.py',
              "& $pythonProyecto -m unittest discover -s herramientas -p 'test_*.py'")
start = s.index('`generar_base.py` usa únicamente')
s = s[:start] + ('`integrar_dulces.py` regenera las tablas de los dulces y sus exportaciones. '
                 '`generar_base.py` conserva la herramienta histórica de marcadores y ahora rechaza '
                 'sobrescribir las fichas integradas.\n')
p.write_text(s, encoding='utf-8')

p = root / 'docs/ARQUITECTURA_Y_LOGICA.md'
s = p.read_text(encoding='utf-8').replace(
    'La paleta se programa con OUT en 3C8h/3C9h a partir de 16 tripletas RGB 0..63.',
    'La paleta se programa con OUT en 3C8h/3C9h a partir de 256 tripletas RGB 0..63. '
    'El tamaño se calcula mediante `paletaFin-paleta`, por lo que la carga no queda limitada a las 16 entradas iniciales de interfaz.')
s = s.replace('Los sprites actuales tienen dos cuadros de 256 bytes:',
              'Las ocho fichas de dulces tienen dos cuadros de 256 bytes, actualmente idénticos porque el paquete trae una sola imagen por ficha:')
s += ('\n## Integración de los dulces\n\n'
      '`herramientas/integrar_dulces.py` valida los doce PNG, conserva los colores 0..15 de interfaz '
      'y cuantiza todos los dulces contra una paleta común. Genera los ocho tipos activos y mantiene '
      'sin cambios las etiquetas `sprites`, `mascota` y `finale`. El motor del juego sigue trabajando '
      'con IDs 0..7; no requiere cambios de reglas ni de evaluación. El título visible pasa a '
      '«Clave Dulce». La especificación y sus límites están en '
      '[INTEGRACION_DULCES.md](INTEGRACION_DULCES.md).\n')
p.write_text(s, encoding='utf-8')

procedimientos = []
for p in (root / 'src').glob('*.asm'):
    inicio = None
    for numero, linea in enumerate(p.read_text(encoding='ascii').splitlines(), 1):
        if re.search(r'\bPROC\b', linea) and not linea.lstrip().startswith(';'):
            inicio = numero
        if inicio is not None and re.search(r'\bENDP\b', linea):
            procedimientos.append((p.name, inicio, numero - inicio + 1))
            inicio = None
print('Procedimientos:', len(procedimientos), 'mayor:', max(procedimientos, key=lambda v: v[2]))
assert all(v[2] <= 200 for v in procedimientos)

p = root / 'docs/PRUEBAS_Y_ESTADO.md'
s = p.read_text(encoding='utf-8')
s = s.replace('Verificación realizada el 20 de octubre de 2026 UTC',
              'Verificación inicial del 20 de octubre; integración de dulces verificada el 2 de noviembre de 2026 (fecha local)')
s = s.replace('Comprobaciones: 11313 Fallos: 0', 'Comprobaciones: 12081 Fallos: 0')
s = s.replace('hay 45 procedimientos;', f'hay {len(procedimientos)} procedimientos;')
s = s.replace('Dos pruebas Python superadas.', 'Cinco pruebas Python superadas en el conjunto completo.')
s = s.replace('guarda seis capturas de 64.000 bytes', 'guarda siete capturas de 64.000 bytes')
s = s.replace('presentación, menú, partida, Difícil, victoria y derrota.',
              'presentación, menú, partida, Difícil A/B, victoria y derrota.')
s = s.replace('## Revisión manual recomendada antes de integrar assets',
              '## Revisión manual recomendada después de integrar assets')
s = s.replace('python -m unittest discover -s herramientas -p test_conversion.py',
              "python -m unittest discover -s herramientas -p 'test_*.py' -v")
s = s.replace('| RG-07 | Las 16 entradas se programan por puertos; la paleta definitiva aún puede cambiar. |',
              '| RG-07 | Las 256 entradas se programan por puertos y sus 768 componentes se verifican leyendo de vuelta el DAC. |')
s += ('\n## Validación específica de dulces\n\n'
      'El conjunto ASM pasa 12.081 comprobaciones con cero fallos. Se incluyen 768 comparaciones '
      'de lectura del DAC con las tripletas enlazadas en el EXE. Las cinco pruebas Python pasan '
      'sin omisiones tras `build.ps1 -Test`. Verifican fuentes idénticas al ZIP, transparencia, '
      '256 bytes por ficha, equivalencia INC/TXT, paleta y disposición de las ocho fichas.\n\n'
      'Las capturas reales `HARD.RAW` y `HARDB.RAW` se comparan contra los píxeles esperados '
      'del catálogo completo y cinco fichas de la propuesta. Esto comprueba direcciones, '
      'transparencia y selección de ambos cuadros. La captura ampliada para inspección está en '
      '[capturas/hard_dulces.png](capturas/hard_dulces.png). La lectura del DAC comprueba los '
      'colores programados; la revisión del PNG confirma presentación, pero no sustituye una '
      'sesión interactiva de teclado ni evalúa animación percibida.\n\n'
      'Las fichas recibidas son estáticas (A/B idénticos); mascota y finales siguen siendo '
      'marcadores. Esos requisitos gráficos permanecen parciales.\n')
p.write_text(s, encoding='utf-8')

p = root / 'docs/PLAN_DESARROLLO.md'
s = p.read_text(encoding='utf-8')
s = s.replace('| Pendiente de los assets del usuario. |',
              '| Recibidos y validados doce dulces estáticos; ocho integrados. Mascota y cuadros animados pendientes. |')
s = s.replace('| Conversor preparado; integración pendiente. |',
              '| Dulces convertidos, paleta VGA256 y catálogo/propuesta verificados. Ayuda, animaciones temáticas e historial pendientes. |')
s = s.replace('La próxima dependencia concreta es la fase 4. Mientras llegan los assets se puede estudiar y revisar la lógica del núcleo, ejecutar el modo manual y completar los nombres de los integrantes en `src/data.asm`.',
              'La integración de los primeros ocho dulces ya está realizada. La próxima dependencia gráfica es recibir cuadros de animación y recursos temáticos de mascota y resultados; también siguen pendientes la ayuda gráfica y la resolución del historial. Se puede continuar revisando la lógica y completar los nombres de integrantes en `src/data.asm`.')
s += ('\n## Avance de integración\n\n'
      'El 2 de noviembre de 2026 (fecha local) se integraron los dulces entregados y se verificaron '
      'las tablas, los colores y las capturas del ASM real. Se conservan seis tipos en Fácil/Normal '
      'y ocho en Difícil; los cuatro adicionales quedan convertidos como alternativas. Véase '
      '[INTEGRACION_DULCES.md](INTEGRACION_DULCES.md).\n')
p.write_text(s, encoding='utf-8')

p = root / 'docs/BITACORA.md'
s = p.read_text(encoding='utf-8')
s += ('\n## Integración de dulces — 2 de noviembre de 2026 (fecha local)\n\n'
      'Se recibió el ZIP con doce sprites de 16×16 y transparencia binaria. Se conservaron '
      'los originales y se convirtieron todos contra una paleta global de 256 entradas, '
      'manteniendo los 16 colores de interfaz. Se integraron los ocho primeros en catálogo '
      'y propuesta, con dos copias del cuadro estático por tipo para mantener el contrato '
      'de direcciones. Los cuatro restantes quedan disponibles en INC/TXT.\n\n'
      'Se añadió `integrar_dulces.py`, una guarda contra sobrescritura de marcadores, '
      'carga dinámica del tamaño de paleta y verificación de sus componentes en el DAC. '
      'Se comprobó la identidad de los PNG y se compararon capturas del ASM píxel por píxel. '
      'Resultado: 12.081 comprobaciones ASM y cinco pruebas Python superadas; ensamblado '
      'sin errores ni advertencias. La captura y las decisiones están en la documentación.\n\n'
      'Pendientes: cuadros animados propios, mascota/finales temáticos, ayuda gráfica e historial. '
      'No se atribuyen aportes individuales sin datos de los integrantes.\n')
p.write_text(s, encoding='utf-8')
