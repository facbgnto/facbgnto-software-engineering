# Graphify + LightRAG

## Graphify

Úsalo para identificar:

- archivos relacionados;
- funciones y clases;
- dependencias;
- rutas, controladores y modelos;
- impacto probable de una modificación.

Ejemplo:

```powershell
graphify . --code-only
```

## LightRAG

Úsalo para consultar:

- arquitectura;
- decisiones;
- especificaciones;
- reglas del negocio;
- manuales y documentos.

## Flujo conjunto

1. Consultar LightRAG para entender el requerimiento y las reglas.
2. Consultar Graphify para ubicar el código.
3. Leer directamente los archivos encontrados.
4. Crear especificación y plan.
5. Implementar y verificar.
