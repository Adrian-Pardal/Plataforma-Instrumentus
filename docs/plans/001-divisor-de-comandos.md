# Plano: divisor de comandos compartilhado para os hooks

- **Spec:** nenhuma. A fonte dos requisitos é o [ADR 0005](../adr/0005-divisor-de-comandos-para-os-hooks.md)
  (Decisão, itens 1 a 4) e os achados do [ERR-003](../erros/ERR-003-protect-merge-analise-de-texto.md).
  Exceção autorizada pelo dono em 2026-11-20 (a skill `planejar` exige spec Aprovada).
- **Status:** Aprovado (reaprovado pelo dono em 2026-11-21, depois de incorporar a revisão do PR 1a: tasks T7b a T7f)
- **Data:** 2026-11-20

## Visão técnica
Um arquivo de funções em bash, `.claude/hooks/lib/divisor.sh`, carregado por `source` nos hooks. Ele varre o
comando UMA vez, caractere a caractere, com um estado (normal, aspa simples, aspa dupla, escape), e entrega o
resultado por variáveis globais (contrato A, o mesmo estilo de `TOK` que os hooks já usam):
- `dividir_comando "$CMD"` → `SEGMENTOS`: um por comando; separadores `&`, `&&`, `||`, `;`, `|`, `|&` e quebra
  de linha fora de aspas.
- `tokenizar_segmento "$SEG"` → `TOK` (sem aspas), `TOK_CITADO` (1 se o token tinha aspas: texto citado nunca
  vira operador nem opção), `ININTERPRETAVEL` e `MOTIVO`.
- `separar_redirecionamentos` → tira de `TOK` os redirecionamentos e o alvo, e deixa `REDIR_ESCRITA` (alvos de
  `>`, `>>`, `>|`, `&>`) e `REDIR_LEITURA` (alvos de `<` e `<<<`); o `protect-files` precisa do tipo. Heredoc
  (`<<`, `<<-`) é tratado na T7.
- `achar_subcomando PROG` → `SUB`, `ARGS` e `DIR_GIT` (o valor de `-C`, que o `protect-push` usa), pulando flags
  globais. Flags que levam valor na forma `--x valor` (com `=` não consomem o token seguinte): git `-C`, `-c`,
  `--git-dir`, `--work-tree`, `--namespace`, `--config-env`, `--attr-source`; gh `-R`, `--repo`. (`--hostname`
  é flag de `gh api`, depois do subcomando.) Flag desconhecida é booleana, e a regra de forma da opção B
  continua como rede extra.
- `desembrulhar` → entra em `env`, `command`, `xargs` sem flags, `sudo`, `nohup`, `time` (os que o
  `protect-files` já pula) e subshell `( )`. `sh -c`, variáveis e aliases ficam fora do alcance.

Falha fechada: aspas abertas, `$(` ou crase em aspas duplas ou sem aspas deixam `ININTERPRETAVEL=1` (em aspas
simples não são expansão). Regra, fixada com testes na T7: (1) se programa e subcomando se acham nas primeiras
palavras, vale o subcomando: protegido (`git push`, `gh pr merge`, `gh api`, `gh alias` e os verbos do
`protect-files`) bloqueia, e `git commit -m "$(cat <<'EOF' ...)"` ou `echo "$(git rev-parse HEAD)"` liberam;
(2) se não se acham (a primeira palavra é uma expansão), bloqueia quando o texto cru tem `gh` ou `git`.

O `source` do `lib/` falha fechado: `source "$(dirname "${BASH_SOURCE[0]}")/lib/divisor.sh" || bloquear ...`
(caminho relativo ao próprio hook, nunca ao `cwd`).

O divisor não bloqueia nada: cada hook decide. A migração é em 4 PRs, um hook por vez, e os testes atuais dos
hooks (`scripts/tests/*.test.sh`) são a rede de segurança.

## Modelo de dados
Não se aplica.

## Interfaces
As funções acima, entre `lib/divisor.sh` e os hooks (contrato interno). Entradas: o texto do comando. Saídas:
as variáveis globais. Erros: `ININTERPRETAVEL` e `MOTIVO`, nunca `exit` dentro do divisor.

## Decisões
- ADR 0005: divisor próprio em bash, compartilhado, com falha fechada.
- Contrato por variáveis globais (opção A, 2026-11-20): estilo atual dos hooks e sem subshell.
- Fora deste plano: a alternativa 4 do ADR (fechar squash e rebase no GitHub), que é decisão separada do dono,
  e o `docs/produto/roadmap.md`, que não existe e é do produto, não da infraestrutura dos hooks.
- Tag `[infra]` nas tasks, porque a stack é "a definir" (a skill `planejar` prevê `[back]`, `[front]` ou `[ambos]`).
- Extensões feitas nas tasks T4 a T7 e não previstas no texto original do plano: `TOK_MASCARA` (por letra), `ENV_PREFIXO`,
  `SUB2`, `WRAPPERS`, `WRAPPER_NAO_SUPORTADO`, `SEGMENTO_CRU`, `analisar_segmento`, `{` e `builtin` no `desembrulhar`, e o corpo de
  heredoc sem aspas virando segmento quando tem `$(` ou crase.
- `$(...)` e crase (opção A, 2026-11-21): se o segmento tem `$(`, crase, `<(` ou `>(` e o texto mostra uma ação protegida em
  qualquer posição, bloqueia. Entrar em `$(...)` e analisar o comando de dentro (opção B) fica como melhoria futura.

## Riscos
- Migração: os 3 hooks tratam aspas e redirecionamento de formas diferentes → regressão. Reduzir: um hook por
  PR; rodar os testes atuais antes e depois; comparar o `rc` em um conjunto de comandos (como no refactor do #8).
- Tabela de flags com valor incompleta → subcomando errado. Reduzir: flag desconhecida = booleana, regra de
  forma mantida, testes com as formas reais (`gh -R x pr merge`, `gh pr -R x merge`, `gh --paginate=true api`).
- O `protect-push` atual libera `git --config-env a=B push origin main` e `git --attr-source HEAD push origin
  main` (confirmado na revisão): é um furo existente, tratado como erro à parte (ERR-004, a registrar) e com
  testes na T5 e na T10.
- É uma aproximação do shell: variáveis, `sh -c`, aliases e `cd` não são resolvidos. Reduzir: falha fechada onde
  dá; o resto segue como limitação (o DEBT-002 é reduzido, não quitado).
- Falsos bloqueios novos pela falha fechada, em especial heredoc (`git commit -m "$(cat <<'EOF' ...)"`) e `$(`
  em aspas simples. Reduzir: regra por subcomando (acima) e testes na T7.
- Falha aberta se o `source` do lib falhar: o bash segue sem as funções. Reduzir: `|| bloquear` e um teste que
  remove o lib e espera 2.
- Estado global vazando entre segmentos. Reduzir: cada função zera suas variáveis; teste com dois segmentos.
- Desempenho: o hook roda em todo comando Bash e varre caractere a caractere. Reduzir: um teste com um comando
  de alguns KB (T2) e medir antes de migrar o PR 2 e o PR 3.
- O `protect-files.test.sh` tem só 3 casos de Bash e não serve de rede de segurança: a T11a escreve os testes
  de caracterização antes da migração. O `protect-files` também usa `compgen -G`, `grep` e `sed`; migra-se só o
  ramo Bash (Edit e Write não mudam).
- Sem biblioteca externa: nada a confirmar no Context7 (só bash 5.2, com `read -ra`, `[[ =~ ]]` e arrays,
  que os hooks já usam). Skills de apoio (modelagem-dominio, modelagem-dados, diagrama, contrato-api,
  casos-de-teste): não se aplicam. `modelagem-ameacas` valeria (é um hook de segurança), mas a skill não existe:
  pendência.
- A revisão do PR 1a (T0 a T7) achou 7 falhas abertas e 6 🟡 no divisor: heredoc com aspas parciais (`<<E"O"F`), ANSI-C
  `$'...'`, comentário com apóstrofo, subcomando que vira expansão, `$(git push)` dentro de `echo`, `<(...)`, wrappers e palavras
  reservadas (`timeout`, `nice`, `if/then`), `env -iS`, desempenho quadrático e complexidade acima dos limites. Reduzir: tasks
  T7b a T7f; o PR 1a só vai à `develop` depois delas e de uma nova `/revisar`.

## Tasks
Formato: `T<n> [tag] — descrição · Cobre: D<n> · Teste: <onde>`. Tag `[infra]`, porque a stack é "a definir".
Cada commit leva o rodapé `Task: T<n>`. Testes novos em `scripts/tests/divisor.test.sh`.
Marque com 🎓 as tasks que você faz à mão.

PR 1a (divisor):
- [x] T0 [infra] — `verify.sh`: incluir `.claude/hooks/lib/*.sh` no shellcheck do modo full e exigir
  `# shellcheck shell=bash` no lib; ajustar `verify.test.sh` · Cobre: D7 · Teste: verify.test.sh (30 min)
- [x] 🎓 T1 [infra] — `lib/divisor.sh` e `dividir_comando`: separa por `&`, `&&`, `||`, `;`, `|`, `|&` e quebra
  de linha, ignorando o que está entre aspas (versão simples) · Cobre: D1 · Teste: divisor.test.sh › separadores (60 min)
- [x] T2 [infra] — aspas numa só passada: `"a|b"`, `'x;y'`, apóstrofo dentro de aspas duplas, escape `\`; mais
  um comando de alguns KB (desempenho) · Cobre: D1 · Teste: divisor.test.sh › aspas (90 min)
- [x] T3 [infra] — `tokenizar_segmento` com `TOK_CITADO`; aspas sem fechar marcam `ININTERPRETAVEL` ·
  Cobre: D1, D4 · Teste: divisor.test.sh › tokens (60 min)
- [x] T4 [infra] — `separar_redirecionamentos` com `REDIR_ESCRITA` e `REDIR_LEITURA` (`>`, `>>`, `<`, `<<<`,
  `2>&1`, `&>`, `>|`, colados a palavra e a texto citado), com os casos do ERR-001 e ERR-002 · Cobre: D1 ·
  Teste: divisor.test.sh › redirecionamentos (90 min)
- [x] T5 [infra] — `achar_subcomando` para `gh` e `git`, com `DIR_GIT` e a tabela de flags acima; testes
  `git --config-env a=B push`, `git --attr-source HEAD push`, `gh -R x pr merge`, `gh pr -R x merge`,
  `gh --paginate=true api` · Cobre: D2 · Teste: divisor.test.sh › subcomando (90 min)
- [x] T6 [infra] — `desembrulhar`: `env`, `command`, `xargs` sem flags, `sudo`, `nohup`, `time` e subshell ·
  Cobre: D3 · Teste: divisor.test.sh › wrappers (60 min)
- [x] T7 [infra] — falha fechada com a regra por subcomando, heredoc (`<<`, `<<-`) e `$(`/crase só em aspas
  duplas ou sem aspas · Cobre: D4 · Teste: divisor.test.sh › falha fechada (60 min)
- [x] T7b [infra] — lexer: `#` abre comentário (fora de aspas, no começo de palavra); `$'...'` (ANSI-C, a barra protege a letra
  seguinte); `<(` e `>(` marcam ininterpretável como `$(`; heredoc com delimitador de aspas parciais (`<<E"O"F`) e `<<` dentro
  de `$((...))` ou de comentário não é heredoc; testes de `<<"EOF"` e `<<\EOF` · Cobre: D1, D4 ·
  Teste: divisor.test.sh › lexer (90 min)
- [x] T7c [infra] — wrappers e palavras reservadas: pular `if then else elif do while until ! exec`; abrir `timeout` (com a duração),
  `nice -n N`, `stdbuf`, `ionice`, `setsid`, `noglob` e `--` em `command`/`time`; `eval`, `watch`, `find -exec`, `coproc` e
  `parallel` vão para WRAPPER_NAO_SUPORTADO; `env` com `S` em qualquer opção curta (`-iS`); `(` e `)` aparados dos argumentos
  (`--force)`) · Cobre: D3 · Teste: divisor.test.sh › wrappers (90 min)
- [x] T7d [infra] — falha fechada: `SUB` ou `SUB2` que não é um nome simples (`$(echo push)`, `{push,}`) bloqueia; `PROTEGIDOS`
  vazio ou indefinido bloqueia; a regex da 1ª palavra roda também sobre os tokens; `VAR=$(...)` no começo não conta como
  "primeira palavra"; opção A do `$(...)` (Decisões) · Cobre: D4 · Teste: divisor.test.sh › falha fechada (90 min)
- [x] T7e [infra] — desempenho: `dividir_comando`, `tokenizar_segmento` e `separar_redirecionamentos` lineares; teste com UM
  segmento entre aspas de 20 KB pelo pipeline inteiro, com limite · Cobre: D1 (risco de desempenho) ·
  Teste: divisor.test.sh › desempenho (90 min)
- [ ] T7f [infra] — refatoração: dividir `dividir_comando`, `tokenizar_segmento`, `separar_redirecionamentos` e `desembrulhar`
  abaixo de ciclomática 10 e cognitiva 15, sem mudar o comportamento (todos os testes continuam iguais) · Cobre: D1 a D4
  (qualidade) · Teste: divisor.test.sh inteiro (90 min)

PR 1b (`protect-merge`):
- [ ] T8 [infra] — testes **vermelhos** dos achados do PR #8 em `protect-merge.test.sh`: `&` solto, `|&`, flag
  antes de `api`/`alias` (o `gh api` por expansão fica no DEBT-002). T8 e T9a vão **no mesmo push**: o hook Stop e
  o CI exigem 100% · Cobre: D1, D2 · Teste: protect-merge.test.sh › achados abertos (60 min)
- [ ] T9a [infra] — `protect-merge.sh` passa a usar `dividir_comando`, `tokenizar_segmento` e
  `separar_redirecionamentos`; `source` com `|| bloquear` e teste que remove o lib e espera 2 · Cobre: D5, D6 ·
  Teste: protect-merge.test.sh inteiro (90 min)
- [ ] T9b [infra] — `achar_gh`, `verificar_forma` e `verificar_prefixo` passam a usar `achar_subcomando`;
  apagar a lógica antiga de corte e de aspas; `gh -R x pr merge` e `gh pr -R x merge` seguem em 2 · Cobre: D5, D6 ·
  Teste: protect-merge.test.sh inteiro (90 min)

PR 2 (`protect-push`):
- [ ] T10 [infra] — `protect-push.sh` usa o divisor e `DIR_GIT`; testes vermelhos `git --config-env a=B push
  origin main`, `git --attr-source HEAD push origin main` e a suspeita do `>|` (origem: Contexto do ADR e
  ERR-001) · Cobre: D2, D6 · Teste: protect-push.test.sh (90 min)

PR 3 (`protect-files` e docs):
- [ ] T11a [infra] — testes de **caracterização** do ramo Bash do `protect-files` com o resultado atual (`>`,
  `>>`, `<`, `tee`/`cp`/`mv`/`rm`, `sed -i`, `sudo cat .env`, glob `.env*`) · Cobre: D6 ·
  Teste: protect-files.test.sh (60 min)
- [ ] T11b [infra] — migrar o ramo Bash de `protect-files.sh` para o divisor · Cobre: D6 ·
  Teste: protect-files.test.sh (90 min)
- [ ] T12 [infra] — docs: `merge-de-pr.md`, `testes-dos-hooks.md`, reescrever o DEBT-002; **fechar o ERR-003 só
  se o dono aceitar de forma explícita a limitação residual**, e essa decisão é dele · Cobre: D7 ·
  Teste: `verify.sh full` (60 min)

## Rastreabilidade
Requisitos vêm do ADR 0005. D1 divisor (aspas, separadores, tokens, redirecionamentos) · D2 subcomando pulando
flags · D3 wrappers e subshell · D4 falha fechada · D5 regras da opção B mantidas · D6 testes atuais não mudam de
resultado; se algum precisar mudar, a mudança é justificada no commit e no plano (como no ADR) · D7 docs e dívida.

| Requisito | Task | Teste |
|-----------|------|-------|
| D1 | T1–T4, T7b, T7e, T8 | divisor.test.sh (separadores, aspas, tokens, redirecionamentos, lexer, desempenho); protect-merge.test.sh (achados) |
| D2 | T5, T8, T10 | divisor.test.sh › subcomando; protect-merge.test.sh; protect-push.test.sh |
| D3 | T6, T7c | divisor.test.sh › wrappers |
| D4 | T3, T7, T7b, T7d | divisor.test.sh › falha fechada, lexer |
| qualidade (ADR, Consequências) | T7e, T7f | divisor.test.sh › desempenho; divisor.test.sh inteiro (refatoração) |
| D5 | T9a, T9b | protect-merge.test.sh (seção expansões) |
| D6 | T9a, T9b, T10, T11a, T11b | os 3 `*.test.sh` dos hooks |
| D7 | T0, T12 | verify.test.sh; `verify.sh full` |

Lacuna declarada: a parte de documentação do D7 (T12) não tem teste próprio, só o `verify.sh full`.
