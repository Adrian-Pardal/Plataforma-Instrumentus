#!/usr/bin/env bash
# stop-verify.test.sh — testes do hook stop-verify.sh (hook Stop: roda "verify.sh test" antes de encerrar).
# Cada caso monta um projeto temporário (git + package.json + o verify.sh real) e roda o hook de verdade.
# Sem node/npm instalados, avisa e pula (o verify.sh usa npm para rodar o script "test").
# Uso: scripts/tests/stop-verify.test.sh   (sai com 1 se algum caso falhar)
set -uo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
HOOK="$RAIZ/.claude/hooks/stop-verify.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
falhas=0

if ! command -v node >/dev/null || ! command -v npm >/dev/null; then
  echo "• node/npm não instalados: testes pulados"
  exit 0
fi

# Mostra se o código de saída é o esperado; em caso de falha, mostra o stderr do hook.
resultado() {   # resultado <esperado> <obtido> <descrição> [stderr]
  if [[ "$1" == "$2" ]]; then
    echo "  ok    ($1) $3"
  else
    echo "  FALHA (esperado $1, veio $2) $3" >&2
    [[ -n "${4:-}" ]] && echo "$4" >&2
    falhas=$((falhas + 1))
  fi
}

# Cria um projeto git limpo (tudo commitado) cujo script "test" do package.json é $2 e guarda o caminho em P.
# (Sem echo dentro de $(...): num subshell, o exit não pararia o teste.)
projeto() {   # projeto <nome> <comando do script test>
  local dir="$TMP/$1"
  mkdir -p "$dir/scripts"
  cp "$RAIZ/scripts/verify.sh" "$dir/scripts/verify.sh"
  jq -n --arg t "$2" '{name: "tmp", version: "1.0.0", scripts: {test: $t}}' > "$dir/package.json"
  git -C "$dir" init -q || { echo "FALHA: git init em $dir" >&2; exit 1; }
  git -C "$dir" add -A
  # Sem assinatura nem hooks globais do git: o commit da base não pode depender do ambiente de quem roda.
  git -C "$dir" -c user.name=teste -c user.email=teste@exemplo.com \
    -c commit.gpgsign=false -c core.hooksPath=/dev/null commit -q -m "base" \
    || { echo "FALHA: commit da base em $dir" >&2; exit 1; }
  P="$dir"
}

# Roda o hook com o JSON da entrada. Sem CLAUDE_PROJECT_DIR (numa sessão real ele aponta para o projeto de verdade).
rodar_hook() {   # rodar_hook <dir> <stop_hook_active: true|false>
  jq -n --arg d "$1" --argjson a "$2" '{cwd: $d, stop_hook_active: $a}' \
    | env -u CLAUDE_PROJECT_DIR "$HOOK" 2>"$TMP/stderr" >/dev/null
}

echo "▶ stop-verify"

# 1. Anti-loop: com stop_hook_active true sai com 0, mesmo com teste falhando e código alterado.
projeto anti-loop 'exit 1'
echo 'x' > "$P/app.js"
rodar_hook "$P" true; resultado 0 "$?" "stop_hook_active true deixa encerrar"

# 2. Sem mudança de código: só um .md alterado, e o teste falharia se rodasse.
projeto sem-codigo 'exit 1'
echo 'nota' > "$P/notas.md"
rodar_hook "$P" false; resultado 0 "$?" "só .md alterado: não roda os testes"

# 3. Teste falhando + arquivo de código alterado: bloqueia.
projeto falhando 'exit 1'
echo 'x' > "$P/app.js"
rodar_hook "$P" false; obtido=$?
resultado 2 "$obtido" "código alterado e teste falhando bloqueia" "$(cat "$TMP/stderr")"
if grep -q 'não estão 100% verdes' "$TMP/stderr"; then
  echo "  ok    a mensagem de bloqueio chegou no stderr"
else
  echo "  FALHA a mensagem de bloqueio não apareceu no stderr" >&2
  falhas=$((falhas + 1))
fi

# 4. Teste passando + arquivo de código alterado: deixa encerrar. O script "test" grava um marcador:
#    só o exit 0 não prova nada (sairia 0 também se o hook nem rodasse o verify).
projeto passando 'touch rodou'
echo 'x' > "$P/app.js"
rodar_hook "$P" false; resultado 0 "$?" "código alterado e teste passando deixa encerrar" "$(cat "$TMP/stderr")"
[[ -e "$P/rodou" ]]; resultado 0 "$?" "o hook rodou o script test (marcador existe)"

if [[ $falhas -gt 0 ]]; then echo "✖ $falhas caso(s) falharam" >&2; exit 1; fi
echo "✔ todos os casos passaram"
