from pathlib import Path
import sys, json, re, hashlib, math
sys.path.insert(0, str(Path('herramientas').resolve()))
from generar_base import tabla
from convertir_asset import leer_paleta
from integrar_dulces import imagen_indexada, ARCHIVOS, pixeles
from PIL import Image

root = Path.cwd()
ruta = root / 'sprites/paleta.json'
antes = json.loads(ruta.read_text(encoding='utf-8'))
elegida = json.loads((root / 'docs/propuestas_color/01_chocolate_oscuro.json').read_text(encoding='utf-8'))
cambios = [i for i,(a,b) in enumerate(zip(antes['colores'],elegida['colores'])) if a != b]
assert cambios == [1,2,3,7,15], cambios
assert len(elegida['colores']) == len(antes['colores']) == 256
ruta.write_text(json.dumps(elegida, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
rgb = leer_paleta(ruta)
componentes = [v for c in elegida['colores'] for v in c['rgb']]
(root/'src/palette.inc').write_text(tabla('paleta',componentes)+'\npaletaFin LABEL BYTE\n',encoding='ascii')

# Actualizar vistas derivadas con los mismos indices que usa el EXE.
def leer_indices(ruta):
 return [int(v,16) for linea in ruta.read_text(encoding='ascii').splitlines()
         if linea.strip().startswith('db ') for v in re.findall(r'([0-9A-F]+)h',linea)]

hoja = Image.new('RGBA',(64,48))
informe = json.loads((root/'sprites/dulces.json').read_text(encoding='utf-8'))
for i,nombre in enumerate(ARCHIVOS):
 indices=leer_indices(root/'sprites/convertidos'/nombre.replace('.png','.inc'))
 hoja.paste(imagen_indexada(indices,rgb),((i%4)*16,(i//4)*16))
 with Image.open(root/'sprites/png_16x16'/nombre) as original:
  datos=list(pixeles(original.convert('RGBA')))
 opacos=[(p[:3],rgb[indice]) for p,indice in zip(datos,indices) if p[3]==255]
 informe['sprites'][i]['error_rgb_rms']=round(math.sqrt(sum((a[c]-b[c])**2 for a,b in opacos for c in range(3))/(3*len(opacos))),3)
hoja.save(root/'sprites/hoja_dulces_vga.png')
(root/'sprites/dulces.json').write_text(json.dumps(informe,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
frames=leer_indices(root/'src/sprites.inc')
animadas=Image.new('RGBA',(128,48))
for i,inicio in enumerate(range(0,len(frames),256)):
 animadas.paste(imagen_indexada(frames[inicio:inicio+256],rgb),((i%8)*16,(i//8)*16))
animadas.save(root/'sprites/hoja_animaciones.png')
print('Chocolate oscuro aplicado: fondo, paneles, bordes y textos.')
print('Paleta: 256 colores; sprites: mismas tablas y transparencias.')
print('Error RGB maximo de los dulces:',max(s['error_rgb_rms'] for s in informe['sprites']))
