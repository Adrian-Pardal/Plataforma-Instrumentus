# Plano: título do PR em Conventional Commits, estratégia de merge (ADR 0006) e regra no CLAUDE.md

- **Spec:** nenhuma. A fonte dos requisitos é o pedido do dono em 2026-11-21 (job `titulo-do-pr`, proteção,
  ADR da estratégia de merge, frase no CLAUDE.md). Exceção autorizada pelo dono (a skill `planejar` exige
  spec Aprovada).
- **Status:** Aprovado (dono, 2026-11-21)
- **Data:** 2026-11-21

## Visão técnica
Um script `scripts/validar-titulo-pr.sh`, testável sem GitHub, recebe o título por variável e diz se segue
Conventional Commits. O job `titulo-do-pr` do `ci.yml` só chama o script, em `pull_request`. Depois que o
job existe na `develop`, a proteção da `develop` e da `main` passa a exigi-lo. Por fim, o ADR 0006 registra a
estratégia de merge e o CLAUDE.md ganha a regra. O padrão é o mesmo do `commit-msg` do lefthook, para o título
do PR (que vira o título do commit de merge) e os commits terem a mesma regra.

## Modelo de dados
Não se aplica.

## Interfaces
`scripts/validar-titulo-pr.sh`: entrada pela variável `TITULO`. Padrão aceito (igual ao do lefthook):
`^(feat|fix|docs|test|refactor|chore|ci|build|perf)(\([a-z0-9._/-]+\))?!?: .+`, isto é, tipo, escopo
opcional, `!` opcional (mudança incompatível) e `: ` antes da descrição. Saída: 0 = título válido; 1 = fora do
padrão (a mensagem mostra o título e o padrão); 2 = faltou `TITULO`.
Job `titulo-do-pr`: só em `pull_request`, tipos `opened`, `edited`, `synchronize` e `reopened`; permissões
`contents: read`; o título entra por `env:` (nunca interpolado no `run:`); sem `name:`, o check aparece como
`titulo-do-pr`.

## Decisões
- Script testável em vez de regex no YAML (mesmo padrão do plano 002).
- Mesmo padrão do lefthook, com `!`, que a spec de Conventional Commits permite; o dono não o citou.
- O job fica no `ci.yml`, como pedido. Efeito aceito: `edited` no gatilho reexecuta o CI inteiro quando o
  título é editado (o `concurrency` cancela a execução antiga do PR). Alternativa descartada por ora: um
  workflow separado só para o título.
- `reopened` entra nos tipos, porque definir `types` tira os padrões (`opened`, `synchronize`, `reopened`).
- ADR 0006 complementa o ADR 0003 (não o substitui). Esquema de tag por recomendação do Claude, aceita pelo
  dono: SemVer `vMAJOR.MINOR.PATCH`, primeira versão `v0.1.0`, uma tag anotada a cada merge `develop → main`,
  criada pelo dono no commit de merge da `main`.

## Riscos
- Exigir o check antes de ele existir deixa todo PR preso em "Expected" → a proteção só entra depois do merge
  do PR que traz o job (task 5).
- O PR #5 do dependabot não terá o check até receber um evento novo (rebase ou edição do título).
- O título do PR da `develop` para a `main` também precisa seguir o padrão (por exemplo,
  `chore(release): v0.1.0`).
- Títulos que o GitHub gera sozinho para reverts (`Revert "..."`) não passam, porque o dono não os incluiu na
  lista de tipos; renomear o PR.
- O job só prova o que faz em um PR de verdade → teste do script + `actionlint` no CI + conferir no próprio
  PR que traz o job.
- O CLAUDE.md está com 62 linhas (limite 60 citado nas skills): mostrar o que enxugar antes de acrescentar.

## Tasks
- [ ] T1 [infra] — teste VERMELHO de `validar-titulo-pr.sh`: aceita `feat: x`, `fix(escopo): x`, `feat!: x`,
  `chore(deps): x`; recusa título sem tipo, tipo fora da lista, sem espaço depois do `:`, só `feat:`, tipo em
  maiúscula, vazio (1); sem `TITULO` dá 2 · Cobre: pedido 1 · Teste: validar-titulo-pr.test.sh (30 min)
- [ ] T2 [infra] — `scripts/validar-titulo-pr.sh` · Cobre: pedido 1 · Teste: validar-titulo-pr.test.sh (20 min)
- [ ] T3 [infra] — job `titulo-do-pr` e `types` no `ci.yml` · Cobre: pedido 1 · Teste: actionlint +
  validar-titulo-pr.test.sh + o próprio PR (30 min)
- [ ] T4 [infra] — help: página `docs/help/ferramentas/titulo-do-pr.md`, atualizar `ci.md`,
  `protecao-de-branches.md` e o índice do help · Cobre: pedidos 1 e 2 · Teste: leitura (30 min)
- [ ] T5 [infra] — (depois do merge do PR da T1–T4) exigir `titulo-do-pr` na proteção da `develop` e da
  `main`, com os comandos mostrados antes de rodar · Cobre: pedido 2 · Teste: `gh api` mostra o check
  exigido; um PR com título errado fica bloqueado (30 min)
- [ ] T6 [docs] — ADR 0006 "Estratégia de merge: merge commit em tudo e tag por versão" pela `/registrar-adr`
  (squash e rebase descartados, com o motivo; Proposto até o "sim" do dono) · Cobre: pedido 3 · Teste:
  leitura (30 min)
- [ ] T7 [docs] — frase no CLAUDE.md (§6), enxugando o que for preciso para não passar do limite · Cobre:
  pedido 4 · Teste: leitura (15 min)

## Rastreabilidade
| Pedido | Task | Teste |
|--------|------|-------|
| 1. Job `titulo-do-pr` (Conventional Commits em `pull_request`) | T1, T2, T3, T4 | validar-titulo-pr.test.sh, actionlint |
| 2. Job obrigatório na proteção da `develop` e da `main` | T4, T5 | `gh api` e um PR com título errado |
| 3. ADR da estratégia de merge | T6 | leitura |
| 4. Regra no CLAUDE.md | T7 | leitura |
