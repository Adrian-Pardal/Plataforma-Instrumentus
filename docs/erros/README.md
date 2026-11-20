# Registro de erros

Cada erro relevante vira um arquivo `ERR-NNN-titulo-curto.md` nesta pasta,
a partir de `docs/templates/erro.md`. O registro é feito pela skill
`/registrar-erro`. Se o mesmo erro voltar, a skill atualiza o arquivo
existente (`recorrencias`) em vez de criar outro.

## Índice

| ID | Título | Categoria | Severidade | Status | Data | Recorrências |
|----|--------|-----------|------------|--------|------|--------------|
| ERR-001 | protect-push bloqueia git push com redirecionamento de saída | bug | baixa | corrigido | 2026-10-28 | 1 |
| ERR-002 | protect-merge bloqueia gh pr merge com redirecionamento de saída | bug | baixa | corrigido | 2026-11-20 | 1 |
| ERR-003 | protect-merge libera opção proibida escondida por aspas com \| ou ; e por expansões do shell | bug | media | aberto | 2026-11-20 | 1 |
