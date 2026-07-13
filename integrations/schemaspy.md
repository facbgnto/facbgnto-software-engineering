# SchemaSpy

SchemaSpy genera documentación HTML navegable de una base de datos, incluyendo diagramas entidad-relación.

## Recomendación

Usa variables de entorno para credenciales:

```text
DB_HOST
DB_PORT
DB_NAME
DB_SCHEMA
DB_USER
DB_PASSWORD
```

Nunca guardes contraseñas reales en scripts o archivos versionados.

## Ejemplo conceptual con Docker

```powershell
docker run --rm `
  -v "${PWD}\docs\database:/output" `
  schemaspy/schemaspy:latest `
  -t pgsql `
  -host $env:DB_HOST `
  -port $env:DB_PORT `
  -db $env:DB_NAME `
  -s $env:DB_SCHEMA `
  -u $env:DB_USER `
  -p $env:DB_PASSWORD `
  -o /output
```

Ajusta el tipo de base de datos y el driver según el proyecto.
