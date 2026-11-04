"""Convierte las capturas del ASM en PNG/GIF para revisar pantallas y cuadros.

Ejecutar despues de build.ps1 -Test. Es una herramienta de revision, no del juego.
"""
from PIL import Image, ImageDraw
from convertir_asset import ROOT, leer_paleta


def main():
    paleta = [v for rgb in leer_paleta(ROOT / "sprites" / "paleta.json") for v in rgb]
    carpeta = ROOT / "tmp" / "dosbuild"
    salida = ROOT / "tmp" / "revision"
    salida.mkdir(exist_ok=True)
    nombres = ["SPLASH", "SPLASHB", "MENU", "SECRET", "HELP", "GAME", "WIN", "WINB",
               "LOSE", "LOSEB", "NORMAL", "HARD", "HARDB", "FULLHARD", "LEVEL", "CREDITS"]
    imagenes = {}
    for nombre in nombres:
        datos = (carpeta / f"{nombre}.RAW").read_bytes()
        if len(datos) != 64000:
            raise ValueError(f"{nombre}: captura incompleta")
        im = Image.frombytes("P", (320, 200), datos)
        im.putpalette(paleta)
        imagenes[nombre] = im.convert("RGB")
        imagenes[nombre].resize((960, 600), Image.Resampling.NEAREST).save(salida / f"{nombre}.png")
    pantallas = ["SPLASH", "MENU", "SECRET", "HELP", "GAME", "LOSE", "NORMAL", "FULLHARD"]
    resumen = Image.new("RGB", (1280, 4 * 428), tuple(paleta[3:6]))
    dibujante = ImageDraw.Draw(resumen)
    for i, nombre in enumerate(pantallas):
        x, y = (i % 2) * 640, (i // 2) * 428
        dibujante.text((x + 8, y + 5), nombre, fill="white")
        resumen.paste(imagenes[nombre].resize((640, 400), Image.Resampling.NEAREST), (x, y + 24))
    resumen.save(salida / "pantallas.png")
    for nombre in ("SPLASH", "WIN", "LOSE", "HARD"):
        cuadros = [imagenes[n].resize((640, 400), Image.Resampling.NEAREST)
                   for n in (nombre, nombre + "B")]
        cuadros[0].save(salida / f"{nombre}.gif", save_all=True, append_images=cuadros[1:],
                        duration=165, loop=0, disposal=2)
    print(f"{len(nombres)} capturas y 4 animaciones de revision: {salida}")


if __name__ == "__main__":
    main()
