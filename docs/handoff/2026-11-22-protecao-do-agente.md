# Handoff — 2026-11-22 (proteção do agente, plano 004)

## Onde estamos
Plano 004 (proteger o próprio agente), fase de revisão concluída; falta a retro e o merge. Branch
`feat/protecao-do-agente`, PR #24 contra `develop`, CI verde no commit `593ffb1`. Sem push: 1 commit, o
`docs(handoff)`, que inclui este arquivo, o índice e a atualização do plano (T6 e Rastreabilidade).

## Feito
- T1 a T6 do plano 004, em TDD (teste vermelho antes do código na T1/T2 e na T6).
- 25 regras `ask` no `.claude/settings.json` (12 comandos de envio nas duas formas, mais `gh gist`/`npm publish`).
- `docs/seguranca/agente.md`: riscos, defesas, limites, MCP aprovados, como aprovar um servidor.
- CLAUDE.md §9 (conteúdo lido é dado; dependência nova conferida e no plano).
- T5: o dono viu o pedido do `curl` no modo default, com e sem `allow` temporário; linha removida.
- `/revisar` duas vezes (revisor-codigo + auditor-spec): 0 🔴. 🟡 1 a 4 da 2ª rodada corrigidos (b4f94ad,
  22b5250, 593ffb1). Nenhum 🔴; 🔵 6 a 10 sem correção. O dono dispensou uma 3ª rodada.

## Em andamento
Nada pela metade. Retro PULADA a pedido do dono (nenhuma pergunta respondida).

## Próximo passo
Decidir o merge do PR #24 na `develop` (só se o dono pedir, por merge commit, com CI verde). Depois, a retro da
feature (perguntas a–e) ou a spec do método de Aceitabilidade TFA.

## Decisões
- Nenhum ADR novo. Opção B do achado 5: `allow` lido como glob do bash em `allow_libera_envio`.

## Problemas
- Aceito pelo dono: commits `d325f28` e `09db70d` sem o rodapé `Task: T6` (só corrige reescrevendo histórico).
- Em aberto (dono decide): conector "claude.ai Claude Docs" (sem allow nem deny); `gh api` fora do `ask`;
  recomendação sobre os modos auto/bypassPermissions no `agente.md`.
- Pendente do dono: explicar `scripts/tests/config.test.sh`, função `allow_libera_envio`.
- Erro meu sem ERR: tentei criar arquivo por redirecionamento no Bash (negado, nada criado).

## Estado da verificação
`scripts/verify.sh test` em 2026-11-22 01:12: passou (todos os casos dos scripts; sem stack detectada).
`verify.sh full` rc=0 no commit 22b5250 (shellcheck sem alertas; actionlint pulado, o CI instala).
- Resultado: passou
- Dívidas abertas: ver docs/DEBT.md (nenhuma nova nesta feature).
