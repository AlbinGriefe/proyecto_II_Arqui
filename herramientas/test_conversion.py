"""Comprueba el contrato que debe compartir el conversor con el dibujante ASM."""
import tempfile
import unittest
from pathlib import Path

from PIL import Image
from convertir_asset import ROOT, convertir, escribir_inc, escribir_txt, leer_paleta


class ConversionTests(unittest.TestCase):
    def test_alpha_color_and_row_order(self):
        palette = leer_paleta(ROOT / "sprites" / "paleta.json")
        image = Image.new("RGBA", (2, 2))
        image.putdata([(*palette[4], 255), (*palette[5], 255), (0, 0, 0, 0), (*palette[15], 255)])
        self.assertEqual(convertir(image, palette), [4, 5, 0, 15])
        # El negro opaco no puede convertirse en transparencia.
        self.assertNotEqual(convertir(Image.new("RGBA", (1, 1), (0, 0, 0, 255)), palette), [0])

    def test_exports_preserve_values(self):
        temporal = (ROOT / "tmp").resolve()
        temporal.mkdir(exist_ok=True)
        with tempfile.TemporaryDirectory(dir=temporal) as directory:
            inc = Path(directory) / "ficha.inc"
            txt = Path(directory) / "ficha.txt"
            escribir_inc(inc, "ficha", 2, 2, [4, 5, 0, 15])
            escribir_txt(txt, 2, 2, [4, 5, 0, 15])
            self.assertIn("db 004h,005h,000h,00Fh", inc.read_text())
            self.assertEqual(txt.read_text().splitlines(), ["VGA8 2 2", "04 05", "00 0F"])
            with self.assertRaises(ValueError):
                escribir_inc(inc, "etiqueta con espacios", 2, 2, [4, 5, 0, 15])


if __name__ == "__main__":
    unittest.main()
