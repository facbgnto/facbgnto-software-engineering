# Structurizr

Structurizr se utiliza para mantener modelos de arquitectura C4 como código.

## Uso recomendado

```text
docs/
└── architecture/
    └── workspace.dsl
```

La plantilla incluida define:

- contexto del sistema;
- contenedores;
- relaciones;
- vistas;
- estilos.

## Ejecución con Docker

```powershell
docker run --rm -it `
  -p 8080:8080 `
  -v "${PWD}\docs\architecture:/usr/local/structurizr" `
  structurizr/lite
```

Luego abre:

```text
http://localhost:8080
```

Mantén Mermaid para diagramas simples y Structurizr para arquitectura C4 formal.
