"""Datos de pixel art y transformacion discreta para las animaciones del juego.

Son tablas de indices VGA, calculadas al construir; el EXE anima mediante ASM.
"""


def cuadro_seleccion(indices):
    """Comprimir verticalmente 16 filas en 14 y apoyar el dulce en su base.

    Nunca desplaza una imagen fuera de su lienzo ni elimina la primera/ultima fila.
    El cuadro A conserva exactamente los indices del PNG recibido.
    """
    salida = [0] * 256
    for y in range(14):
        origen = round(y * 15 / 13)
        salida[(y + 2) * 16:(y + 3) * 16] = indices[origen * 16:(origen + 1) * 16]
    return salida


def patron(filas, colores):
    if len(filas) != 16 or any(len(fila) > 16 for fila in filas):
        raise ValueError("Cada cuadro debe caber en 16x16.")
    return [colores[c] for fila in filas for c in fila.center(16, ".")]


def crear_personajes():
    # Confitero: gorro blanco, rostro crema y delantal rosa. A/B mueve los brazos.
    colores = {".": 0, "W": 15, "B": 3, "C": 9, "S": 14,
               "X": 1, "R": 12, "P": 13, "G": 10, "Y": 14, "T": 11}
    chef = ["WWWWWW", "WWWWWWWWWW", "WWWWWWWWWWWW", "WWWWWWWWWWWW",
            "WWWWWWWW", "BBBBBBBBBB", "BCSSSSSSCB", "BCXSSSSXCB",
            "BCSSSSSSCB", "BCSPSSPSCB", "SSBCSXXSCBSS", "CCCCCCCC",
            "RWWRRWWR", "RRWWWWRR", "BB....BB", "BB....BB"]
    chef_b = chef.copy()
    chef_b[8] = "SSBCSSSSSSCBSS"
    chef_b[10] = "BCSXXSCB"
    # Victoria: cupcake coronado, brazos elevados y destellos cambiantes.
    gana = ["Y", ".Y.Y.", "YYY", ".Y.", "WWWWWW", "WWWWWWWW",
            "WWWWWWWWWW", "WPPWWPPWWP", "WWWWWWWWWW", "CCCCCCCCCC",
            "GCCCCCCCCCCG", "G.CCCCCCCC.G", "CCCCCCCC", "CCCCCC",
            "BBBBBBBB", "BB....BB"]
    gana_b = gana.copy()
    gana_b[0] = "Y...Y"
    gana_b[1] = "Y"
    gana_b[10] = "CCCCCCCCCC"
    gana_b[8] = "GWWWWWWWWWWG"
    # Derrota: pastel quemado y lagrimas, sin reutilizar el dibujo de victoria.
    pierde = ["..B..B..", "B..B..B", ".B..B.", "BBBBBBBB",
              "BBBBBBBBBB", "BCCCCCCCCB", "BCXCCCCXCB", "BCTCCCCTCB",
              "BCCCCCCCCB", "BCCCXXCCCB", "BCCCCCCCCB", "CCCCCCCC",
              "CCCCCCCC", "BBBBBBBB", "BB....BB", "BB....BB"]
    pierde_b = pierde.copy()
    pierde_b[0] = "B..B..B"
    pierde_b[1] = ".B..B."
    pierde_b[7] = "BCCCCCCCCB"
    pierde_b[8] = "BCTCCCCTCB"
    return ([patron(chef, colores), patron(chef_b, colores)],
            [patron(gana, colores), patron(gana_b, colores),
             patron(pierde, colores), patron(pierde_b, colores)])
