# Plano: registro de erros — modelos de issue, etiquetas e issue automática quando a main falha

- **Spec:** nenhuma. A fonte dos requisitos é o pedido do dono em 2026-11-21 (5 itens) e o método de
  registro de erros já existente (`docs/erros/`, `docs/templates/erro.md`, skill `registrar-erro`).
  Exceção autorizada pelo dono (a skill `planejar` exige spec Aprovada).
- **Status:** Aprovado (dono, 2026-11-21)
- **Data:** 2026-11-21

## Visão técnica
O método (índice, template, skill) já existe: este plano só acrescenta o que faltava. Três formulários de
issue em `.github/ISSUE_TEMPLATE/` (bug, erro da IA, ambiente); um script `scripts/abrir-issue-ci.sh`, testável
com `gh` falso, que abre uma issue "CI falhou na main" com o link do log, sem duplicar; um job
`registrar-falha` no `ci.yml` que só chama o script quando um push na `main` falha; e uma frase no CLAUDE.md.

## Modelo de dados
Não se aplica.

## Interfaces
`scripts/abrir-issue-ci.sh`: entrada por variáveis `RUN_URL` (obrigatória), `SHA` e `BRANCH` (opcionais).
Saída: 0 = abriu a issue ou já havia uma aberta; 1 = o `gh` falhou (não abre às cegas); 2 = faltou `RUN_URL`.
Usa o `gh` com a etiqueta `incidente`. Job: `needs: [seguranca, verificar]`, `if: failure()` e push na `main`,
permissões `contents: read` e `issues: write`.

## Decisões
- Script testável em vez de shell no YAML (o job só é exercitado quando a `main` falha de verdade).
- Etiqueta `incidente` para a issue de CI; só a `main` (a `develop` fica de fora; é uma linha a mais no `if`).
- Sem ADR: é automação de CI, fácil de desfazer.

## Riscos
- A etiqueta `incidente` não existir faz o job falhar → criá-la antes do merge (comandos na página de help).
- O job só roda de verdade quando a `main` falha → teste do script com `gh` falso + `actionlint` no CI.
- As chaves do topo do formulário de issue (`name`, `description`, `title`, `labels`, `body`) não foram
  confirmadas nos trechos da doc consultados → conferir abrindo "New issue" depois do merge.

## Tasks
- [x] T1 [infra] — teste VERMELHO de `abrir-issue-ci.sh`: abre uma issue; não duplica com 1 ou mais abertas;
  sem `RUN_URL` dá 2; consulta falha dá 1 sem abrir; criar falha dá 1 · Cobre: pedido 4 ·
  Teste: abrir-issue-ci.test.sh (30 min)
- [x] T2 [infra] — `scripts/abrir-issue-ci.sh` · Cobre: pedido 4 · Teste: abrir-issue-ci.test.sh (30 min)
- [x] T3 [infra] — formulários `bug.yml`, `erro-ia.yml` e `ambiente.yml` em `.github/ISSUE_TEMPLATE/` ·
  Cobre: pedido 2 · Teste: conferência manual em "New issue" (30 min)
- [x] T4 [infra] — job `registrar-falha` no `ci.yml` · Cobre: pedido 4 · Teste: actionlint + abrir-issue-ci.test.sh (30 min)
- [x] T5 [infra] — frase no CLAUDE.md (§6) e uma linha na skill `registrar-erro` (campo `issue`) · Cobre: pedidos
  3 e 5 · Teste: leitura (15 min)
- [x] T6 [infra] — página `docs/help/ferramentas/registro-de-erros.md` (etiquetas, modelos, issue de CI),
  atualizar `ci.md` e o índice do help · Cobre: pedidos 2 e 4 · Teste: leitura (30 min)

## Rastreabilidade
| Pedido | Task | Teste |
|--------|------|-------|
| 1. `docs/erros/`, README e template | já existem (nada a fazer) | — |
| 2. Modelos de issue e etiquetas | T3, T6 | conferência manual |
| 3. Skill `registrar-erro` segue o método | T5 (confirmado; 1 linha) | leitura |
| 4. Job que abre issue se a main falhar | T1, T2, T4 | abrir-issue-ci.test.sh, actionlint |
| 5. Regra no CLAUDE.md | T5 | leitura |
