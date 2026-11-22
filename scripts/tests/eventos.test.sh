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
projeto tipo-desconhecido
registrar inventado protect-files adr-aceito x
confere "rc=0" "$SAIDA" "tipo desconhecido: devolve 0 e não imprime"
confere 0 "$(linhas)" "tipo desconhecido: não grava"
projeto sem-jq
SAIDA=$(CLAUDE_PROJECT_DIR="$P" bash -c 'source "$1"; PATH=/nonexistent; registrar_evento bloqueio protect-files adr-aceito x; echo "rc=$?"' _ "$LIB" 2>&1)
confere "rc=0" "$SAIDA" "sem jq: devolve 0 e não imprime"
confere 0 "$(linhas)" "sem jq: não grava"

if [[ $falhas -gt 0 ]]; then
  echo "✖ $falhas caso(s) de eventos falharam" >&2
  exit 1
fi
echo "✔ todos os casos de eventos passaram"
