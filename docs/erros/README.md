---
titulo: Registro de erros
proposito: Indexar os erros relevantes já ocorridos, com causa raiz e prevenção
status: vigente
atualizado: 2026-11-22
mantido-por: /registrar-erro
relacionados: [../templates/erro.md, ../README.md]
---

# Registro de erros

**Esta pasta responde:** esse erro já aconteceu? Qual foi a causa e como se previne?
**Mantida por:** `/registrar-erro`

Cada erro relevante vira um arquivo `ERR-NNN-titulo-curto.md` nesta pasta,
a partir de `docs/templates/erro.md`. O registro é feito pela skill
`/registrar-erro`. Se o mesmo erro voltar, a skill atualiza o arquivo
existente (`recorrencias`) em vez de criar outro.

## Índice

| ID | Título | Categoria | Severidade | Status | Data | Recorrências |
|----|--------|-----------|------------|--------|------|--------------|
| ERR-001 | protect-push bloqueia git push com redirecionamento de saída | bug | baixa | corrigido | 2026-10-28 | 1 |
| ERR-002 | protect-merge bloqueia gh pr merge com redirecionamento de saída | bug | baixa | corrigido | 2026-11-20 | 1 |
| ERR-003 | protect-merge libera opção proibida escondida por aspas com \| ou ;, e por apóstrofos pareando errado | bug | media | aceito | 2026-11-20 | 1 |
