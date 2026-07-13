# Reglas del proyecto para agentes

## Prioridad

1. Instrucciones explícitas del usuario.
2. Este archivo.
3. Documentación y convenciones del proyecto.
4. Skill `facbgnto-software-engineering`.

## Antes de modificar

- Lee README, configuración, scripts y archivos relacionados.
- Identifica frontend, backend, base de datos, autenticación y despliegue.
- Busca una implementación similar antes de crear una nueva.
- Para cambios significativos presenta o crea especificación y plan.
- Usa Graphify como ayuda si está disponible, pero confirma leyendo el código.

## Reglas de código

- Mantén el estilo y arquitectura existentes.
- Realiza cambios mínimos relacionados con el requerimiento.
- No agregues dependencias sin justificar.
- No incluyas secretos ni archivos `.env`.
- No desactives pruebas o validaciones para lograr que el build pase.
- No alteres contratos o migraciones existentes sin explicar el impacto.
- No modifiques código no relacionado.

## Seguridad y datos

- Toda autorización se valida en backend.
- Toda consulta multi-tenant debe filtrar por el tenant correspondiente.
- Valida entradas en API y persistencia.
- No muestres información sensible en logs o respuestas.
- Usa transacciones para operaciones atómicas de múltiples pasos.

## Verificación

Antes de finalizar:

- ejecuta pruebas relevantes;
- ejecuta build, lint y typecheck disponibles;
- revisa el diff;
- confirma criterios de aceptación;
- informa resultados reales y fallos pendientes.

## Git

- No hagas `push`, merge, rebase destructivo ni elimines ramas sin autorización.
- No descartes cambios locales del usuario.
- Prefiere commits pequeños y descriptivos cuando se soliciten.
