---
id: ERR-002
titulo: protect-merge bloqueia gh pr merge com redirecionamento de saída
status: corrigido
categoria: bug
severidade: baixa
detectado-em: local
data: 2026-11-20
issue: nenhuma
pr: https://github.com/Adrian-Pardal/Plataforma-Instrumentus/pull/8
recorrencias: 1
---

# ERR-002: protect-merge bloqueia gh pr merge com redirecionamento de saída

## Sintoma
`gh pr merge 7 --merge 2>&1` foi recusado pelo hook, e o merge não rodou:
"🚫 protect-merge: não consegui consultar o destino do PR com 'gh pr view'; bloqueio por segurança."
O PR 7 mirava `develop` e o CI estava verde.

## Como reproduzir
1. Rodar `jq -n --arg c 'gh pr merge 7 --merge 2>&1' --arg d "$PWD" '{tool_name:"Bash",tool_input:{command:$c},cwd:$d}' | .claude/hooks/protect-merge.sh`
2. Sai com código 2 e a mensagem acima (reproduzido em 2026-11-20).
3. O mesmo comando sem `2>&1` (`gh pr merge 7 --merge`) sai com 0.

## Causa raiz (5 porquês)
1. Por quê o merge foi bloqueado? O hook não conseguiu descobrir o destino do PR e, sem isso, bloqueia por segurança (o `bloquear` que vem depois do `gh pr view`).
2. Por quê não conseguiu? Chamou `gh pr view 2>&1 --json ...`, em vez de `gh pr view 7 ...`, e o gh falhou.
3. Por quê o alvo virou `2>&1`? Em `analisar_merge`, todo argumento que não é opção cai em `*) ALVO="$A"`, e o último vence. O `2>&1` veio depois do `7` e o sobrescreveu.
4. Por quê o `2>&1` chegou lá? O hook separa o comando só por `&&`, `||`, `;` e `|` e depois por espaços. Não distingue redirecionamento de argumento do gh, mas o shell consome os redirecionamentos antes de o gh rodar.
5. Por quê ninguém viu? O `protect-merge.test.sh` cobre estratégias e destinos, mas nenhum caso tem sintaxe de shell em volta do comando (causa raiz: falta de teste com redirecionamento). Não sei se o `protect-merge` e o `protect-push` compartilham código; o conserto do ERR-001 foi só no `protect-push`.

## Correção
Em três rodadas, em `.claude/hooks/protect-merge.sh`:
1. `2fa761b`: a função `tirar_redirecionamentos` descarta os tokens de redirecionamento (`>`, `>>`, `<`, `2>`, `2>&1`, `&>`) e o alvo deles antes de `analisar_merge`. Diferente do `protect-push`, o `protect-merge` tira as aspas antes de separar os tokens; por isso o texto entre aspas ganha um marcador `\x02`, que impede `--body ">" --squash` de ser lido como redirecionamento (isso liberaria o squash).
2. `e4e55a2`, depois que a 1ª revisão do PR #8 achou 2 brechas: (a) `>|` — o corte do comando por `|` acontecia antes, então `>| x --squash` liberava o `--squash`. A lógica de opções **já tinha essa brecha na `develop`** (com um `gh` que responde `develop`, o hook liberava). Na prática ela estava mascarada: o `>` virava o alvo do PR e o `gh pr view` real falhava, bloqueando por acidente. A 1ª correção removeu o acidente e expôs a brecha. Agora `>|` vira `>` antes do corte. (b) redirecionamento **colado** ao fim de uma palavra (`--squash>x`, `--admin>x`), que também já liberava a opção na `develop`; agora a função separa a palavra do operador.
3. `817b161`, depois da 2ª revisão: (c) opção **entre aspas** com redirecionamento colado (`'--squash'>x`, `"--squash">x`). O marcador `\x02` da 1ª rodada fazia a função pular o token inteiro. Agora o texto citado fica entre `\x02` e `\x03`, e `achar_operador` só considera `<`/`>` fora desse trecho. Na `develop` esses comandos também passavam (rc=0).

## Teste de regressão
`scripts/tests/protect-merge.test.sh`, seção "redirecionamentos do shell". O `gh` falso passou a falhar se receber `<` ou `>`, como o gh real.
- `b53d98a` (antes da 1ª correção): `2>&1` (0), `> /tmp/log 2>&1` (0) e `--merge 2>&1` sem número (0) falhavam sem a correção. `--body "a > b"` (0), `--squash 2>&1` (2) e `main ... 2>&1` (2) são guardas.
- `2fa761b`: `--body ">" --squash` (2), acrescentado junto com a correção. É guarda contra regressão; nunca esteve vermelho (o código antigo também o bloqueava).
- `25a3d2d` (antes da 2ª correção): 9 casos vermelhos (`--squash>x`, `--admin>x`, `--auto>/dev/null`, `--rebase<x`, `--squash&>x`, `>| x --squash`, `>|x --squash`, `2>|x --admin` e `--merge>x`), mais guardas de outros operadores.
- `b20252b` (antes da 3ª correção): 6 falhas. 5 eram válidas (`'--squash'>x`, `"--squash">x`, `'--admin'>x`, `"--auto"<x` e `"12">x`, este esperando 0). 1 tinha expectativa **errada**: `"--admin"2>&1` esperando 2, mas o shell entrega a palavra `--admin2`, que não é opção. Corrigido em `817b161`: `"--admin" 2>&1` espera 2 e `"--admin"2>&1` espera 0.

## Prevenção
Cobrir no teste a sintaxe de shell em volta do comando **em todas as formas**: separada (`> x`), colada (`--opção>x`), colada a texto citado (`'--opção'>x`), `>|` e `&>`. A 1ª correção testou só a forma separada e deixou passar brechas, achadas em duas revisões. Se voltar (2ª ocorrência), propor regra automática (ver skill registrar-erro, passo 7). Como é a mesma família do ERR-001, vale conferir `protect-files.sh` e `protect-push.sh`: a revisão suspeitou que o `protect-push` tem o mesmo problema com `>|`, mas **isso não foi testado**.

## Lição para a IA
Ao rodar `gh`/`git` sob hooks que leem o comando, evitar redirecionamentos (`2>&1`, `| tail`) em comandos protegidos. Ao escrever hook que lê `tool_input.command`, tratar redirecionamento como sintaxe do shell e testá-lo em todas as formas, não só na que causou o erro; e, em hook de segurança, rodar o hook de verdade com variações antes de declarar corrigido. Conferir o que o shell realmente entrega (`printf '[%s]\n' ...`) antes de escrever a expectativa de um teste: um caso copiado da lista de um revisor estava errado.

## Ocorrências
- 2026-11-20 — primeira ocorrência, ao mergear o PR #7 (reproduzida com o hook rodando direto).
- 2026-11-20 — a 1ª revisão do PR #8 achou 2 brechas (`>|` e redirecionamento colado); corrigidas em `e4e55a2`.
- 2026-11-20 — a 2ª revisão achou a brecha da opção entre aspas com redirecionamento colado; corrigida em `817b161`.

As duas últimas entradas são brechas na própria correção, descobertas na revisão. Não são reincidência do bug original, por isso `recorrencias` continua 1.
