"""Renderiza propuestas exactas de color desde los indices VGA, sin aplicar temas.

La paleta del juego y sus INC no se modifican. Cada JSON guarda una propuesta
DAC lista para revisar; las capturas provienen de build.ps1 -Test.
"""
import copy
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

from convertir_asset import ROOT

PROPUESTAS = (
    ("01_chocolate_oscuro", "1. Chocolate oscuro", "Profundo, calido y con texto crema",
     {1: (7, 4, 3), 2: (14, 8, 5), 3: (29, 18, 11), 7: (54, 46, 36), 15: (63, 60, 53)}),
    ("02_caramelo_tostado", "2. Caramelo tostado", "Mas luminoso, con matices dorados",
     {1: (15, 8, 4), 2: (24, 13, 6), 3: (39, 24, 11), 7: (57, 49, 37), 15: (63, 61, 54)}),
    ("03_capuchino", "3. Capuchino", "Cafe suave, neutro y menos saturado",
     {1: (14, 11, 9), 2: (22, 18, 15), 3: (35, 28, 21), 7: (56, 49, 41), 15: (63, 61, 56)}),
)


def fuente(tamano):
    try:
        return ImageFont.truetype(r"C:\Windows\Fonts\segoeui.ttf", tamano)
    except OSError:
        return ImageFont.load_default()


def paleta_rgb(documento):
    return [tuple(round(v * 255 / 63) for v in c["rgb"]) for c in documento["colores"]]


def renderizar(datos, colores):
    imagen = Image.frombytes("P", (320, 200), datos)
    imagen.putpalette([v for color in colores for v in color])
    return imagen.convert("RGB").resize((640, 400), Image.Resampling.NEAREST)


def main():
    original = json.loads((ROOT / "sprites" / "paleta.json").read_text(encoding="utf-8"))
    carpeta = ROOT / "tmp" / "dosbuild"
    pantallas = {n: (carpeta / f"{n}.RAW").read_bytes() for n in ("FULLHARD", "CREDITS")}
    if any(len(datos) != 64000 for datos in pantallas.values()):
        raise ValueError("Primero ejecutar build.ps1 -Test para capturas completas.")
    salida = ROOT / "docs" / "propuestas_color"
    salida.mkdir(exist_ok=True)
    fondo = (250, 244, 233)
    tinta = (62, 39, 25)
    comparacion = Image.new("RGB", (2048, 600), fondo)
    dibujo = ImageDraw.Draw(comparacion)
    dibujo.text((32, 16), "CLAVE DULCE | Propuestas de color", fill=tinta, font=fuente(30))
    dibujo.text((32, 56), "Vistas calculadas con la paleta VGA de cada propuesta; pendientes de eleccion.",
                fill=tinta, font=fuente(20))
    for i, (archivo, titulo, descripcion, cambios) in enumerate(PROPUESTAS):
        candidato = copy.deepcopy(original)
        candidato["nombre"] = titulo
        for indice, rgb_dac in cambios.items():
            candidato["colores"][indice]["rgb"] = list(rgb_dac)
        colores = paleta_rgb(candidato)
        x = 32 + i * 672
        dibujo.text((x, 100), titulo, fill=tinta, font=fuente(28))
        comparacion.paste(renderizar(pantallas["FULLHARD"], colores), (x, 144))
        dibujo.text((x, 557), descripcion, fill=tinta, font=fuente(20))
        detalle = Image.new("RGB", (1328, 576), fondo)
        texto = ImageDraw.Draw(detalle)
        texto.text((24, 14), titulo, fill=tinta, font=fuente(30))
        texto.text((24, 57), "Tablero", fill=tinta, font=fuente(20))
        texto.text((688, 57), "Creditos con nombres actualizados", fill=tinta, font=fuente(20))
        detalle.paste(renderizar(pantallas["FULLHARD"], colores), (24, 88))
        detalle.paste(renderizar(pantallas["CREDITS"], colores), (688, 88))
        for j, (indice, nombre) in enumerate(((1, "Fondo"), (2, "Panel"), (3, "Borde"),
                                             (7, "Texto suave"), (15, "Texto principal"))):
            sx = 24 + j * 256
            texto.rectangle((sx, 511, sx + 44, 551), fill=colores[indice], outline=tinta)
            texto.text((sx + 54, 514), nombre, fill=tinta, font=fuente(18))
        detalle.save(salida / f"{archivo}.png")
        (salida / f"{archivo}.json").write_text(
            json.dumps(candidato, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    comparacion.save(salida / "comparacion.png")
    print(f"Tres propuestas y sus vistas de tablero/creditos: {salida}")
    print("La paleta activa y los sprites del ejecutable no se modificaron.")


if __name__ == "__main__":
    main()
