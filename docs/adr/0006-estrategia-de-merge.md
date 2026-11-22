# ADR 0006: Estratégia de merge: merge commit em tudo e tag por versão

- **Status:** Aceito
- **Data:** 2026-11-21
- **Substitui:** nenhum (complementa o ADR 0003)

## Contexto
- O ADR 0003 já manda `gh pr merge --merge` e o hook `protect-merge` barra `--squash`, `--rebase`, `--admin` e
  `--auto`. Mas, até 2026-11-21, o GitHub ainda aceitava squash e rebase pelo site.
- O fluxo é TDD (ADR 0002): cada task gera commits na ordem teste vermelho, depois código, com o rodapé
  `Task: Tn`. A `/revisar` (agente `auditor-spec`) confere pelos commits se o teste veio antes do código.
- Os commits já passam pelo `commit-msg` do lefthook (Conventional Commits). O título do PR passou a ser
  conferido pelo job `titulo-do-pr` (plano 003, PR #18), exigido na proteção da `develop` e da `main`.
- Em 2026-11-21 o repositório foi configurado: só merge commit (squash e rebase desligados), título do commit
  de merge = título do PR, corpo = descrição do PR, branch do PR apagada depois do merge. O primeiro merge
  nessa configuração (PR #18) gerou o commit `feat(ci): job que confere o título do PR (#18)`.
- Handoffs, planos e registros de erro citam commits e PRs por SHA e número.
- Não existe nenhuma tag no repositório. A `main` é só do dono e fica protegida.

## Decisão
1. Todo merge de PR (para a `develop` e da `develop` para a `main`) é por merge commit. Squash e rebase ficam
   desligados no repositório, além de barrados pelo `protect-merge`.
2. O título do PR segue Conventional Commits (job `titulo-do-pr`) e vira o título do commit de merge; a
   descrição do PR vira o corpo.
3. Histórico já enviado não se reescreve (amend, rebase ou force push).
4. Cada merge da `develop` para a `main` recebe uma tag anotada SemVer `vMAJOR.MINOR.PATCH` (a primeira será
   `v0.1.0`), criada pelo dono no commit de merge da `main`.

## Alternativas
1. **Squash merge** — prós: um commit por PR; histórico linear e curto · contras: apaga os commits da branch,
   então a ordem teste-antes-do-código e os rodapés `Task:` somem da `develop`, e a `/revisar` deixa de poder
   conferir o TDD depois do merge; a mensagem única mistura várias tasks.
   **Descartada** porque o TDD verificável por commit é regra do projeto (ADR 0002).
2. **Rebase merge** — prós: histórico linear, sem commit de merge · contras: recria os commits com SHAs novos
   na `develop`, ou seja, reescreve o que já foi enviado na branch do PR; os SHAs citados em PRs, handoffs e
   erros deixam de existir na `develop`; perde a fronteira do PR.
   **Descartada** porque contraria "nunca reescrever histórico enviado" e a rastreabilidade por SHA.
3. **Merge commit, sem tags** — prós: simples, nada novo para manter · contras: a `main` não tem marco do que
   foi entregue; voltar a um estado só pelo SHA do merge.
   **Descartada** porque o dono quer um marco por versão na `main`.
4. **Merge commit + tag SemVer a cada merge `develop → main`** (escolhida) — prós: preserva os commits e a
   fronteira de cada PR; marco legível por versão; `git log --first-parent` mostra um item por PR ·
   contras: histórico não linear e com mais commits; a tag é manual (o dono pode esquecer); o SemVer exige
   decidir o número a cada versão.
   **Recomendada.**

## Consequências
**Positivas:** o histórico preserva a ordem do TDD e os rodapés `Task:`; o título do commit de merge é o do
PR, já conferido; os SHAs citados na documentação continuam valendo; a `main` ganha marcos de versão.

**Negativas:** o histórico não é linear; a qualidade do histórico depende do título do PR (o `titulo-do-pr`
confere o formato, não o sentido); a tag é um passo manual sem automação.

**Daqui para frente:**
- T7 do plano 003: a regra entra no CLAUDE.md.
- Quando a primeira tag for criada, o procedimento ganha página em `docs/help/` (CLAUDE.md §6). Não verifiquei
  se o `protect-push` barra o envio de tags; como a tag é do dono, ele a cria no terminal dele.
- Rever este ADR se o ruído do histórico atrapalhar, ou se a tag precisar ser automática (por exemplo, um
  job no CI).
