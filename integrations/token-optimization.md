# Optimización de tokens: Headroom + Caveman

## Responsabilidades

- Headroom `0.31.0`: comprime el contexto de entrada y resultados de herramientas.
- Caveman: reduce la verbosidad de la salida.
- No activar simultáneamente Caveman y `HEADROOM_OUTPUT_SHAPER=1` salvo que se haya medido el resultado.

## Política de precisión

Nunca comprimir ni reescribir de forma destructiva:

- código fuente;
- comandos y scripts;
- consultas SQL;
- rutas y URL;
- mensajes de error;
- contratos API;
- migraciones;
- resultados de pruebas;
- hallazgos y evidencia de seguridad.

## Configuración recomendada

- Headroom habilitado.
- Version fijada en `HEADROOM_VERSION=0.31.0`.
- Headroom output shaper deshabilitado.
- Caveman `lite`.
- Holdout de Headroom en 10% para medir ahorro real.
