# Plano: divisor de comandos compartilhado para os hooks

- **Spec:** nenhuma. A fonte dos requisitos é o [ADR 0005](../adr/0005-divisor-de-comandos-para-os-hooks.md)
  (Decisão, itens 1 a 4) e os achados do [ERR-003](../erros/ERR-003-protect-merge-analise-de-texto.md).
  Exceção autorizada pelo dono em 2026-11-20 (a skill `planejar` exige spec Aprovada).
- **Status:** Aprovado
- **Data:** 2026-11-20

## Visão técnica
Um arquivo de funções em bash, `.claude/hooks/lib/divisor.sh`, carregado por `source` nos hooks. Ele varre o
comando UMA vez, caractere a caractere, com um estado (normal, aspa simples, aspa dupla, escape), e entrega o
resultado por variáveis globais (contrato A, o mesmo estilo de `TOK` que os hooks já usam):
- `dividir_comando "$CMD"` → `SEGMENTOS`: um por comando; separadores `&`, `&&`, `||`, `;`, `|`, `|&` e quebra
  de linha fora de aspas.
- `tokenizar_segmento "$SEG"` → `TOK` (sem aspas), `TOK_CITADO` (1 se o token tinha aspas: texto citado nunca
  vira operador nem opção), `ININTERPRETAVEL` e `MOTIVO`.
- `separar_redirecionamentos` → tira de `TOK` os redirecionamentos e o alvo, e deixa `REDIR_ALVOS` (o
  `protect-files` usa).
- `achar_subcomando PROG` → `SUB` e `ARGS`, pulando flags globais. Há uma tabela de flags que levam valor
  (gh: `-R`, `--repo`, `--hostname`; git: `-C`, `-c`, `--git-dir`, `--work-tree`, `--namespace`); flag
  desconhecida é tratada como booleana, e a regra de forma da opção B continua como rede extra.
- `desembrulhar` → entra em `env`, `command`, `xargs` sem flags e subshell `( )`. `sh -c`, variáveis e aliases
  ficam fora do alcance.
Falha fechada: aspas abertas, `$(` ou crase deixam `ININTERPRETAVEL=1`, e o hook bloqueia se o texto cru do
segmento contém o nome de um programa protegido (`gh`, `git`); a regra exata é fixada com teste na T7.
O divisor não bloqueia nada: cada hook decide. A migração é em 3 PRs, um hook por vez, e os testes atuais dos
hooks (`scripts/tests/*.test.sh`) são a rede de segurança: nenhum muda de resultado.

## Modelo de dados
Não se aplica.

## Interfaces
As funções acima, entre `lib/divisor.sh` e os hooks (contrato interno). Entradas: o texto do comando. Saídas:
as variáveis globais. Erros: `ININTERPRETAVEL` e `MOTIVO`, nunca `exit` dentro do divisor.

## Decisões
- ADR 0005: divisor próprio em bash, compartilhado, com falha fechada.
- Contrato por variáveis globais (opção A, 2026-11-20): estilo atual dos hooks e sem subshell.

## Riscos
- Migração: os 3 hooks tratam aspas e redirecionamento de formas diferentes → regressão. Reduzir: um hook por
  PR; rodar os testes atuais antes e depois; comparar o `rc` em um conjunto de comandos (como no refactor do #8).
- Tabela de flags com valor incompleta → subcomando errado. Reduzir: flag desconhecida = booleana, regra de
  forma mantida, testes com as formas reais (`gh -R x pr merge`, `gh pr -R x merge`, `gh --paginate=true api`).
- É uma aproximação do shell: variáveis, `sh -c`, aliases e `cd` não são resolvidos. Reduzir: falha fechada onde
  dá; o resto segue como limitação (o DEBT-002 é reduzido, não quitado).
- Falsos bloqueios novos pela falha fechada. Reduzir: só bloquear se o segmento tem o nome de um programa
  protegido; os casos aceitos viram testes.
- Estado global vazando entre segmentos. Reduzir: cada função zera suas variáveis; teste com dois segmentos.
- `protect-files` usa `compgen -G`, `grep` e `sed`: migrar só o ramo Bash (T11); Edit e Write não mudam.
- Sem biblioteca externa: nada a confirmar no Context7 (só bash 5.2, com `read -ra`, `[[ =~ ]]` e arrays,
  que os hooks já usam). Skills de apoio (modelagem-dominio, modelagem-dados, diagrama, contrato-api,
  casos-de-teste): não se aplicam. `modelagem-ameacas` valeria (é um hook de segurança), mas a skill não existe:
  pendência.

## Tasks
Formato: `T<n> [tag] — descrição · Cobre: D<n> · Teste: <onde>`. Tag `[infra]`, porque a stack é "a definir".
Cada commit leva o rodapé `Task: T<n>`. Testes novos em `scripts/tests/divisor.test.sh`.
Marque com 🎓 as tasks que você faz à mão.

PR 1 (divisor + `protect-merge`):
- [ ] 🎓 T1 [infra] — `lib/divisor.sh` e `dividir_comando`: separa por `&`, `&&`, `||`, `;`, `|`, `|&` e quebra
  de linha, ignorando o que está entre aspas (versão simples) · Cobre: D1 · Teste: divisor.test.sh › separadores (60 min)
- [ ] T2 [infra] — aspas numa só passada: `"a|b"`, `'x;y'`, apóstrofo dentro de aspas duplas, escape `\` ·
  Cobre: D1 · Teste: divisor.test.sh › aspas (90 min)
- [ ] T3 [infra] — `tokenizar_segmento` com `TOK_CITADO`; aspas sem fechar marcam `ININTERPRETAVEL` ·
  Cobre: D1, D4 · Teste: divisor.test.sh › tokens (60 min)
- [ ] T4 [infra] — `separar_redirecionamentos` (`>`, `>>`, `<`, `2>&1`, `&>`, `>|`, colados a palavra e a texto
  citado), com os casos do ERR-001 e ERR-002 · Cobre: D1 · Teste: divisor.test.sh › redirecionamentos (90 min)
- [ ] T5 [infra] — `achar_subcomando` para `gh` e `git`, pulando flags globais · Cobre: D2 ·
  Teste: divisor.test.sh › subcomando (90 min)
- [ ] T6 [infra] — `desembrulhar`: `env`, `command`, `xargs` sem flags e subshell · Cobre: D3 ·
  Teste: divisor.test.sh › wrappers (60 min)
- [ ] T7 [infra] — falha fechada: `$(`, crase e aspas abertas; fixar a regra do nome de programa protegido ·
  Cobre: D4 · Teste: divisor.test.sh › falha fechada (60 min)
- [ ] T8 [infra] — testes **vermelhos** dos achados do PR #8 em `protect-merge.test.sh`: `&` solto, `|&`, flag
  antes de `api`/`alias`, `gh api` por expansão · Cobre: D1, D2 · Teste: protect-merge.test.sh › achados abertos (60 min)
- [ ] T9 [infra] — migrar `protect-merge.sh` para o divisor, apagar a lógica antiga de corte e de aspas, manter as
  regras da opção B · Cobre: D5, D6 · Teste: protect-merge.test.sh inteiro (90 min)

PR 2 (`protect-push`):
- [ ] T10 [infra] — migrar `protect-push.sh` e testar a suspeita do `>|` · Cobre: D6 ·
  Teste: protect-push.test.sh (90 min)

PR 3 (`protect-files` e docs):
- [ ] T11 [infra] — migrar o ramo Bash de `protect-files.sh` · Cobre: D6 · Teste: protect-files.test.sh (90 min)
- [ ] T12 [infra] — docs: `merge-de-pr.md`, `testes-dos-hooks.md`, reescrever o DEBT-002, atualizar o ERR-003 ·
  Cobre: D7 · Teste: `verify.sh full` (60 min)

## Rastreabilidade
Requisitos vêm do ADR 0005. D1 divisor (aspas, separadores, tokens, redirecionamentos) · D2 subcomando pulando
flags · D3 wrappers e subshell · D4 falha fechada · D5 regras da opção B mantidas · D6 testes atuais não mudam de
resultado · D7 docs e dívida.

| Requisito | Task | Teste |
|-----------|------|-------|
| D1 | T1–T4, T8 | divisor.test.sh (separadores, aspas, tokens, redirecionamentos); protect-merge.test.sh (achados) |
| D2 | T5, T8 | divisor.test.sh › subcomando; protect-merge.test.sh |
| D3 | T6 | divisor.test.sh › wrappers |
| D4 | T3, T7 | divisor.test.sh › falha fechada |
| D5 | T9 | protect-merge.test.sh (seção expansões) |
| D6 | T9, T10, T11 | os 3 `*.test.sh` dos hooks |
| D7 | T12 | `verify.sh full` |

Lacuna declarada: D7 é documentação e não tem teste próprio, só o `verify.sh full`.
