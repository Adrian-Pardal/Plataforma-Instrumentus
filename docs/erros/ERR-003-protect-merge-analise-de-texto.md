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
- B (corrigida): `gh pr merge` com `$`, crase ou `\` no texto é bloqueado (`5b820bc`). Custa um falso bloqueio, por exemplo `--body "custa $5"`.
- C (aceita como limitação): `|`, `;`, `&&`, `||` dentro de aspas e aspas de tipos diferentes pareando errado continuam sem ser vistos. Só o `ask` do `settings.json` (confirmação do dono) cobre esses casos.
- A (dividir o comando respeitando as aspas, com biblioteca compartilhada pelos hooks) fica como alternativa futura (DEBT-002), com ADR.

## Teste de regressão
`scripts/tests/protect-merge.test.sh`, seção "expansões do shell" (`74d3c2a`): 8 casos vermelhos antes de `5b820bc` (`$(...)`, crase, `\--squash`, `$IFS--squash`, `${X}--squash`, `--body "$(echo x)"`, `$PR` e o falso bloqueio `'custa $5'`) e 3 guardas. Os casos de aspas (opção C) não têm teste, pois a limitação é aceita.

## Prevenção
O `gh pr merge` passa por `permissions.ask` no `settings.json`: todo merge pede confirmação do dono, independentemente do hook; o hook é a segunda camada. A limitação das aspas está documentada no cabeçalho de `protect-merge.sh` e na página `docs/help/ferramentas/merge-de-pr.md`. Se voltar (2ª ocorrência), propor regra automática (ver skill registrar-erro, passo 7).

## Lição para a IA
Um hook que lê o texto do comando é rede de segurança, não garantia. Ao descrevê-lo, dizer também o que ele não enxerga, e não afirmar que "não libera nada".

## Ocorrências
- 2026-11-20 — achado na 2ª revisão do PR #8, rodando o hook com um `gh` falso; já existia na `develop`.
- 2026-11-20 — na 3ª revisão, achado o caso dos apóstrofos. O dono decide C + B; B corrigida em `5b820bc`.
