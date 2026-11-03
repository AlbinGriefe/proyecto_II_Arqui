"""Integra los 12 PNG de dulces; las primeras ocho fichas se enlazan en el EXE.

Uso: python herramientas/integrar_dulces.py [directorio_png_o_zip]
Conserva los 16 colores de interfaz y reserva hasta 240 colores para los dulces.
Los originales nunca se redimensionan ni se modifican.
"""
import argparse
import hashlib
import io
import json
import math
import zipfile
from pathlib import Path

from PIL import Image

from convertir_asset import ROOT, convertir, escribir_inc, escribir_txt, leer_paleta
from generar_base import tabla
from animaciones import cuadro_seleccion, crear_personajes

NOMBRES = (
    "bollo_glaseado", "cupcake_crema", "waffle", "dona_glaseada",
    "pretzel", "tarta_frutos_rojos", "rebanada_pastel", "muffin_chocolate",
    "pudin_caramelo", "rosquilla_crema", "dulce_redondo", "rollo_canela",
)
ARCHIVOS = tuple(f"{i:02}_{nombre}.png" for i, nombre in enumerate(NOMBRES, 1))


def pixeles(imagen):
    # Compatibilidad con Pillow 10..12 y con el runtime que ya incluye la API nueva.
    if hasattr(imagen, "get_flattened_data"):
        return imagen.get_flattened_data()
    return list(imagen.getdata())


def leer_fuentes(entrada):
    """Lee solo los doce nombres conocidos, sin extraer rutas arbitrarias del ZIP."""
    imagenes, originales = [], []
    if entrada.is_dir():
        originales = [(entrada / nombre).read_bytes() for nombre in ARCHIVOS]
    else:
        with zipfile.ZipFile(entrada) as paquete:
            originales = [paquete.read(f"png_16x16/{nombre}") for nombre in ARCHIVOS]
    for nombre, contenido in zip(ARCHIVOS, originales):
        with Image.open(io.BytesIO(contenido)) as fuente:
            imagen = fuente.convert("RGBA")
        if imagen.size != (16, 16):
            raise ValueError(f"{nombre}: se esperaba 16x16, se recibio {imagen.size}.")
        alfa = list(imagen.getchannel("A").tobytes())
        if set(alfa) != {0, 255}:
            raise ValueError(f"{nombre}: se requiere contenido visible y alfa binario 0/255.")
        imagenes.append(imagen)
    return imagenes, originales


def crear_paleta(imagenes, colores_ui):
    """Cuantiza el conjunto completo y adapta los tonos al DAC real de seis bits."""
    muestras = [tuple(round(v * 63 / 255) for v in rgb[:3])
                for im in imagenes for rgb in pixeles(im) if rgb[3] == 255]
    muestra = Image.new("RGB", (len(muestras), 1))
    muestra.putdata(muestras)
    # Trabajar en DAC evita gastar entradas en tonos que el hardware igualaria.
    # MAXCOVERAGE conserva tambien los verdes/rojos poco frecuentes de la tarta.
    cuantizada = muestra.quantize(colors=240, method=Image.Quantize.MAXCOVERAGE,
                                 dither=Image.Dither.NONE)
    rgb = cuantizada.getpalette()
    colores = [dict(c, rgb=list(c["rgb"])) for c in colores_ui]
    usados = {tuple(c["rgb"]) for c in colores}
    for i in sorted(set(cuantizada.tobytes())):
        dac = tuple(rgb[3 * i:3 * i + 3])
        if dac in usados:
            continue
        indice = len(colores)
        colores.append({"indice": indice, "nombre": f"Dulces {indice}", "rgb": list(dac)})
        usados.add(dac)
    return {"nombre": "Paleta compartida VGA: interfaz y dulces", "rango_dac": 63,
            "colores": colores}


def imagen_indexada(indices, paleta):
    imagen = Image.new("RGBA", (16, 16))
    imagen.putdata([(*paleta[i], 255) if i else (0, 0, 0, 0) for i in indices])
    return imagen


def integrar(entrada):
    imagenes, originales = leer_fuentes(entrada)
    ruta_paleta = ROOT / "sprites" / "paleta.json"
    documento = json.loads(ruta_paleta.read_text(encoding="utf-8"))
    leer_paleta(ruta_paleta)  # Validar antes de producir archivos.
    colores_ui = documento["colores"][:16]
    if len(colores_ui) != 16:
        raise ValueError("Deben existir las 16 entradas originales de la interfaz.")
    fuentes = ROOT / "sprites" / "png_16x16"
    for nombre, original in zip(ARCHIVOS, originales):
        destino = fuentes / nombre
        if destino.exists() and destino.read_bytes() != original:
            raise ValueError(f"Se conserva el PNG existente diferente: {destino}")
    nueva_paleta = crear_paleta(imagenes, colores_ui)
    ruta_paleta.write_text(json.dumps(nueva_paleta, ensure_ascii=False, indent=2) + "\n",
                           encoding="utf-8")
    paleta = leer_paleta(ruta_paleta)
    exportados = ROOT / "sprites" / "convertidos"
    fuentes.mkdir(exist_ok=True)
    exportados.mkdir(exist_ok=True)
    datos_fichas, informe = [], []
    cuadros = []
    hoja = Image.new("RGBA", (64, 48))
    for i, (nombre, original, imagen) in enumerate(zip(ARCHIVOS, originales, imagenes)):
        destino = fuentes / nombre
        destino.write_bytes(original)
        indices = convertir(imagen, paleta)
        escribir_inc(exportados / f"{Path(nombre).stem}.inc", f"dulce{i + 1:02}", 16, 16, indices)
        escribir_txt(exportados / f"{Path(nombre).stem}.txt", 16, 16, indices)
        hoja.paste(imagen_indexada(indices, paleta), ((i % 4) * 16, (i // 4) * 16))
        opacos = [(rgba[:3], paleta[indice]) for rgba, indice in zip(pixeles(imagen), indices)
                  if rgba[3] == 255]
        error = math.sqrt(sum((a[c] - b[c]) ** 2 for a, b in opacos for c in range(3))
                          / (3 * len(opacos)))
        informe.append({"archivo": nombre, "id_juego": i if i < 8 else None,
                        "tecla": i + 1 if i < 8 else None,
                        "sha256_original": hashlib.sha256(original).hexdigest(),
                        "pixeles_opacos": len(opacos), "colores_vga": len(set(indices) - {0}),
                        "error_rgb_rms": round(error, 3)})
        if i < 8:
            seleccionado = cuadro_seleccion(indices)
            escribir_inc(exportados / f"{Path(nombre).stem}_seleccion.inc",
                         f"dulce{i + 1:02}b", 16, 16, seleccionado)
            escribir_txt(exportados / f"{Path(nombre).stem}_seleccion.txt", 16, 16, seleccionado)
            datos_fichas.extend(indices + seleccionado)
            cuadros.extend([indices, seleccionado])
    hoja.save(ROOT / "sprites" / "hoja_dulces_vga.png")
    texto_paleta = tabla("paleta", [v for c in nueva_paleta["colores"] for v in c["rgb"]])
    (ROOT / "src" / "palette.inc").write_text(texto_paleta + "\npaletaFin LABEL BYTE\n",
                                              encoding="ascii")
    chef, finales = crear_personajes()
    tablas = ["; Generado por integrar_dulces.py. No regenerar con generar_base.py.",
              "; Fichas 1..8: A original y B de seleccion, 256 bytes por cuadro.",
              tabla("sprites", datos_fichas),
              "; Confitero, cupcake ganador y pastel quemado: dos cuadros cada uno.",
              tabla("mascota", sum(chef, [])), tabla("finale", sum(finales, []))]
    (ROOT / "src" / "sprites.inc").write_text("\n\n".join(tablas) + "\n", encoding="ascii")
    resumen = {"colores_paleta": len(paleta), "colores_ui_preservados": 16,
               "fichas_activas": 8, "cuadros_distintos_por_ficha": 2,
               "bytes_sprites_asm": 5632, "sprites": informe}
    (ROOT / "sprites" / "dulces.json").write_text(
        json.dumps(resumen, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"12 PNG validados; 8 fichas activas; paleta compartida: {len(paleta)} colores.")
    print("Generados src/sprites.inc, src/palette.inc, matrices INC/TXT y hoja VGA.")
    hoja_animada = Image.new("RGBA", (128, 48))
    for i, datos in enumerate(cuadros + chef + finales):
        hoja_animada.paste(imagen_indexada(datos, paleta), ((i % 8) * 16, (i // 8) * 16))
    hoja_animada.save(ROOT / "sprites" / "hoja_animaciones.png")
    print("Seleccion animada, confitero y finales tematicos: 22 cuadros distintos.")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("entrada", nargs="?", type=Path,
                        default=ROOT / "sprites" / "sprites_dulces_16x16.zip")
    args = parser.parse_args()
    try:
        integrar(args.entrada)
    except (OSError, ValueError, KeyError, zipfile.BadZipFile) as error:
        parser.error(str(error))


if __name__ == "__main__":
    main()
