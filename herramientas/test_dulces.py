"""Verifica fuentes, tablas de datos y capturas del ASM real tras build.ps1 -Test."""
import hashlib
import json
import re
import unittest
import zipfile

from convertir_asset import ROOT, leer_paleta
from integrar_dulces import ARCHIVOS, leer_fuentes, pixeles


def leer_tabla(texto):
    return [int(numero, 16) for linea in texto.splitlines() if linea.strip().startswith("db ")
            for numero in re.findall(r"([0-9A-F]+)h", linea)]


class DulcesTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.paleta = leer_paleta(ROOT / "sprites" / "paleta.json")
        cls.imagenes, cls.originales = leer_fuentes(ROOT / "sprites" / "png_16x16")
        cls.informe = json.loads((ROOT / "sprites" / "dulces.json").read_text(encoding="utf-8"))

    def test_fuentes_y_transparencia_exportadas(self):
        with zipfile.ZipFile(ROOT / "sprites" / "sprites_dulces_16x16.zip") as paquete:
            for nombre, imagen, original, info in zip(
                    ARCHIVOS, self.imagenes, self.originales, self.informe["sprites"]):
                with self.subTest(sprite=nombre):
                    self.assertEqual(original, paquete.read(f"png_16x16/{nombre}"))
                    self.assertEqual(hashlib.sha256(original).hexdigest(), info["sha256_original"])
                    ruta = ROOT / "sprites" / "convertidos" / nombre.replace(".png", ".txt")
                    lineas = ruta.read_text().splitlines()
                    self.assertEqual(lineas[0], "VGA8 16 16")
                    indices = [int(v, 16) for linea in lineas[1:] for v in linea.split()]
                    inc = leer_tabla(ruta.with_suffix(".inc").read_text())
                    self.assertEqual(indices, inc)
                    self.assertEqual(len(indices), 256)
                    self.assertTrue(all(0 <= i < len(self.paleta) for i in indices))
                    self.assertEqual([i == 0 for i in indices], [p[3] == 0 for p in pixeles(imagen)])
                    self.assertLess(info["error_rgb_rms"], 8)

    def test_tablas_y_colores_interfaz(self):
        self.assertLessEqual(len(self.paleta), 256)
        # RGB DAC originales: la ampliacion no cambia paneles, texto ni marcadores.
        ui = [(0, 0, 0), (4, 6, 12), (8, 12, 20), (18, 24, 32), (58, 17, 20),
              (17, 48, 30), (18, 32, 60), (42, 47, 54), (44, 23, 58), (63, 34, 12),
              (27, 61, 41), (15, 51, 57), (60, 28, 44), (63, 23, 27), (63, 52, 22), (60, 62, 63)]
        doc = json.loads((ROOT / "sprites" / "paleta.json").read_text())
        self.assertEqual([tuple(c["rgb"]) for c in doc["colores"][:16]], ui)
        palette_inc = (ROOT / "src" / "palette.inc").read_text()
        self.assertEqual(leer_tabla(palette_inc), [v for c in doc["colores"] for v in c["rgb"]])
        self.assertIn("paletaFin LABEL BYTE", palette_inc)
        tabla = leer_tabla((ROOT / "src" / "sprites.inc").read_text())
        self.assertEqual(len(tabla), 5632)
        for i, nombre in enumerate(ARCHIVOS[:8]):
            inc = ROOT / "sprites" / "convertidos" / nombre.replace(".png", ".inc")
            seleccionado = inc.with_name(inc.stem + "_seleccion.inc")
            cuadro_a = leer_tabla(inc.read_text())
            cuadro_b = leer_tabla(seleccionado.read_text())
            self.assertEqual(len(cuadro_b), 256)
            self.assertNotEqual(cuadro_a, cuadro_b)
            self.assertEqual(tabla[i * 512:(i + 1) * 512], cuadro_a + cuadro_b)
        for inicio in (4096, 4608, 5120):
            self.assertNotEqual(tabla[inicio:inicio + 256], tabla[inicio + 256:inicio + 512])

    def test_catalogo_y_propuesta_en_capturas_asm(self):
        carpeta = ROOT / "tmp" / "dosbuild"
        if not (carpeta / "HARDB.RAW").exists():
            self.skipTest("Primero ejecutar build.ps1 -Test para obtener las capturas del ASM.")
        for captura in ("HARD.RAW", "HARDB.RAW"):
            pantalla = (carpeta / captura).read_bytes()
            self.assertEqual(len(pantalla), 64000)
            # Todas las fichas y cada pixel, incluidos los huecos sobre el panel.
            for i in range(8):
                self.comprobar_sprite(pantalla, i, 208 + (i % 4) * 26, 36 + (i // 4) * 26, 2)
            for columna, i in enumerate((0, 3, 5, 6, 7)):
                cuadro_b = captura == "HARDB.RAW" and columna == 0
                self.comprobar_sprite(pantalla, i, 208 + columna * 20, 108, 1, cuadro_b)

    def comprobar_sprite(self, pantalla, i, x, y, fondo, seleccionado=False):
        nombre = ARCHIVOS[i].replace(".png", "_seleccion.inc" if seleccionado else ".inc")
        indices = leer_tabla((ROOT / "sprites" / "convertidos" / nombre).read_text())
        esperado = bytes(v or fondo for v in indices)
        real = b"".join(pantalla[(y + f) * 320 + x:(y + f) * 320 + x + 16] for f in range(16))
        self.assertEqual(real, esperado, f"Ficha {i + 1} en ({x},{y})")

    def test_historial_completo_y_secreto_revelado(self):
        carpeta = ROOT / "tmp" / "dosbuild"
        for nombre in ("LOSE.RAW", "NORMAL.RAW", "FULLHARD.RAW"):
            if not (carpeta / nombre).exists():
                self.skipTest("Ejecutar build.ps1 -Test.")
            pantalla = (carpeta / nombre).read_bytes()
            if nombre == "LOSE.RAW":
                for fila in range(12):
                    for columna in range(4):
                        self.comprobar_sprite(pantalla, 5, 18 + (fila // 6) * 98 + columna * 16,
                                             38 + (fila % 6) * 24, 2)
                for columna, i in enumerate((0, 0, 1, 2)):
                    self.comprobar_sprite(pantalla, i, 208 + columna * 20, 172, 2)
            else:
                cantidad = 4 if nombre == "NORMAL.RAW" else 5
                for fila in range(10):
                    for columna in range(cantidad):
                        self.comprobar_sprite(pantalla, (fila + columna) % (6 if cantidad == 4 else 8),
                                             32 + columna * 20, 30 + fila * 16, 2)

    def test_animaciones_restauran_su_region(self):
        carpeta = ROOT / "tmp" / "dosbuild"
        tabla = leer_tabla((ROOT / "src" / "sprites.inc").read_text())
        for nombre, inicio, x, y, fondo in (("SPLASH", 4096, 144, 100, 1),
                                           ("WIN", 4608, 292, 154, 2),
                                           ("LOSE", 5120, 292, 154, 2)):
            if not (carpeta / f"{nombre}B.RAW").exists():
                self.skipTest("Ejecutar build.ps1 -Test.")
            a = (carpeta / f"{nombre}.RAW").read_bytes()
            b = (carpeta / f"{nombre}B.RAW").read_bytes()
            region = {f * 320 + c for f in range(y, y + 16) for c in range(x, x + 16)}
            self.assertNotEqual(a, b, nombre)
            self.assertTrue(all(a[p] == b[p] for p in range(64000) if p not in region), nombre)
            for cuadro, captura in enumerate((a, b)):
                esperado = bytes(v or fondo for v in tabla[inicio + cuadro * 256:inicio + (cuadro + 1) * 256])
                real = b"".join(captura[(y + f) * 320 + x:(y + f) * 320 + x + 16] for f in range(16))
                self.assertEqual(real, esperado, f"{nombre}, cuadro {cuadro}")


if __name__ == "__main__":
    unittest.main()
