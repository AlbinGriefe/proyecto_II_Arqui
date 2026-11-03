from pathlib import Path
p = Path('docs/README.md')
s = p.read_text(encoding='utf-8')
indice = s.index('## Iniciar desde PowerShell')
s = s[:indice] + ('El avance gráfico posterior incorpora animaciones, historial con sprites y ayuda visual. '
                  'El estado vigente y la revisión realizada están en [AVANCE_GRAFICO.md](AVANCE_GRAFICO.md).\n\n') + s[indice:]
s = s.replace('El historial compacto muestra **identificadores numéricos** de fichas, con T y V para la retroalimentación. Los sprites de 16×16 se usan en el catálogo y en la propuesta. Este acomodo es provisional: no equivale a tener aprobada una modificación de la maqueta del docente.',
              'El historial muestra sprites de 16×16: dos columnas de seis intentos en Fácil y diez filas en Normal/Difícil, con T y V para la retroalimentación. El acomodo de Fácil adapta la maqueta y debe validarse con el docente.')
s = s.replace('Faltan los cuadros de animación propios de cada dulce, la mascota y los resultados temáticos, los nombres de integrantes y la ayuda gráfica.',
              'La selección, la mascota y los resultados ya tienen cuadros distintos, y la ayuda incluye un ejemplo gráfico. Faltan los nombres de integrantes y el cierre documental.')
s = s.replace('La guía gráfica dentro del programa todavía debe completarse con los assets. ', '')
p.write_text(s, encoding='utf-8')

p = Path('docs/PLAN_DESARROLLO.md')
s = p.read_text(encoding='utf-8')
s = s.replace('Recibidos y validados doce dulces estáticos; ocho integrados. Mascota y cuadros animados pendientes.',
              'Ocho dulces integrados, selección animada y personajes temáticos de dos cuadros implementados.')
s = s.replace('Dulces convertidos, paleta VGA256 y catálogo/propuesta verificados. Ayuda, animaciones temáticas e historial pendientes.',
              'Ayuda gráfica, animaciones, historial con sprites y revelación del secreto implementados y verificados. Validación del acomodo de Fácil pendiente con el docente.')
s += ('\n## Cierre funcional y gráfico\n\n'
      'Se completaron las animaciones de selección, mascota y resultados; la ayuda visual; '
      'el historial con todos los intentos en sprites; y la revelación gráfica del secreto. '
      'La verificación vigente y las decisiones externas están en [AVANCE_GRAFICO.md](AVANCE_GRAFICO.md). '
      'Por indicación del usuario, el informe de entrega y la preparación de defensa se dejan para el final.\n')
p.write_text(s, encoding='utf-8')

p = Path('docs/PRUEBAS_Y_ESTADO.md')
s = p.read_text(encoding='utf-8')
indice = s.index('\n\n')
s = s[:indice] + ('\n\n**Estado vigente:** 12.153 comprobaciones ASM y siete pruebas Python superadas. '
                  'La revisión posterior de animaciones, historial y teclado BIOS está en '
                  '[AVANCE_GRAFICO.md](AVANCE_GRAFICO.md). Las secciones inferiores conservan también '
                  'la evidencia histórica de los avances anteriores.') + s[indice:]
p.write_text(s, encoding='utf-8')

# Los documentos anteriores describen la primera integración estática, no el cierre actual.
for nombre in ('ASSETS_Y_PALETA.md','INTEGRACION_DULCES.md'):
 p = Path('docs') / nombre
 s = p.read_text(encoding='utf-8-sig')
 indice = s.index('\n\n')
 nota = ('\n\n**Actualización:** ya se añadieron selección animada, confitero, resultados temáticos, '
         'ayuda e historial con sprites. Véase [AVANCE_GRAFICO.md](AVANCE_GRAFICO.md). '
         'La descripción de cuadros estáticos que sigue corresponde a la primera integración; '
         'el integrador actual genera dos cuadros diferentes por ficha y `sprites/hoja_animaciones.png`.')
 p.write_text(s[:indice] + nota + s[indice:], encoding='utf-8')

procedimientos=[]
import re
for p in Path('src').glob('*.asm'):
 inicio=None
 for numero,linea in enumerate(p.read_text(encoding='ascii').splitlines(),1):
  if re.search(r'\bPROC\b',linea) and not linea.lstrip().startswith(';'): inicio=numero
  if inicio and re.search(r'\bENDP\b',linea): procedimientos.append((p.name,inicio,numero-inicio+1)); inicio=None
assert all(p[2]<=200 for p in procedimientos), procedimientos
print('Procedimientos:',len(procedimientos),'máximo:',max(p[2] for p in procedimientos),'líneas.')
print('Notas operativas actualizadas; informe final y defensa aplazados.')
