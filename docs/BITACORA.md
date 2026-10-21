# Bitácora del desarrollo

## Primer avance — 20 de octubre de 2026 UTC

Se consultó la memoria del proyecto y se preparó una implementación nueva en TASM/MASM compatible con 8086. Se eligió construir siete módulos ASM con objetos separados para permitir llamadas entre áreas sin concentrar todo en el principal.

Se implementaron pantalla VGA, paleta, texto, dibujante de sprites, framebuffer, temporización, menú y estados; dificultades, generador, entrada manual, propuestas, evaluador, historial y resultados. Se generaron símbolos provisionales para avanzar antes de recibir los assets originales. Se añadieron construcción, arranque y tareas de VS Code.

Se ejecutaron pruebas del ASM real en DOSBox, pruebas de conversión y revisión de capturas VGA. El resultado actual y sus límites se registran en `PRUEBAS_Y_ESTADO.md`. Las decisiones principales y su razón están en `ARQUITECTURA_Y_LOGICA.md`; la guía para los recursos se mantiene en `ASSETS_Y_PALETA.md`.

La indicación del usuario establece que los assets se prepararán en otro chat y se entregarán posteriormente. No se eligió una temática definitiva ni se completaron nombres de integrantes sin información confirmada.

**Aportes de cada integrante:** pendientes de registrar con nombres y trabajo real. Este registro del avance asistido no debe presentarse como una contribución individual inventada ni como una bitácora de semanas anteriores. La entrega final debe conservar una página por semana según el enunciado.

Próximo registro: diseño de la temática, entrega de PNG originales, acuerdo sobre la maqueta de Fácil, integración de cuadros y validación con la pareja.
