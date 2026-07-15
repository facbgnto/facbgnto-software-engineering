# Perfil Deportivox: skills y complemento Headroom

Este perfil documenta el inventario esperado para que Deportivox use las skills del proyecto, las skills locales de Claude y el complemento global de Codex con Headroom.

## Skills del proyecto

En `.agents/skills`:

- `facbgnto-security-review`
- `facbgnto-software-engineering`

En `.claude/skills`:

- `facbgnto-security-review`
- `facbgnto-software-engineering`
- `frontend-ui-engineering`
- `graphify`

## Skills globales de Codex

En `C:\Users\Socius\.codex\skills`:

- `api-and-interface-design`
- `api-design`
- `backend-patterns`
- `banner-design`
- `brand`
- `browser-testing-with-devtools`
- `ci-cd-and-automation`
- `code-review-and-quality`
- `code-simplification`
- `coding-standards`
- `context-engineering`
- `database-migrations`
- `debugging-and-error-recovery`
- `deployment-patterns`
- `deprecation-and-migration`
- `design`
- `design-system`
- `docker-patterns`
- `documentation-and-adrs`
- `doubt-driven-development`
- `e2e-testing`
- `facbgnto-security-review`
- `facbgnto-software-engineering`
- `frontend-patterns`
- `frontend-ui-engineering`
- `git-workflow-and-versioning`
- `idea-refine`
- `incremental-implementation`
- `interview-me`
- `iterative-retrieval`
- `observability-and-instrumentation`
- `performance-optimization`
- `planning-and-task-breakdown`
- `postgres-patterns`
- `search-first`
- `security-and-hardening`
- `security-review`
- `security-scan`
- `shipping-and-launch`
- `slides`
- `source-driven-development`
- `spec-driven-development`
- `tdd-workflow`
- `test-driven-development`
- `ui-styling`
- `ui-ux-pro-max`
- `using-agent-skills`
- `verification-loop`

## Headroom

- Version objetivo: `headroom 0.31.0`
- Configuracion del proyecto: `.facbgnto/headroom.env`
- Variable esperada: `HEADROOM_VERSION=0.31.0`
- Output shaper recomendado: `HEADROOM_OUTPUT_SHAPER=0`

Headroom comprime contexto y resultados de herramientas; Caveman, si se instala, reduce salida. No actives `HEADROOM_OUTPUT_SHAPER=1` junto con Caveman sin medir el resultado.
