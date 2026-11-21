# Dívida técnica

Tudo que foi adiado de propósito. Teste desativado ou com `.only` exige entrada aqui.
Cada item tem um ID `DEBT-NNN`. Ao quitar, mude o status para "Quitada" (não apague).

| ID | Descrição | Onde | Motivo | Quitar quando | Status |
|----|-----------|------|--------|---------------|--------|
| DEBT-001 | O CI não instala o lefthook: o `lefthook validate` (`config.test.sh`) e o `lefthook.test.sh` são pulados lá | `.github/workflows/ci.yml` (job `verificar`), `scripts/tests/config.test.sh`, `scripts/tests/lefthook.test.sh` | Instalar exige conferir o método na doc, fixar a versão e atualizar `docs/help`; ficou fora do PR #7, que só tem testes | PR `chore/ci-lefthook`: instalar o lefthook (versão fixada) no job `verificar` e atualizar `docs/help` (`ci.md`, `instaladas.md`) | Aberta |
| DEBT-002 | `protect-merge` não enxerga `\|`/`;`/`&&`/`\|\|` dentro de aspas, nem apóstrofos pareando errado, glob, quebra de linha em aspas, `cd` para outra pasta, `GH_REPO` exportado em outro segmento e `gh` fora do início do segmento (`env`, `command`, `xargs`, `sh -c`, subshell), alias que já exista, config apontada por `GH_CONFIG_DIR`/`XDG_CONFIG_HOME`, `&` solto e flag antes de `api`/`alias` (ERR-003, opção C aceita) | `.claude/hooks/protect-merge.sh`, `scripts/tests/protect-merge.test.sh` | O dono aceitou a limitação em 2026-11-20; as expansões do shell já são bloqueadas (opção B). Corrigir o resto exige um divisor que respeita aspas, que é decisão de arquitetura; o `ask` só cobre comandos que começam com `gh pr merge`; nos demais, a barreira é o dono ler o comando | Opção A (divisor de comandos próprio), decidida pelo dono em 2026-11-20: ADR, plano e PR próprio, com teste vermelho antes | Aberta |
