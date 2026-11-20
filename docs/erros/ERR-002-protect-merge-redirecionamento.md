---
id: ERR-002
titulo: protect-merge bloqueia gh pr merge com redirecionamento de saída
status: corrigido
categoria: bug
severidade: baixa
detectado-em: local
data: 2026-11-20
issue: nenhuma
pr: nenhum
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
Em duas rodadas, em `.claude/hooks/protect-merge.sh`:
1. `2fa761b`: a função `tirar_redirecionamentos` descarta os tokens de redirecionamento (`>`, `>>`, `<`, `2>`, `2>&1`, `&>`) e o alvo deles antes de `analisar_merge`. Diferente do `protect-push`, o `protect-merge` tira as aspas antes de separar os tokens; por isso o texto entre aspas ganha um marcador `\x02`, que impede `--body ">" --squash` de ser lido como redirecionamento (isso liberaria o squash).
2. `e4e55a2`, depois que a revisão do PR #8 achou 2 brechas na 1ª rodada: (a) `>|` — o corte do comando por `|` acontecia antes, então `>| x --squash` liberava o `--squash`. Isso era **regressão** da 1ª rodada (antes bloqueava por acidente); agora `>|` vira `>` antes do corte. (b) redirecionamento **colado** ao fim de uma palavra (`--squash>x`, `--admin>x`), que já liberava a opção antes do ERR-002; agora a função separa a palavra do operador.

## Teste de regressão
`scripts/tests/protect-merge.test.sh`, seção "redirecionamentos do shell". O `gh` falso passou a falhar se receber `<` ou `>`, como o gh real.
- `b53d98a` (antes da 1ª correção): `2>&1` (0), `> /tmp/log 2>&1` (0) e `--merge 2>&1` sem número (0) falhavam sem a correção. `--body "a > b"` (0), `--squash 2>&1` (2) e `main ... 2>&1` (2) são guardas.
- `2fa761b`: `--body ">" --squash` (2), acrescentado junto com a correção. É guarda contra regressão; nunca esteve vermelho (o código antigo também o bloqueava).
- `25a3d2d` (antes da 2ª correção): 9 casos vermelhos (`--squash>x`, `--admin>x`, `--auto>/dev/null`, `--rebase<x`, `--squash&>x`, `>| x --squash`, `>|x --squash`, `2>|x --admin` e `--merge>x`), mais guardas de outros operadores.

## Prevenção
Cobrir no teste a sintaxe de shell em volta do comando **em todas as formas**: separada (`> x`), colada (`--opção>x`), `>|` e `&>`. A 1ª correção testou só a forma separada e deixou passar duas brechas, achadas na revisão. Se voltar (2ª ocorrência), propor regra automática (ver skill registrar-erro, passo 7). Como é a mesma família do ERR-001, vale conferir `protect-files.sh` e `protect-push.sh`: a revisão suspeitou que o `protect-push` tem o mesmo problema com `>|`, mas **isso não foi testado**.

## Lição para a IA
Ao rodar `gh`/`git` sob hooks que leem o comando, evitar redirecionamentos (`2>&1`, `| tail`) em comandos protegidos. Ao escrever hook que lê `tool_input.command`, tratar redirecionamento como sintaxe do shell e testá-lo em todas as formas, não só na que causou o erro; e, em hook de segurança, rodar o hook de verdade com variações antes de declarar corrigido.

## Ocorrências
- 2026-11-20 — primeira ocorrência, ao mergear o PR #7 (reproduzida com o hook rodando direto).
- 2026-11-20 — a revisão do PR #8 achou 2 brechas na 1ª correção (`>|` e redirecionamento colado); corrigidas em `e4e55a2`.
