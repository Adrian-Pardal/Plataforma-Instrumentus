#!/usr/bin/env bash
# eventos.test.sh — testes do registro de eventos do harness (plano 005, ADR 0007).
# Cobre a lib .claude/hooks/lib/eventos.sh e, nas tasks seguintes, cada hook que grava em
# .claude/pesquisa/eventos.jsonl. Cada caso usa um projeto temporário: o arquivo real nunca é tocado.
# Uso: scripts/tests/eventos.test.sh   (sai com 1 se algum caso falhar)
# shellcheck disable=SC2016  # o $ dentro de bash -c '...' é de propósito: quem expande é o bash filho
set -uo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LIB="$RAIZ/.claude/hooks/lib/eventos.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
falhas=0

command -v jq >/dev/null || { echo "• jq não instalado: testes pulados"; exit 0; }

# Compara o valor esperado com o obtido e conta a falha.
confere() {   # confere <esperado> <obtido> <descrição>
  if [[ "$1" == "$2" ]]; then
    echo "  ok    $3"
  else
    echo "  FALHA $3 (esperado '$1', veio '$2')" >&2
    falhas=$((falhas + 1))
  fi
}

# Projeto novo e vazio; guarda o caminho em P (sem echo em $(...), para o exit funcionar).
projeto() { P="$TMP/$1"; mkdir -p "$P"; }
EVENTOS() { echo "$P/.claude/pesquisa/eventos.jsonl"; }
linhas() { [[ -f "$(EVENTOS)" ]] && wc -l < "$(EVENTOS)" | tr -d ' ' || echo 0; }

# Roda registrar_evento num subshell novo, com CLAUDE_PROJECT_DIR=$P; guarda stdout+stderr em SAIDA.
registrar() {   # registrar <args de registrar_evento>
  SAIDA=$(CLAUDE_PROJECT_DIR="$P" bash -c 'source "$1"; shift; registrar_evento "$@"; echo "rc=$?"' _ "$LIB" "$@" 2>&1)
}

echo "▶ lib eventos.sh: bloqueio"
projeto basico
registrar bloqueio protect-files adr-aceito "docs/adr/0003-x.md"
confere "rc=0" "$SAIDA" "não imprime nada e devolve 0"
confere 1 "$(linhas)" "grava UMA linha"
L=$(head -1 "$(EVENTOS)")
confere true "$(jq -e . >/dev/null 2>&1 <<<"$L" && echo true || echo false)" "a linha é JSON válido"
confere "bloqueio|protect-files|adr-aceito|docs/adr/0003-x.md" \
  "$(jq -r '[.tipo,.hook,.motivo,.alvo] | join("|")' <<<"$L")" "campos tipo, hook, motivo e alvo"
confere "quando,tipo,hook,motivo,alvo" "$(jq -r 'keys_unsorted | join(",")' <<<"$L")" "só as 5 chaves, nessa ordem"
confere true "$(jq -r '.quando | test("^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$")' <<<"$L")" "quando é data e hora UTC (ISO 8601)"
registrar bloqueio protect-push push-forcado "feat/x"
confere 2 "$(linhas)" "a segunda chamada acrescenta, não substitui"

echo "▶ lib eventos.sh: texto perigoso e tamanho"
projeto escape
ALVO=$'com "aspas" e\nquebra de linha'
registrar bloqueio protect-files arquivo-sensivel "$ALVO"
confere 1 "$(linhas)" "quebra de linha no alvo continua sendo UMA linha"
confere "$ALVO" "$(jq -r '.alvo' < "$(EVENTOS)")" "aspas e quebra de linha voltam idênticas"
projeto longo
registrar bloqueio protect-files arquivo-sensivel "$(printf 'a%.0s' {1..500})"
confere 200 "$(jq -r '.alvo | length' < "$(EVENTOS)")" "alvo truncado em 200 caracteres"
projeto vazio
registrar bloqueio protect-merge merge-squash ""
confere "" "$(jq -r '.alvo' < "$(EVENTOS)")" "alvo vazio é aceito"

echo "▶ lib eventos.sh: tipo sessao"
projeto sessao
registrar sessao session-start "2.1.0 (Claude Code)" "docs/pesquisa"
L=$(head -1 "$(EVENTOS)")
confere "sessao|session-start|2.1.0 (Claude Code)|docs/pesquisa" \
  "$(jq -r '[.tipo,.hook,.versao,.branch] | join("|")' <<<"$L")" "campos tipo, hook, versao e branch"
confere "quando,tipo,hook,versao,branch" "$(jq -r 'keys_unsorted | join(",")' <<<"$L")" "só as 5 chaves, nessa ordem"

echo "▶ lib eventos.sh: nunca atrapalha o hook"
projeto sem-variavel
SAIDA=$(cd "$P" && env -u CLAUDE_PROJECT_DIR bash -c 'source "$1"; registrar_evento bloqueio protect-files adr-aceito x; echo "rc=$?"' _ "$LIB" 2>&1)
confere "rc=0" "$SAIDA" "sem CLAUDE_PROJECT_DIR: devolve 0 e não imprime"
confere false "$([[ -e "$P/.claude" ]] && echo true || echo false)" "sem CLAUDE_PROJECT_DIR: não cria nada"
projeto pasta-bloqueada
mkdir -p "$P/.claude"; : > "$P/.claude/pesquisa"   # "pesquisa" é um ARQUIVO: o mkdir -p falha
registrar bloqueio protect-files adr-aceito x
confere "rc=0" "$SAIDA" "não consegue gravar: devolve 0 e não imprime"
SAIDA=$(CLAUDE_PROJECT_DIR="$TMP/nao-existe" bash -c 'source "$1"; registrar_evento bloqueio protect-files adr-aceito x; echo "rc=$?"' _ "$LIB" 2>&1)
confere "rc=0" "$SAIDA" "pasta do projeto inexistente: devolve 0 e não imprime"
confere false "$([[ -e "$TMP/nao-existe" ]] && echo true || echo false)" "pasta do projeto inexistente: a lib não a cria"
projeto tipo-desconhecido
registrar inventado protect-files adr-aceito x
confere "rc=0" "$SAIDA" "tipo desconhecido: devolve 0 e não imprime"
confere 0 "$(linhas)" "tipo desconhecido: não grava"
projeto sem-jq
SAIDA=$(CLAUDE_PROJECT_DIR="$P" bash -c 'source "$1"; PATH=/nonexistent; registrar_evento bloqueio protect-files adr-aceito x; echo "rc=$?"' _ "$LIB" 2>&1)
confere "rc=0" "$SAIDA" "sem jq: devolve 0 e não imprime"
confere 0 "$(linhas)" "sem jq: não grava"

# --- Hooks ----------------------------------------------------------------------------------------------
# roda_hook <hook> <json>: roda o hook real com CLAUDE_PROJECT_DIR=$P (RC e ERR) e, de controle, sem ela
# (RC_CTRL e ERR_CTRL). Comparar os dois prova que gravar o evento não muda o código de saída nem o stderr (CA-3).
roda_hook() {
  local hook="$RAIZ/.claude/hooks/$1.sh"
  rm -f "$(EVENTOS)"
  ERR=$(printf '%s' "$2" | (cd / && CLAUDE_PROJECT_DIR="$P" "$hook") 2>&1 >/dev/null); RC=$?
  ERR_CTRL=$(printf '%s' "$2" | (cd / && env -u CLAUDE_PROJECT_DIR "$hook") 2>&1 >/dev/null); RC_CTRL=$?
}
# bloqueou <descrição> <hook> <motivo> <alvo>: o hook bloqueou (2), gravou UMA linha certa e nada mudou no resto.
bloqueou() {
  confere 2 "$RC" "$1: bloqueia (código 2)"
  confere "$RC_CTRL" "$RC" "$1: mesmo código de saída sem o registro"
  confere "$ERR_CTRL" "$ERR" "$1: mesmo stderr sem o registro"
  confere 1 "$(linhas)" "$1: grava UMA linha"
  confere "bloqueio|$2|$3|$4" "$({ jq -r '[.tipo,.hook,.motivo,.alvo] | join("|")' < "$(EVENTOS)"; } 2>/dev/null | head -1)" "$1: hook, motivo e alvo"
}
# sem_o_texto <texto> <descrição>: passa só se o evento EXISTE e NÃO contém o texto (arquivo ausente não vale).
sem_o_texto() {
  confere sim "$([[ -f "$(EVENTOS)" ]] && ! grep -q -- "$1" "$(EVENTOS)" && echo sim || echo nao)" "$2"
}
# liberou <descrição>: o hook deixou passar (0) e não gravou nada.
liberou() {
  confere 0 "$RC" "$1: libera (código 0)"
  confere 0 "$(linhas)" "$1: não grava nada"
}
json_write() { jq -cn --arg p "$1" --arg c "${2:-x}" --arg d "$P" '{tool_name:"Write",tool_input:{file_path:$p,content:$c},cwd:$d}'; }
json_bash() { jq -cn --arg c "$1" --arg d "$P" '{tool_name:"Bash",tool_input:{command:$c},cwd:$d}'; }

echo "▶ protect-files grava o evento"
projeto pf
mkdir -p "$P/docs/adr"
printf '# ADR 0001\n\n- **Status:** Aceito\n- **Data:** 2026-01-01\n\nTexto.\n' > "$P/docs/adr/0001-exemplo.md"
roda_hook protect-files "$(json_write ".env")"
bloqueou "Write em .env" protect-files arquivo-sensivel ".env"
roda_hook protect-files "$(json_write "secrets/chave.txt")"
bloqueou "Write em secrets/" protect-files arquivo-sensivel "secrets/chave.txt"
roda_hook protect-files "$(json_write "docs/adr/0001-exemplo.md" "outro texto")"
bloqueou "Write em ADR Aceito" protect-files adr-aceito "docs/adr/0001-exemplo.md"
roda_hook protect-files "$(json_bash "cat .env")"
bloqueou "Bash lendo .env" protect-files bash-leitura-segredo ".env"
roda_hook protect-files "$(json_bash "echo x > .env")"
bloqueou "Bash escrevendo em .env" protect-files bash-escrita-sensivel ".env"
roda_hook protect-files "$(json_bash "rm docs/adr/0001-exemplo.md")"
bloqueou "Bash apagando ADR Aceito" protect-files bash-escrita-adr-aceito "docs/adr/0001-exemplo.md"
roda_hook protect-files "não é json"
bloqueou "entrada que não é JSON" protect-files entrada-invalida ""
roda_hook protect-files "$(json_write "docs/notas.md")"
liberou "Write em arquivo comum"
roda_hook protect-files "$(json_bash "ls -la")"
liberou "Bash inofensivo"

echo "▶ protect-files nunca grava conteúdo nem valor de variável"
roda_hook protect-files "$(json_write ".env" "SEGREDO_NO_CONTEUDO_123")"
sem_o_texto "SEGREDO_NO_CONTEUDO_123" "conteúdo do arquivo não vai para o evento"
roda_hook protect-files "$(json_bash "echo SEGREDO_NO_COMANDO_456 > .env")"
sem_o_texto "SEGREDO_NO_COMANDO_456" "texto do comando não vai para o evento"
rm -f "$(EVENTOS)"
printf '%s' "$(json_bash "cat .env")" | (cd / && MINHA_VARIAVEL=VALOR_DA_VARIAVEL_789 CLAUDE_PROJECT_DIR="$P" "$RAIZ/.claude/hooks/protect-files.sh") >/dev/null 2>&1
sem_o_texto "VALOR_DA_VARIAVEL_789" "valor de variável de ambiente não vai para o evento"

echo "▶ protect-push grava o evento"
projeto pp
git init -q -b main "$P/repo" || { echo "FALHA: git init" >&2; exit 1; }
json_bash_em() { jq -cn --arg c "$2" --arg d "$1" '{tool_name:"Bash",tool_input:{command:$c},cwd:$d}'; }   # json_bash_em <cwd> <cmd>
roda_hook protect-push "$(json_bash "git push --force origin feat/x")"
bloqueou "push --force" protect-push push-forcado ""
roda_hook protect-push "$(json_bash "git push -fu origin feat/x")"
bloqueou "push -fu" protect-push push-forcado ""
roda_hook protect-push "$(json_bash "git push --mirror")"
bloqueou "push --mirror" protect-push push-opcao-destrutiva ""
roda_hook protect-push "$(json_bash "git push --repo=outro")"
bloqueou "push --repo" protect-push push-opcao-proibida ""
roda_hook protect-push "$(json_bash "git push -d origin feat/x")"
bloqueou "push -d" protect-push push-delete ""
roda_hook protect-push "$(json_bash "git push upstream feat/x")"
bloqueou "remoto que não é origin" protect-push remoto-nao-permitido ""
roda_hook protect-push "$(json_bash_em "$P/repo" "git push")"
bloqueou "push sem destino estando na main" protect-push destino-nao-permitido "main"
roda_hook protect-push "$(json_bash "git push origin main")"
bloqueou "push para main" protect-push destino-nao-permitido "main"
roda_hook protect-push "$(json_bash "git push origin feat/x:develop")"
bloqueou "refspec que mira develop" protect-push destino-nao-permitido "develop"
roda_hook protect-push "$(json_bash "git push origin +feat/x")"
bloqueou "refspec com +" protect-push push-forcado "+feat/x"
roda_hook protect-push "$(json_bash "git push origin :feat/x")"
bloqueou "refspec que apaga a branch" protect-push push-delete ":feat/x"
roda_hook protect-push "não é json"
bloqueou "entrada que não é JSON" protect-push entrada-invalida ""
roda_hook protect-push "$(json_bash "git push origin feat/x")"
liberou "push para feat/x"
roda_hook protect-push "$(json_bash "git status")"
liberou "git que não é push"
roda_hook protect-push "$(json_bash "ls -la")"
liberou "comando que não é git"
roda_hook protect-push "$(json_bash "git push https://TOKEN_SECRETO_999@exemplo.com/x.git feat/x")"
bloqueou "push para URL com credencial" protect-push remoto-nao-permitido ""
sem_o_texto "TOKEN_SECRETO_999" "credencial na URL do remoto não vai para o evento"

echo "▶ protect-merge grava o evento"
projeto pm
# "gh" falso: só responde ao "gh pr view" que o hook faz para saber a base do PR (FAKE_BASE e FAKE_RC controlam a resposta).
mkdir -p "$TMP/fakegh"
printf '%s\n' '#!/usr/bin/env bash' 'case "$*" in "pr view"*) echo "${FAKE_BASE:-develop}"; exit "${FAKE_RC:-0}" ;; esac' > "$TMP/fakegh/gh"
chmod +x "$TMP/fakegh/gh"
merge() { PATH="$TMP/fakegh:$PATH" FAKE_BASE="${FAKE_BASE:-develop}" FAKE_RC="${FAKE_RC:-0}" roda_hook protect-merge "$(json_bash "$1")"; }
merge "gh pr merge 1 --merge --admin"
bloqueou "merge --admin" protect-merge merge-admin ""
merge "gh pr merge 1 --merge --auto"
bloqueou "merge --auto" protect-merge merge-auto ""
merge "gh pr merge 1 --squash"
bloqueou "merge --squash" protect-merge merge-squash-ou-rebase ""
merge "gh pr merge 1 -s"
bloqueou "merge -s" protect-merge merge-squash-ou-rebase ""
merge "gh pr merge 1 -x"
bloqueou "merge com opção curta desconhecida" protect-merge opcao-desconhecida ""
merge "gh pr merge 1"
bloqueou "merge sem --merge" protect-merge sem-merge-commit ""
merge "gh api -X PUT repos/o/r/pulls/1/merge"
bloqueou "merge por gh api" protect-merge merge-por-api ""
FAKE_BASE=main merge "gh pr merge 1 --merge"
bloqueou "PR que mira a main" protect-merge base-nao-permitida "main"
FAKE_RC=1 merge "gh pr merge 1 --merge"
bloqueou "gh pr view falhou" protect-merge consulta-pr-falhou ""
merge "gh -R o/r pr merge 1 --merge"
bloqueou "forma não canônica" protect-merge forma-nao-canonica ""
merge "gh alias set m x"
bloqueou "gh alias set" protect-merge alias-set-import ""
merge "GH_REPO=o/r gh pr merge 1 --merge"
bloqueou "GH_REPO no prefixo" protect-merge prefixo-gh-repo-host ""
merge 'gh pr merge 1 --merge --body "$X"'
bloqueou "\$ no comando" protect-merge expansao-no-comando ""
roda_hook protect-merge "não é json"
bloqueou "entrada que não é JSON" protect-merge entrada-invalida ""
merge "gh pr merge 1 --merge"
liberou "merge --merge em PR da develop"
merge "ls -la"
liberou "comando que não é gh"
merge "gh pr view 1"
liberou "gh que não é merge"
merge "gh pr merge --squash https://TOKEN_PR_321@exemplo.com/o/r/pull/1"
bloqueou "merge --squash com URL de credencial" protect-merge merge-squash-ou-rebase ""
sem_o_texto "TOKEN_PR_321" "credencial na URL do PR não vai para o evento"

echo "▶ stop-verify grava o evento"
# Projeto git com um arquivo de código novo (a.ts) e um verify.sh de mentira que sai com o código dado.
# O stop-verify só confere se scripts/verify.sh existe e é executável, e o chama com "test".
projeto_stop() {   # projeto_stop <nome> <código de saída do verify.sh falso | nenhum> <com código: sim|nao>
  projeto "$1"
  git init -q -b main "$P" || { echo "FALHA: git init" >&2; exit 1; }
  if [[ "$2" != nenhum ]]; then
    mkdir -p "$P/scripts"
    printf '%s\n' '#!/usr/bin/env bash' 'echo "saída do verify de mentira"' "exit $2" > "$P/scripts/verify.sh"
    chmod +x "$P/scripts/verify.sh"
  fi
  if [[ "$3" == sim ]]; then echo "x" > "$P/a.ts"; fi
}
json_stop() { jq -cn --arg d "$P" --argjson a "${1:-false}" '{hook_event_name:"Stop",stop_hook_active:$a,cwd:$d}'; }

projeto_stop sv-falha 1 sim
roda_hook stop-verify "$(json_stop)"
bloqueou "testes falharam" stop-verify testes-falharam "main"
projeto_stop sv-sem-verify nenhum sim
roda_hook stop-verify "$(json_stop)"
bloqueou "verify.sh ausente" stop-verify verify-ausente ""
roda_hook stop-verify "não é json"
bloqueou "entrada que não é JSON" stop-verify entrada-invalida ""
projeto_stop sv-ok 0 sim
roda_hook stop-verify "$(json_stop)"
liberou "testes passaram"
projeto_stop sv-sem-codigo 1 nao
roda_hook stop-verify "$(json_stop)"
liberou "sem mudança de código"
projeto_stop sv-ativo 1 sim
roda_hook stop-verify "$(json_stop true)"
liberou "stop_hook_active (anti-loop)"
# Raiz do projeto inexistente: bloqueia (código 2) e, sem pasta onde gravar, não cria nenhuma.
ERR=$(printf '%s' '{"hook_event_name":"Stop","stop_hook_active":false,"cwd":"/nao/existe"}' | (cd / && CLAUDE_PROJECT_DIR="$TMP/nao-existe-2" "$RAIZ/.claude/hooks/stop-verify.sh") 2>&1 >/dev/null); RC=$?
confere 2 "$RC" "raiz do projeto inexistente: bloqueia (código 2)"
confere false "$([[ -e "$TMP/nao-existe-2" ]] && echo true || echo false)" "raiz do projeto inexistente: não cria a pasta"

if [[ $falhas -gt 0 ]]; then
  echo "✖ $falhas caso(s) de eventos falharam" >&2
  exit 1
fi
echo "✔ todos os casos de eventos passaram"
