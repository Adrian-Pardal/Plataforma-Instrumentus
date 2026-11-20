---
id: ERR-002
titulo: protect-merge bloqueia gh pr merge com redirecionamento de saída
status: aberto
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
1. Por quê o merge foi bloqueado? O hook não conseguiu descobrir o destino do PR e, sem isso, bloqueia por segurança (`protect-merge.sh:78`).
2. Por quê não conseguiu? Chamou `gh pr view 2>&1 --json ...`, em vez de `gh pr view 7 ...`, e o gh falhou.
3. Por quê o alvo virou `2>&1`? Em `analisar_merge`, todo argumento que não é opção cai em `*) ALVO="$A"` (linha 66), e o último vence. O `2>&1` veio depois do `7` e o sobrescreveu.
4. Por quê o `2>&1` chegou lá? O hook separa o comando só por `&&`, `||`, `;` e `|` e depois por espaços. Não distingue redirecionamento de argumento do gh, mas o shell consome os redirecionamentos antes de o gh rodar.
5. Por quê ninguém viu? O `protect-merge.test.sh` cobre estratégias e destinos, mas nenhum caso tem sintaxe de shell em volta do comando (causa raiz: falta de teste com redirecionamento). Não sei se o `protect-merge` e o `protect-push` compartilham código; o conserto do ERR-001 foi só no `protect-push`.

## Correção
Pendente. Direção: descartar os tokens de redirecionamento (`>`, `>>`, `<`, `2>`, `2>&1`, `&>`) e o alvo deles antes do `case` de `analisar_merge`, como `tirar_redirecionamentos` faz no `protect-push.sh` (ERR-001), preservando `">"` entre aspas como argumento. Será feita numa branch própria, a pedido do dono.

## Teste de regressão
Ainda não existe (a correção está pendente). Será o primeiro passo da correção, em `scripts/tests/protect-merge.test.sh`, com o gh falso que o teste já usa:
`gh pr merge 7 --merge 2>&1` (0, e o gh falso deve receber o alvo `7`), `gh pr merge 7 --merge > /tmp/log 2>&1` (0) e `gh pr merge 7 --squash 2>&1` (2). Os dois primeiros devem falhar antes da correção.

## Prevenção
Cobrir no teste a sintaxe de shell em volta do comando. Se voltar (2ª ocorrência), propor regra automática (ver skill registrar-erro, passo 7). Como é a mesma família do ERR-001, vale conferir `protect-files.sh` e `protect-push.sh` por redirecionamentos.

## Lição para a IA
Ao rodar `gh`/`git` sob hooks que leem o comando, evitar redirecionamentos (`2>&1`, `| tail`) em comandos protegidos e, ao escrever hook que lê `tool_input.command`, tratar redirecionamento como sintaxe do shell e testá-lo.

## Ocorrências
- 2026-11-20 — primeira ocorrência, ao mergear o PR #7 (reproduzida com o hook rodando direto).
