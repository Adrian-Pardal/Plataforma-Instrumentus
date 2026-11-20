# Dívida técnica

Tudo que foi adiado de propósito. Teste desativado ou com `.only` exige entrada aqui.
Cada item tem um ID `DEBT-NNN`. Ao quitar, mude o status para "Quitada" (não apague).

| ID | Descrição | Onde | Motivo | Quitar quando | Status |
|----|-----------|------|--------|---------------|--------|
| DEBT-001 | O CI não instala o lefthook: o `lefthook validate` (`config.test.sh`) e o `lefthook.test.sh` são pulados lá | `.github/workflows/ci.yml` (job `verificar`), `scripts/tests/config.test.sh`, `scripts/tests/lefthook.test.sh` | Instalar exige conferir o método na doc, fixar a versão e atualizar `docs/help`; ficou fora do PR #7, que só tem testes | PR `chore/ci-lefthook`: instalar o lefthook (versão fixada) no job `verificar` e atualizar `docs/help` (`ci.md`, `instaladas.md`) | Aberta |
