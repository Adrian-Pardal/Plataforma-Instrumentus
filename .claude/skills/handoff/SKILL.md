---
name: handoff
description: Cria o handoff da sessão em docs/handoff/AAAA-MM-DD-<assunto>.md pelo template, com onde estamos, feito, em andamento, próximo passo concreto, ADRs criados, problemas e o resultado de scripts/verify.sh test rodado na hora, além da branch e dos commits sem push. Use ao encerrar uma sessão de trabalho. Não use para planejar, implementar ou registrar erro, e nunca para afirmar que está tudo funcionando sem a saída do verify. No fim, também gera o registro da sessão para a pesquisa em docs/estudo-de-caso/sessoes/AAAA-MM-DD.md (feito, intervenções humanas, bloqueios do harness, erros da IA, testes).
disable-model-invocation: true
---

# Handoff

## Conceito (para você, dono do projeto)
O Claude não lembra de uma sessão para outra. O handoff é o bilhete que
deixamos para a próxima: onde paramos, o que falta e qual é o primeiro
passo. Um bom handoff deixa a próxima sessão começar em 2 minutos, e só
afirma o que foi comprovado agora.

## Passos
1. Pegue a data de hoje com `date +%F` (não adivinhe). O <assunto> é uma
   expressão curta em minúsculas, com hífens, escolhida com o dono.
2. Leia CLAUDE.md (§2, fluxo), o último handoff em docs/handoff/, a spec e o
   plano em andamento, docs/DEBT.md e docs/erros/README.md.
3. Levante o estado do git e mostre a saída:
   - `git branch --show-current`
   - `git status -sb` (alterações não commitadas)
   - `git log @{u}..HEAD --oneline` (commits sem push). Se a branch não tem
     upstream, diga isso e que todos os commits dela estão sem push.
4. Rode `scripts/verify.sh test` AGORA e MOSTRE a saída. Registre o resultado
   (passou ou falhou) com data e hora. Se falhou, escreva "falhou" e a causa
   conhecida; não corrija durante o handoff sem o dono pedir.
5. Monte docs/handoff/AAAA-MM-DD-<assunto>.md pelo template:
   - Onde estamos: feature, fase do fluxo, branch atual e commits sem push.
   - Feito: o concluído, com commits.
   - Em andamento: o ponto EXATO (arquivo, teste, fase do TDD).
   - Próximo passo: a primeira ação concreta (comando, task ou arquivo).
   - Decisões: ADRs criados nesta sessão, com link.
   - Problemas: bloqueios, ERR-NNN, dúvidas em aberto.
   - Estado da verificação: a saída do passo 4, resumida.
6. Mantenha em ~40 linhas. Corte o que a próxima sessão não precisa.
7. MOSTRE o arquivo inteiro e espere aprovação antes de salvar.
8. Atualize docs/handoff/README.md (índice com data, assunto e link). Se não
   existir, proponha o conteúdo, mostre e crie após aprovação.
9. Siga para o registro da pesquisa (abaixo). Ao fim, pergunte se o dono quer
   commitar o handoff e o registro. Não faça push sem pedido.

## Registro da pesquisa (ADR 0007)
Gere docs/estudo-de-caso/sessoes/AAAA-MM-DD.md (se o dia já tem um, use -2, -3). Só contagens e uma linha por item:
nada de trechos de conversa, segredos, conteúdo de arquivo ou valores de variáveis.
10. INÍCIO da sessão: a primeira linha `"tipo":"sessao"` de hoje em .claude/pesquisa/eventos.jsonl
    (`jq -r 'select(.tipo=="sessao") | .quando' .claude/pesquisa/eventos.jsonl | grep "^$(date -u +%F)" | head -1`).
    Mostre ao dono e use o horário que ele confirmar. Sem o arquivo, diga isso; não invente.
11. Levante, mostrando a saída de cada comando:
    - Feito: `git log --since=<início> --format='%h %s'`.
    - Bloqueios: `jq -r 'select(.tipo=="bloqueio" and .quando >= "<início>") | [.quando,.hook,.motivo,.alvo] | @tsv' .claude/pesquisa/eventos.jsonl`.
    - Erros: ERR-NNN tocados (`git log --since=<início> --name-only --format= -- docs/erros`), com a categoria; destaque `erro-ia`.
    - Testes: o resultado do passo 4 (não rode de novo).
12. Tabela de intervenções humanas: uma linha por intervenção do dono NESTA conversa, com o tipo de
    docs/estudo-de-caso/protocolo.md §3 (decisão, aprovação, correção, operação manual, desbloqueio, aprendizado;
    empate: vale a que mudou o resultado). Na dúvida, marque `?`. Você só vê a conversa atual: avise se ela foi compactada.
13. Comece o arquivo com o cabeçalho de `docs/templates/cabecalho.md` (titulo "Sessão AAAA-MM-DD", mantido-por
    /handoff). Depois, as seções: Feito · Intervenções humanas (`# | o que o dono fez | tipo`) · Bloqueios do harness ·
    Erros da IA · Testes · Minha percepção (só o título e `_a preencher_`). MOSTRE o arquivo inteiro, com a
    tabela em destaque: o dono confirma ou corrige antes de salvar. Salve só após o ok.

## Proibido
- Escrever "tudo funcionando", "passou" ou equivalente sem a saída de
  scripts/verify.sh test rodado na hora.
- Reaproveitar o resultado de uma execução anterior.
- Omitir alterações não commitadas ou commits sem push.
- Inventar estado, causa ou próximo passo vago ("continuar o trabalho").
- Passar de ~40 linhas ou incluir segredos.
- Salvar sem mostrar o conteúdo e receber aprovação.
- Criar ou editar arquivos por Bash (cat, echo, sed, tee, redirecionamento).
- No registro da pesquisa: inventar intervenção, preencher "Minha percepção" ou gravar conteúdo de conversa ou segredo.

## Como verificar
- O arquivo docs/handoff/AAAA-MM-DD-<assunto>.md existe e segue o template.
- A data bate com `date +%F` e o arquivo tem ~40 linhas ou menos.
- "Onde estamos" traz a branch e os commits sem push (ou "nenhum").
- "Estado da verificação" traz a saída real do verify, com data e hora.
- "Próximo passo" é uma ação concreta que alguém executa sem perguntar.
- docs/handoff/README.md lista o novo handoff.
- O registro da pesquisa existe, a tabela de intervenções foi confirmada e "Minha percepção" está vazia.
