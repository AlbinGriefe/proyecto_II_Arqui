"""Genera tablas TASM de paleta y simbolos temporales propios, sin dependencias.

Los simbolos son marcadores de desarrollo, no los assets tematicos definitivos.
Ejecutar desde cualquier directorio: python herramientas/generar_base.py
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

# Dibujos de 8x8 propios ampliados por vecino mas cercano a 16x16.
PATRONES = [
    ["00010000", "00111000", "01111100", "11111110", "00111000", "00111000", "00111000", "00000000"],
    ["10000010", "01000100", "00101000", "00010000", "00101000", "01000100", "10000010", "00000000"],
    ["00010000", "00010000", "00010000", "11111110", "00010000", "00010000", "00010000", "00000000"],
    ["00000000", "00000110", "00001100", "10011000", "11110000", "01100000", "00000000", "00000000"],
    ["00100000", "00110000", "00111000", "00111100", "00111000", "00110000", "00100000", "00000000"],
    ["11111110", "00000100", "00001000", "00010000", "00100000", "01000000", "11111110", "00000000"],
    ["01111100", "01000100", "01000100", "01111100", "01000000", "01000000", "01000000", "00000000"],
    ["11000110", "01101100", "00111000", "00010000", "00010000", "00010000", "00010000", "00000000"],
]
MASCOTA = ["00111100", "01111110", "11011011", "11111111", "10111101", "11000011", "01111110", "00100100"]
GANO = ["00010000", "01010100", "00111000", "11111110", "00111000", "01010100", "00010000", "00000000"]
PERDIO = ["00000000", "01000100", "00101000", "00010000", "00101000", "01000100", "00000000", "00000000"]


def ampliar(patron, color, frame):
    datos = []
    for y in range(16):
        for x in range(16):
            pixel = patron[y // 2][x // 2] == "1"
            datos.append((15 if frame and (x + y) % 4 == 0 else color) if pixel else 0)
    return datos


def tabla(nombre, valores):
    filas = [f"; {nombre}: bytes por filas, 0 transparente", f"{nombre} LABEL BYTE"]
    for inicio in range(0, len(valores), 16):
        filas.append("    db " + ",".join(f"{valor:03X}h" for valor in valores[inicio:inicio + 16]))
    return "\n".join(filas)


def generar():
    paleta = json.loads((ROOT / "sprites" / "paleta.json").read_text(encoding="utf-8"))
    colores = paleta["colores"]
    assert [c["indice"] for c in colores] == list(range(16))
    assert all(0 <= v <= 63 for c in colores for v in c["rgb"])
    texto_paleta = tabla("paleta", [v for c in colores for v in c["rgb"]])
    (ROOT / "src" / "palette.inc").write_text(texto_paleta + "\n", encoding="ascii")
    fichas = []
    for patron, color in zip(PATRONES, [4, 5, 6, 8, 9, 11, 12, 14]):
        for frame in range(2):
            fichas.extend(ampliar(patron, color, frame))
    tablas = [tabla("sprites", fichas)]
    tablas.append(tabla("mascota", sum([ampliar(MASCOTA, 11, f) for f in range(2)], [])))
    tablas.append(tabla("finale", sum([ampliar(p, c, f) for p, c in [(GANO, 10), (PERDIO, 13)] for f in range(2)], [])))
    (ROOT / "src" / "sprites.inc").write_text("\n\n".join(tablas) + "\n", encoding="ascii")
    print("Generados src/palette.inc y src/sprites.inc")


if __name__ == "__main__":
    generar()
