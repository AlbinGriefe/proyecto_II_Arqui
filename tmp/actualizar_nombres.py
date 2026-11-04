from pathlib import Path
p = Path('docs/AVANCE_GRAFICO.md')
s = p.read_text(encoding='utf-8')
s = s.replace('Los nombres de integrantes siguen pendientes en `txtTeam`, dentro de `src/data.asm`; no se inventaron datos.', 'Los créditos y la presentación incluyen Arwee Granados y Albin Greife, según los nombres confirmados por el usuario. Se definen en `txtTeam`, dentro de `src/data.asm`.')
p.write_text(s, encoding='utf-8')
