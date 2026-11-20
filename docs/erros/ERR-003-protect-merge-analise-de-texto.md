---
id: ERR-003
titulo: protect-merge libera opção proibida escondida por aspas com | ou ; e por expansões do shell
status: aberto
categoria: bug
severidade: media
detectado-em: revisao
data: 2026-11-20
issue: nenhuma
pr: nenhum
recorrencias: 1
---

# ERR-003: protect-merge libera opção proibida escondida por aspas com | ou ; e por expansões do shell

## Sintoma
Com um `gh` que responde `develop`, o hook sai com 0 (libera) em comandos que o shell executaria com `--squash`, `--auto` ou `-s`:
`gh pr merge 1 --merge --body "a|b" --squash`, `--body "a;b" --auto`, `--body 'x||y' --squash`, `--body "a&&b" -s`,
e também com `\--squash`, `$IFS--squash`, `${X}--squash`, `$(echo --squash)`, crases e quebra de linha dentro de aspas.
O mesmo vale para o hook da `develop` (não é regressão).

## Como reproduzir
1. Criar um `gh` falso no PATH que, para `gh pr view`, imprime `develop` (com um PR real que mira `develop` o resultado é o mesmo).
2. Rodar `jq -n --arg c 'gh pr merge 1 --merge --body "a|b" --squash' --arg d "$PWD" '{tool_name:"Bash",tool_input:{command:$c},cwd:$d}' | .claude/hooks/protect-merge.sh`
3. Sai com 0, quando o correto seria 2. Conferido em 2026-11-20 (hook atual e hook da `develop`).
4. Nos casos de expansão, `printf '[%s] ' \--squash $IFS--squash ${X}--squash "$(echo --squash)"` mostra que o shell entrega `--squash`.

## Causa raiz (5 porquês)
1. Por quê o comando passa? O hook não vê `--squash` como argumento do `gh pr merge`.
2. Por quê? Nos casos de `|`, `;`, `&&` e `||` dentro de aspas, o hook corta o comando nesses caracteres antes de olhar as aspas, e o `--squash` cai num segmento que não começa com `gh`. Nos casos de expansão, o texto do comando não contém `--squash` como token; ele só aparece depois que o shell expande.
3. Por quê o hook não expande? Ele lê só o texto de `tool_input.command`, antes de o shell rodar. Reproduzir aspas, escapes e expansões seria reimplementar um parser de shell.
4. Por quê foi escrito assim? Para ser simples e legível: corta por separadores e confere tokens. Cobre o uso normal do Claude, não comandos escritos para escapar da regra.
5. Por quê ninguém viu? Os testes cobrem opções, destinos e (depois do ERR-002) redirecionamentos, mas nenhum caso tem separador dentro de aspas nem expansão (causa raiz: o hook é análise estática de texto, sem um registro explícito do que ele não consegue ver). Não sei se `protect-push` e `protect-files` têm as mesmas limitações; não foi testado.

## Correção
Pendente. Opções, a decidir pelo dono: (A) dividir o comando respeitando as aspas (varrer caractere a caractere), o que cobre `|`/`;` em aspas; (B) bloquear qualquer `gh pr merge` cujo texto tenha `$`, crase ou `\`, o que cobre as expansões e pode causar falso bloqueio; (C) aceitar como limitação conhecida e confiar no `ask` do `settings.json`.

## Teste de regressão
Ainda não existe (correção pendente). Será o primeiro passo, em `scripts/tests/protect-merge.test.sh`, com os comandos do Sintoma esperando 2 (os que a opção escolhida cobrir).

## Prevenção
O `gh pr merge` passa por `permissions.ask` no `settings.json`: todo merge pede confirmação do dono, independentemente do hook; o hook é a segunda camada. A limitação está documentada no cabeçalho de `protect-merge.sh` (commit `817b161`). Se voltar (2ª ocorrência), propor regra automática (ver skill registrar-erro, passo 7).

## Lição para a IA
Um hook que lê o texto do comando é rede de segurança, não garantia. Ao descrevê-lo, dizer também o que ele não enxerga, e não afirmar que "não libera nada".

## Ocorrências
- 2026-11-20 — achado na 2ª revisão do PR #8, rodando o hook com um `gh` falso; já existia na `develop`. Sem correção.
