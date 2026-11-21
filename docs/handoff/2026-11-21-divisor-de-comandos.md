# Handoff — 2026-11-21 (divisor-de-comandos)

## Onde estamos
Feature: divisor de comandos compartilhado para os hooks (ADR 0005, plano
`docs/plans/001-divisor-de-comandos.md`, Aprovado e reaprovado em 2026-11-21). Fase: implementação em TDD
(PR 1a, só o `divisor.sh`; nenhum hook o usa ainda). Branch `feat/divisor-de-comandos`, em sincronia com
`origin` (commits sem push: nenhum). PR 1a NÃO aberto.
Alteração não commitada: `scripts/tests/divisor.test.sh` (+30 linhas) = o VERMELHO da T7e.

## Feito (T0–T7d, plano marcado até a T7d; último commit c517626)
- T0–T7: divisor, tokenizador, redirecionamentos, wrappers, falha fechada.
- `/revisar` da branch deu REPROVADO (7 🔴 fail-open). Corrigidos nesta sessão:
  - T7b: lexer (comentário `#`, `$'...'`, `<(...)`, heredoc com aspas parciais, `<<` em aritmética).
  - T7c (5c963d4): wrappers timeout/nice/stdbuf/ionice/setsid/exec/noglob, palavras reservadas, `case`,
    eval/watch/coproc/parallel/`find -exec`, `env -iS`, `)` sobrando.
  - T7d (c80d4bd): falha fechada acha ação protegida em qualquer posição; subcomando que não é nome simples
    bloqueia; `PROTEGIDOS` vazia bloqueia. Os 22 casos da revisão agora barram.

## Em andamento
T7e (desempenho), fase VERMELHO escrita e NÃO commitada em `scripts/tests/divisor.test.sh` (`caso_pipeline`,
4 casos de 20 KB). Falham pelo tempo, como esperado: ~5,6 s (aspas), ~5,6 s (heredoc em aspas),
~7,2 s (palavra única) contra limite de 2 s. O heredoc fora de aspas passa (19 ms).
Medição (scratchpad `micro.sh`): `${s:i:1}` é o custo quadrático (14 KB = 214 ms; 28 KB = 754 ms);
`+=` e `read -N1` são lineares. Caminho provável: trocar a indexação por leitura linear nos laços.

## Próximo passo
Commitar o vermelho da T7e: `git add scripts/tests/divisor.test.sh` e
`test(divisor): desempenho do pipeline com segmento de 20 KB` com rodapé `Task: T7e`. Depois o verde
(remover a indexação quadrática no lexer/tokenizador), `verify.sh test` e `full`, marcar T7e, push.
Seguem T7f (complexidade), nova `/revisar` (só o dono roda) e decisão do dono sobre abrir o PR 1a.

## Decisões
Nenhum ADR novo. Opção A do plano para `$(...)`: bloquear se o texto mostra ação protegida; falso positivo
aceito. Falso bloqueio conhecido: `git-lfs push` (🔵, ainda não tratado).

## Problemas
- Eu apresentei o divisor como pronto e a revisão achou 7 brechas; corrigidas em T7b–T7d.
- Limites aceitos no ADR: `sh -c`, `ssh h "git push"`, variáveis, aliases.
- `protect-push` ainda tem o furo `--config-env`/`--attr-source` até a T10.
- Abertos: DEBT-001 (lefthook no CI), DEBT-002; método de registro de erros (pedido original) não feito;
  CLAUDE.md com 62 linhas (limite 60); PR #5 do dependabot; branches antigas locais e remotas.

## Estado da verificação
`scripts/verify.sh test` em 2026-11-21 00:12:03: FALHOU (rc=1) — "1 teste(s) de script falharam".
Causa conhecida: os 3 casos vermelhos da T7e, ainda sem código. Antes da T7e, em T7d, `test` e `full`
passavam (rc=0, 301 casos).
