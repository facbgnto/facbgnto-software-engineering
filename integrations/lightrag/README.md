# LightRAG para proyectos

LightRAG se recomienda para indexar:

- documentación de arquitectura;
- especificaciones funcionales;
- decisiones técnicas;
- reglas de negocio;
- manuales;
- esquemas y diccionarios de datos;
- documentación de API.

No indexes:

- `.env`;
- tokens o credenciales;
- respaldos productivos;
- datos personales;
- archivos generados;
- `node_modules`;
- logs con información sensible.

## Instalación recomendada

Desde el repositorio oficial:

```powershell
git clone https://github.com/HKUDS/LightRAG.git
cd LightRAG
```

Sigue su instalación oficial con `uv`. Para uso en equipo, ejecuta LightRAG Server y configura su WebUI/API.

## Relación con Graphify

- Graphify: estructura estática y relaciones del código.
- LightRAG: búsqueda semántica y grafo de conocimiento documental.

Los resultados de ambos deben verificarse contra el repositorio fuente.
