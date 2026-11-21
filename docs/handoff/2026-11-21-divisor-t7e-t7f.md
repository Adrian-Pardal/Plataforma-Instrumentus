# Handoff — 2026-11-21 (divisor-de-comandos, T7e–T7f)

## Onde estamos
Feature: divisor de comandos compartilhado para os hooks (ADR 0005, plano
`docs/plans/001-divisor-de-comandos.md`). Fase: implementação do PR 1a (só o `divisor.sh`; nenhum hook o usa
ainda) TERMINADA; falta a nova `/revisar`. Branch `feat/divisor-de-comandos`, em sincronia com `origin`
(commits sem push: nenhum; último commit d0b2836). PR 1a NÃO aberto. Árvore limpa.

## Feito (T7e e T7f; plano marcado até a T7f)
- T7e (desempenho): o custo quadrático era `${s:i:1}` (O(n) por chamada, mesmo em locale C). Criado
  `_divisor_letras` (lê o texto uma vez para um array; 3 posições vazias no fim por causa do `set -u` dos
  hooks). Aplicado em `dividir_comando`, `_divisor_registrar_heredoc`, `tokenizar_segmento`,
  `separar_redirecionamentos` e `_desemb_aparar_parenteses`, com atalhos para palavra sem `<`/`>`/parêntese
  soltos. Os 4 casos de 20 KB ficaram em ~0,7–1,3 s contra o limite de 2 s (antes 5,6–7,2 s).
- Régua de complexidade: `scripts/complexidade.sh` (+ `scripts/tests/complexidade.test.sh` e
  `docs/help/ferramentas/complexidade.md`). Conta 1 + `if/elif/while/until/for/&&/||` + ramos de `case`
  por função. É uma APROXIMAÇÃO por texto, não a métrica oficial, e não mede complexidade cognitiva.
- T7f (refatoração, sem mudar o comportamento; a suíte do divisor ficou intacta): `dividir_comando` 49→6,
  `desembrulhar` 43→6, `tokenizar_segmento` 39→6, `separar_redirecionamentos` 35→3. Cada uma virou um laço
  fino + helpers (`_divisor_*`, `_desemb_*`, `_tokenizar_*`, `_redir_*`) que usam as variáveis locais de quem
  chamou, por escopo dinâmico, como `_divisor_fechar` já fazia.
- Commits da sessão: 3dbb85e…d0b2836 (9 commits), todos enviados.

## Em andamento
Nada pela metade.

## Próximo passo
Rodar `scripts/verify.sh test` e `git status` antes de agir (o estado abaixo vale às 11:56). Depois,
o dono roda a nova `/revisar` da branch (inclui complexidade cognitiva < 15, que o script não mede) e
decide se abre o PR 1a. Se a revisão reprovar, corrigir em tasks novas (T7g…), com TDD.

## Decisões
Nenhum ADR novo. Opção A (helper por estado/ramo) para a T7f; régua por contagem de texto (opção a), sem
entrar no `verify.sh` (só mede; pode virar barreira depois da T7f, se o dono quiser). Não subi o limite
de 2 s do teste de desempenho: as correções foram no código.

## Problemas
- Ainda acima de 9 pela régua, fora da T7f: `achar_subcomando` (12), `_redir_emitir` (12),
  `_desemb_aparar_parenteses` (11).
- A régua errava em palavras reservadas dentro de padrão de `case`; corrigido (1ccd631, 96d1bfd). Pode
  errar em `case` com ramo em várias linhas e `if` dentro de `$( )` (documentado na página de ajuda).
- Falso bloqueio conhecido: `git-lfs push` (🔵, ainda não tratado).
- Limites aceitos no ADR: `sh -c`, `ssh h "git push"`, variáveis, aliases.
- `protect-push` ainda tem o furo `--config-env`/`--attr-source` até a T10.
- Abertos: DEBT-001 (lefthook no CI), DEBT-002; método de registro de erros (pedido original) não feito;
  CLAUDE.md com 62 linhas (limite 60); PR #5 do dependabot; branches antigas locais e remotas.
- O `actionlint` não está instalado nesta máquina (o `full` o pula; o CI instala).

## Estado da verificação
`scripts/verify.sh test` em 2026-11-21 11:56:57: PASSOU (rc=0), "todos os casos passaram" e "testes dos
scripts passaram", 567 casos `ok`. `scripts/verify.sh full` rodou com rc=0 antes do último commit de
código (shellcheck sem alertas em 18 arquivos); depois dele mudou só o checkbox do plano.
- Testes desativados/dívidas abertas: ver docs/DEBT.md
