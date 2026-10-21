"""PNG original -> indices de paleta fija -> tabla .inc y TXT opcional.

La conversion es una herramienta de construccion. El juego ejecuta solo ASM.
Requiere Pillow: python -m pip install -r herramientas/requirements.txt
"""
import argparse
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def leer_paleta(ruta):
    documento = json.loads(Path(ruta).read_text(encoding="utf-8"))
    colores = documento["colores"]
    if [c["indice"] for c in colores] != list(range(len(colores))):
        raise ValueError("Los indices de la paleta deben ser consecutivos desde 0.")
    if documento.get("rango_dac") != 63 or not 2 <= len(colores) <= 256:
        raise ValueError("Se requiere rango_dac=63 y entre 2 y 256 entradas.")
    if any(len(c["rgb"]) != 3 or any(type(v) is not int or not 0 <= v <= 63 for v in c["rgb"]) for c in colores):
        raise ValueError("Cada entrada debe tener tres enteros RGB entre 0 y 63.")
    # Comparar el PNG con la representacion 0..255 de los colores DAC reales.
    return [tuple(round(v * 255 / 63) for v in c["rgb"]) for c in colores]


def convertir(imagen, paleta, umbral=128):
    """Mapea alfa bajo a 0; los pixeles opacos solo usan indices 1..255."""
    if not 0 <= umbral <= 255:
        raise ValueError("El umbral de alfa debe estar entre 0 y 255.")
    cache = {}
    salida = []
    rgba = imagen.convert("RGBA")
    pixeles = rgba.load()
    for x, y in ((x, y) for y in range(rgba.height) for x in range(rgba.width)):
        r, g, b, a = pixeles[x, y]
        if a < umbral:
            salida.append(0)
            continue
        rgb = (r, g, b)
        if rgb not in cache:
            cache[rgb] = min(range(1, len(paleta)), key=lambda i: sum((rgb[j] - paleta[i][j]) ** 2 for j in range(3)))
        salida.append(cache[rgb])
    return salida


def escribir_inc(ruta, nombre, ancho, alto, indices):
    if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]{0,30}", nombre):
        raise ValueError("La etiqueta ASM debe usar letras, numeros o _ y comenzar con letra/_ (maximo 31).")
    if len(indices) != ancho * alto:
        raise ValueError("La cantidad de pixeles no coincide con las dimensiones.")
    lineas = [f"; {ancho}x{alto}; por filas; indice 0 transparente.", f"{nombre} LABEL BYTE"]
    for inicio in range(0, len(indices), 16):
        lineas.append("    db " + ",".join(f"{valor:03X}h" for valor in indices[inicio:inicio + 16]))
    Path(ruta).parent.mkdir(parents=True, exist_ok=True)
    Path(ruta).write_text("\n".join(lineas) + "\n", encoding="ascii")


def escribir_txt(ruta, ancho, alto, indices):
    lineas = [f"VGA8 {ancho} {alto}"]
    for y in range(alto):
        lineas.append(" ".join(f"{v:02X}" for v in indices[y * ancho:(y + 1) * ancho]))
    Path(ruta).parent.mkdir(parents=True, exist_ok=True)
    Path(ruta).write_text("\n".join(lineas) + "\n", encoding="ascii")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("entrada", type=Path)
    parser.add_argument("salida", type=Path, help="Tabla .inc de salida.")
    parser.add_argument("--paleta", type=Path, default=ROOT / "sprites" / "paleta.json")
    parser.add_argument("--nombre", default="asset")
    parser.add_argument("--txt", type=Path, help="Exportar ademas una matriz hexadecimal con cabecera VGA8.")
    parser.add_argument("--ancho", type=int)
    parser.add_argument("--alto", type=int)
    parser.add_argument("--umbral-alfa", type=int, default=128)
    args = parser.parse_args()
    if (args.ancho is None) != (args.alto is None):
        parser.error("Para redimensionar proporciona --ancho y --alto juntos.")
    from PIL import Image
    try:
        paleta = leer_paleta(args.paleta)
        with Image.open(args.entrada) as original:
            imagen = original.convert("RGBA")
        if args.ancho is not None:
            if args.ancho < 1 or args.alto < 1:
                raise ValueError("Las dimensiones deben ser positivas.")
            imagen = imagen.resize((args.ancho, args.alto), Image.Resampling.NEAREST)
        ancho, alto = imagen.size
        if ancho > 320 or alto > 200:
            raise ValueError("El sprite no cabe en una pantalla de 320x200.")
        indices = convertir(imagen, paleta, args.umbral_alfa)
        escribir_inc(args.salida, args.nombre, ancho, alto, indices)
        if args.txt:
            escribir_txt(args.txt, ancho, alto, indices)
    except (ValueError, OSError, KeyError, TypeError) as error:
        parser.error(str(error))
    print(f"{ancho}x{alto}: {len(indices)} bytes; indices usados {sorted(set(indices))}.")
    print(f"Tabla generada: {args.salida}")


if __name__ == "__main__":
    main()
