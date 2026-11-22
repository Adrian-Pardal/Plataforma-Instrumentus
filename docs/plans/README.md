---
titulo: Planos
proposito: Indexar os planos de implementação (como e em que ordem construir cada feature)
status: vigente
atualizado: 2026-11-22
mantido-por: /planejar
relacionados: [../templates/plan.md, ../specs/README.md]
---

# Planos

**Esta pasta responde:** como e em que ordem esta feature será construída?
**Mantida por:** `/planejar`

Um arquivo por plano, `NNN-<feature>.md`, a partir de `docs/templates/plan.md`. O plano diz COMO e em que
ORDEM construir o que a spec (ou o ADR, quando não há spec) pede. Só se implementa com o plano **Aprovado**.

## Índice

| Nº | Plano | Status | Data |
|----|-------|--------|------|
| 001 | [Divisor de comandos compartilhado para os hooks](001-divisor-de-comandos.md) | Aprovado | 2026-11-20 |
| 002 | [Registro de erros: modelos de issue, etiquetas e issue automática](002-registro-de-erros.md) | Aprovado | 2026-11-21 |
| 003 | [Título do PR em Conventional Commits, estratégia de merge e regra no CLAUDE.md](003-titulo-do-pr-e-estrategia-de-merge.md) | Aprovado | 2026-11-21 |
| 004 | [Proteger o próprio agente: conteúdo lido é dado, saída de dados pede confirmação, MCP aprovado](004-protecao-do-agente.md) | Aprovado | 2026-11-22 |
| 005 | [Registro de eventos do harness para a pesquisa](005-registro-de-eventos-do-harness.md) | Concluído | 2026-11-22 |
| 006 | [Coleta de dados por fase da pesquisa](006-coleta-de-dados-por-fase.md) | Concluído | 2026-11-22 |
