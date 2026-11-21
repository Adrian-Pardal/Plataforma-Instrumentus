---
id: ERR-003
titulo: protect-merge libera opção proibida escondida por aspas com | ou ;, e por apóstrofos pareando errado
status: aceito
categoria: bug
severidade: media
detectado-em: revisao
data: 2026-11-20
issue: nenhuma
pr: https://github.com/Adrian-Pardal/Plataforma-Instrumentus/pull/8
recorrencias: 1
---

# ERR-003: protect-merge libera opção proibida escondida por aspas com | ou ;, e por apóstrofos pareando errado

## Sintoma
Com um `gh` que responde `develop`, o hook sai com 0 (libera) em comandos que o shell executaria com `--squash`, `--auto` ou `-s`:
`gh pr merge 1 --merge --body "a|b" --squash`, `--body "a;b" --auto`, `--body 'x||y' --squash`, `--body "a&&b" -s`,
e também com `\--squash`, `$IFS--squash`, `${X}--squash`, `$(echo --squash)`, crases e quebra de linha dentro de aspas.
O mesmo vale para o hook da `develop` (não é regressão).
Também libera quando há apóstrofo ou aspa dentro de duas citações diferentes, por pareamento errado das aspas:
`--body "it's" --squash --subject "x's"`, `... --body "it's" -s --subject "x's"`, `"a'b" --squash "c'd"` e `'a"b' --squash "c"`.
O `printf '[%s] '` mostra que o shell entrega `--squash` ao gh nesses casos. Já passava na `develop`.
Depois da opção B (ver Correção), as expansões (`$(...)`, crase, `\`, `$IFS`, `${X}`) passam a ser bloqueadas; o restante continua liberado.
Também libera (confirmado na 4ª revisão): `env gh pr merge ... --squash`, `sh -c "gh pr merge ... --squash"`, `command gh`, `xargs gh`, subshell (o hook só olha segmentos que começam com `gh`; já passava na `develop`), expansão de chaves (`{--squash,x}`, corrigida com a opção B em `162aca3`), glob (`--s*`, só com um arquivo `--s...` na pasta) e quebra de linha dentro de aspas. Também alias que já exista e config apontada por `GH_CONFIG_DIR`/`XDG_CONFIG_HOME`.
Achados na 7ª revisão (🔴, confirmados com o hook e com o `gh` real, que aceita as flags): `&` solto separa comandos em segundo plano e o hook não o corta (`gh pr view 1 & gh api -X PUT repos/o/r/pulls/12/merge`, `gh auth status & gh api graphql -f query=x`), e uma flag antes de `api` ou `alias` os tira de `TOK[i+1]` (`gh --paginate=true api -X PUT .../merge`, `gh --hostname=github.com api ...`, `gh --clobber=true alias set m 'pr merge --squash'`). Com `merge` literal o hook pega; o contorno vale só para `api` e `alias`. A lógica vem da `develop` (não rodei lado a lado). O `ask` também não os cobre.
Achados na 5ª revisão: `gh -R o/r pr merge 1 --squash` e `gh --repo o/r pr merge 1 --admin` (passam pelo hook **e** pelo `ask`, que só casa comandos que começam com `gh pr merge`), `GH_REPO=o/r gh pr merge 1 --merge` (o hook consulta o PR no repositório da sessão), `cd outra-pasta && gh pr merge ...` (consulta na pasta errada) e `gh alias set pm "pr merge --squash"` seguido de `gh pm 1`. Os três primeiros e o alias foram corrigidos na 6ª rodada (`d778e3a`); o `cd` e um `GH_REPO` exportado em outro segmento ficam como limitação.
Achado na 6ª revisão (🔴): `gh pr -R x merge 12 --squash`, `gh pr --repo x merge 12 --admin` e `gh pr -R x merge 12 --merge` davam rc=0, porque a regra da flag só olhava logo depois do `gh`; o `gh` real aceita `-R` entre `pr` e `merge`, e o `ask` também não casa. Corrigido na 7ª rodada com uma regra de forma (`6508c44`).

## Como reproduzir
1. Criar um `gh` falso no PATH que, para `gh pr view`, imprime `develop` (com um PR real que mira `develop` o resultado é o mesmo).
2. Rodar `jq -n --arg c 'gh pr merge 1 --merge --body "a|b" --squash' --arg d "$PWD" '{tool_name:"Bash",tool_input:{command:$c},cwd:$d}' | .claude/hooks/protect-merge.sh`
3. Sai com 0, quando o correto seria 2. Conferido em 2026-11-20 (hook atual e hook da `develop`).
4. Nos casos de expansão, `printf '[%s] ' \--squash $IFS--squash ${X}--squash "$(echo --squash)"` mostra que o shell entrega `--squash`.

## Causa raiz (5 porquês)
1. Por quê o comando passa? O hook não vê `--squash` como argumento do `gh pr merge`.
2. Por quê? Nos casos de `|`, `;`, `&&` e `||` dentro de aspas, o hook corta o comando nesses caracteres antes de olhar as aspas, e o `--squash` cai num segmento que não começa com `gh`. Nos casos de expansão, o texto do comando não contém `--squash` como token; ele só aparece depois que o shell expande. No caso dos apóstrofos, o laço troca cada citação encontrada e roda a regex de novo sobre o texto já alterado; um `'` ou `"` de dentro de uma citação pareia com a aspa de outra.
3. Por quê o hook não expande? Ele lê só o texto de `tool_input.command`, antes de o shell rodar. Reproduzir aspas, escapes e expansões seria reimplementar um parser de shell.
4. Por quê foi escrito assim? Para ser simples e legível: corta por separadores e confere tokens. Cobre o uso normal do Claude, não comandos escritos para escapar da regra.
5. Por quê ninguém viu? Os testes cobrem opções, destinos e (depois do ERR-002) redirecionamentos, mas nenhum caso tem separador dentro de aspas nem expansão (causa raiz: o hook é análise estática de texto, sem um registro explícito do que ele não consegue ver). Não sei se `protect-push` e `protect-files` têm as mesmas limitações; não foi testado.

## Correção
Decisão do dono em 2026-11-20: opções C + B.
- B (corrigida): `gh pr merge` com `$`, crase, `\` ou `{` no texto é bloqueado (`5b820bc`; o `{` veio em `162aca3`). Custa um falso bloqueio, por exemplo `--body "custa $5"` ou `--body "fix {x}"`; a mensagem sugere `--body-file`. Na 6ª rodada (`d778e3a`) também são bloqueados `GH_REPO`/`GH_HOST` no prefixo e `gh alias set/import`. Na 7ª (`6508c44`) entrou uma regra de forma: a palavra `merge` num comando `gh` só vale como `gh pr merge ...` (opções como `-R` vão depois); ela cobre `gh -R x pr merge` e `gh pr -R x merge` e custa um falso bloqueio (`gh pr view merge`, `gh pr list --search merge`).
- C (aceita como limitação): `|`, `;`, `&&`, `||` dentro de aspas, aspas de tipos diferentes pareando errado, quebra de linha em aspas, glob, `cd outra-pasta && gh pr merge`, `GH_REPO` exportado em outro segmento e `gh` fora do início do segmento (`env`, `command`, `xargs`, `sh -c`, subshell), alias que já exista e config apontada por `GH_CONFIG_DIR`/`XDG_CONFIG_HOME` continuam sem ser vistos. Nos wrappers, a única barreira é você ler o comando antes de aprovar, porque o `ask` não casa com eles.
- A (um divisor de comandos próprio, que respeita aspas e `&`, `;`, `&&`, `||`, `|` e acha o subcomando de forma única, compartilhado pelos hooks): **decidida pelo dono em 2026-11-20**, depois da 7ª revisão seguida que achou algo novo. Vai em PR próprio, com ADR (registrar-adr), plano e TDD (DEBT-002). Até lá, os 2 🔴 da 7ª revisão (`&` solto e flag antes de `api`/`alias`) ficam registrados como limitação da opção C.

## Teste de regressão
`scripts/tests/protect-merge.test.sh`, seção "expansões do shell" (`74d3c2a`): 8 casos vermelhos antes de `5b820bc` (`$(...)`, crase, `\--squash`, `$IFS--squash`, `${X}--squash`, `--body "$(echo x)"`, `$PR` e o falso bloqueio `'custa $5'`) e 3 guardas. Na 4ª revisão: 3 casos vermelhos de `{` (`f55e1e2`: `{--squash,x}`, `--{squash,x}` e o falso bloqueio `"fix {x}"`), corrigidos em `162aca3`. Na 5ª revisão: 7 casos vermelhos (`3ddf376`: `gh -R x pr merge` em 3 formas, `GH_REPO=`, `GH_HOST=`, `gh alias set` e `gh alias import`) e 4 guardas, corrigidos em `d778e3a`. Na 6ª revisão: 4 casos vermelhos (`eec3709`: `gh pr -R x merge` em 3 formas e o falso bloqueio `gh pr view merge`) e 2 guardas, corrigidos em `6508c44`. Os casos da opção C não têm teste, pois a limitação é aceita.

## Prevenção
O `permissions.ask` do `settings.json` (`Bash(gh pr merge *)`) pede confirmação do dono, mas só casa comandos que começam com `gh pr merge`. Não cobre `env gh`, `command gh`, `xargs gh`, `sh -c` nem subshell; nesses casos a única barreira é o dono ler o comando antes de aprovar. O hook é a segunda camada. A lista completa do que o hook não vê está no cabeçalho de `protect-merge.sh` (é a lista canônica; as outras a repetem) e na página `docs/help/ferramentas/merge-de-pr.md`. Se voltar (2ª ocorrência), propor regra automática (ver skill registrar-erro, passo 7).

## Lição para a IA
Um hook que lê o texto do comando é rede de segurança, não garantia. Ao descrevê-lo, dizer também o que ele não enxerga, e não afirmar que "não libera nada". Também não dizer que o `ask` cobre tudo: o padrão só casa o início do comando (esse exagero apareceu ao recomendar a opção C).

## Ocorrências
- 2026-11-20 — achado na 2ª revisão do PR #8, rodando o hook com um `gh` falso; já existia na `develop`.
- 2026-11-20 — na 3ª revisão, achado o caso dos apóstrofos. O dono decide C + B; B corrigida em `5b820bc`.
- 2026-11-20 — na 4ª revisão, achados o `{` (expansão de chaves) e a lista de limitações incompleta; corrigidos em `162aca3` e `ff24840`.
- 2026-11-20 — na 5ª revisão, achados `gh -R x pr merge`, `GH_REPO`, `cd` e `gh alias`, além do exagero sobre o `ask`; corrigidos em `d778e3a` (o `cd` ficou como limitação).
- 2026-11-20 — na 6ª revisão, achado `gh pr -R x merge ... --squash` (🔴, a flag entre `pr` e `merge`), além do DEBT-002 que ainda dizia que o `ask` cobre o merge; corrigidos em `6508c44` e `6c2a1cb`. Esta foi a 6ª revisão seguida que achou algo novo: se a próxima achar outro 🔴, a decisão é partir para a opção A (ADR).
- 2026-11-20 — na 7ª revisão, achados 2 🔴 (`&` solto e flag antes de `api`/`alias`) e a lista do Sintoma incompleta. O dono decide a opção A (ADR e PR próprio); os 2 🔴 ficam como limitação registrada neste PR. O refactor `0cbb6fa` foi conferido pelos revisores (81 comandos, 0 diferenças).
