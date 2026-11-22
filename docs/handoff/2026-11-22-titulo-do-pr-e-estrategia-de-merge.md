# Handoff — 2026-11-22 (título do PR, estratégia de merge, ADR 0006)

## Onde estamos
Planos 002 (registro de erros) e 003 (título do PR e estratégia de merge) CONCLUÍDOS e mergeados na `develop`
(PRs #16 a #22; último: #22, commit de merge 251b68f, 2026-11-22 03:31 UTC). O plano 001 (divisor de
comandos) segue PAUSADO. O próximo trabalho do produto é a spec do método de Aceitabilidade TFA.

## Feito
- Plano 002 (registro de erros): ver o handoff `2026-11-21-registro-de-erros.md` (PRs #16 e #17).
- Estratégia de merge configurada no GitHub (`gh api -X PATCH`, campos conferidos na doc via Context7): só
  merge commit (squash e rebase desligados), título do commit de merge = título do PR, corpo = descrição do PR,
  branch do PR apagada depois do merge. Conferido nos merges seguintes: o commit sai como
  `feat(ci): job que confere o título do PR (#18)` e a branch do PR some da remota.
- Etiquetas criadas: `erro-ia`, `ambiente`, `producao`, `incidente` (a `bug` já existia).
- Plano 003 (PRs #18, #19, #20):
  - T1/T2: `scripts/validar-titulo-pr.sh` + `scripts/tests/validar-titulo-pr.test.sh` (29 casos), TDD.
  - T3: job `titulo-do-pr` no `ci.yml` (`pull_request`, tipos `opened`, `edited`, `synchronize`, `reopened`;
    o título entra só por `env:`). Visto no PR #18: passou com título válido e FALHOU, com a mensagem esperada,
    com título inválido.
  - T4: help (página `titulo-do-pr.md`, `ci.md`, `merge-de-pr.md` com a configuração da estratégia de merge).
  - T5: `titulo-do-pr` exigido na proteção da `develop` e da `main` (`PATCH .../protection/required_status_checks`,
    lista `seguranca`, `verificar`, `titulo-do-pr`, `strict: true`); `protecao-de-branches.md` atualizado.
  - T6: ADR 0006 "Estratégia de merge: merge commit em tudo e tag por versão" (ACEITO pelo dono; squash e rebase
    descartados, com o motivo de cada um; complementa o ADR 0003).
  - T7: regra no CLAUDE.md §6 (fundida na linha do merge de PR; segue com 62 linhas).
- `/revisar` (skill) rodada duas vezes no PR #18, com os agentes `revisor-codigo` e `auditor-spec`: sem 🔴.
  Corrigidos 2 🟡 (condição morta no script e falta de teste para descrição só de espaços) e vários 🔵.
- Teste de desempenho do divisor corrigido (PR #22): cada caso vale a melhor de até 3 execuções
  (`melhor_de_3` e `relatar_desempenho` em `scripts/tests/divisor.test.sh`), com os limites intactos
  (3000 ms e 2000 ms). `/revisar` rodada (sem 🔴; achados corrigidos: duplicação, texto da tolerância,
  mensagem de falha e comentário). Prova por mutação nos dois caminhos: com os limites baixados para 30 ms e
  200 ms, ambos ficaram vermelhos após 3 execuções.
- Limpeza: branches locais mergeadas apagadas; remotas apagadas pelo dono (e pela exclusão automática).

## Em andamento
Nada pela metade.

## Próximo passo
1. O dono abre GitHub → Issues → New issue e confere os 3 formulários (Bug, Erro da IA, Ambiente). É a única
   parte do plano 002 sem prova; depois, atualizar a linha "ainda não foi feita" de `registro-de-erros.md`.
2. Spec do método de Aceitabilidade TFA (CLAUDE.md §2: sem spec aprovada, nada de código). Perguntas ao dono:
   quais outros métodos virão depois do TFA? Escala e relatório são próprios de cada método ou compartilhados?

## Decisões
- ADR 0006 (merge commit em tudo; título do PR em Conventional Commits; nunca reescrever histórico já enviado;
  tag anotada SemVer `vMAJOR.MINOR.PATCH` a cada merge `develop → main`, a primeira `v0.1.0`, criada pelo dono).
- Plano 003: o job fica no `ci.yml` (efeito aceito: `edited` reexecuta o CI inteiro, inclusive ao editar o corpo
  do PR); `!` e `reopened` entram por decisão técnica; a regex é a do lefthook, mas recusa descrição só de espaços
  (o lefthook a aceita); só a 1ª linha do título conta.
- A opção (b) da revisão do PR #16 (`--search` trocado por `--label` + `--jq`) NÃO foi feita: o atraso do índice de
  busca não está confirmado.

## Problemas
- RESOLVIDO no PR #22: o teste de desempenho do divisor era frágil (no `verify.sh full` do PR #19, 2091 ms
  contra o limite de 2000 ms; o normal é 1,0 a 1,4 s). Troca declarada: com "melhor de até 3 execuções", uma
  regressão só um pouco acima do limite pode passar numa das execuções; a quadrática de verdade (5,5 s contra
  3 s) continua reprovando. Só a regressão grande foi provada.
- O stderr do `divisor.test.sh` mostra `divisor.sh: line 758: PROTEGIDOS: unbound variable`. Já existia: vem do
  caso "PROTEGIDOS ausente" (T7d), não afeta o resultado e não foi mexido.
- PR #5 do dependabot (`setup-java 6.3.0`) foi aberto antes do job `titulo-do-pr`; pode precisar de
  `gh pr update-branch 5`. O `mergeStateStatus` dele ainda dizia `CLEAN` depois da mudança de proteção; não sei se
  o GitHub só recalcula depois.
- Não verificado: se o `protect-push` barra o envio de tags; se a exclusão automática de branch respeita a
  proteção da `develop` (não foi testado); se o `gh issue create --template` aceita formulários YAML.
- Limites aceitos do `titulo-do-pr`: o job executa o script do próprio PR; uma quebra de linha no título passa.
- Abertos: CLAUDE.md com 62 linhas (limite 60 citado nas skills); DEBT-001, DEBT-002, DEBT-003; branch remota
  `docs/adr-divisor-de-comandos` (PR #9, fechado; só o dono apaga); branch local `feat/protect-merge-divisor`
  (commit vermelho da T8 do plano 001, nunca enviado); `actionlint` não instalado localmente (o CI o instala);
  as skills `solid`, `clean-code` e `revisao-seguranca` que a `/revisar` cita não existem.
- Processo: ao atualizar o corpo de um PR com `gh pr edit`, o CI roda de novo e cancela a execução do push;
  as linhas `fail`/`cancelled` que aparecem em `gh pr checks --watch` podem ser dessa execução cancelada.

## Estado da verificação
`scripts/verify.sh full` rodou com rc=0 no último commit de código do PR #22 (todos os casos dos testes dos
scripts passaram, shellcheck sem alertas em 22 arquivos; actionlint pulado local e verde no CI). CI do PR #22:
`seguranca`, `titulo-do-pr` e `verificar` verdes.
- Resultado: passou
- Testes desativados/dívidas abertas: ver docs/DEBT.md
