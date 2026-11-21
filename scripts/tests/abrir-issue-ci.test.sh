#!/usr/bin/env bash
# abrir-issue-ci.test.sh — testes do scripts/abrir-issue-ci.sh (usa um "gh" falso; não chama o GitHub).
# Uso: scripts/tests/abrir-issue-ci.test.sh   (sai com 1 se algum caso falhar)
set -uo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$RAIZ/scripts/abrir-issue-ci.sh"
FALSO="$(mktemp -d)"; trap 'rm -rf "$FALSO"' EXIT
falhas=0
URL="https://github.com/o/r/actions/runs/123"

# gh falso: grava os argumentos de cada chamada em chamadas.log. "issue list" imprime $FAKE_ABERTAS (padrão 0)
# e falha se FAKE_LISTA=erro; "issue create" falha se FAKE_CRIAR=erro.
# As aspas simples são de propósito: $* e as variáveis devem ser lidos pelo gh falso, não aqui.
# shellcheck disable=SC2016
printf '%s\n' '#!/usr/bin/env bash' \
  'echo "$*" >> "$(dirname "$0")/chamadas.log"' \
  'case "$1 $2" in' \
  '  "issue list") [[ "${FAKE_LISTA:-}" != erro ]] || exit 1; echo "${FAKE_ABERTAS:-0}" ;;' \
  '  "issue create") [[ "${FAKE_CRIAR:-}" != erro ]] || exit 1; echo "https://github.com/o/r/issues/1" ;;' \
  '  *) exit 9 ;;' \
  'esac' > "$FALSO/gh"
chmod +x "$FALSO/gh"

caso() {   # caso <descrição> <código esperado> <issues criadas esperadas> [argumentos do env...]
  local descricao="$1" esp_rc="$2" esp_criou="$3" rc criou
  shift 3
  : > "$FALSO/chamadas.log"
  env RUN_URL="$URL" SHA=abc123 "$@" PATH="$FALSO:$PATH" "$SCRIPT" >/dev/null 2>&1
  rc=$?
  criou=$(grep -c '^issue create' "$FALSO/chamadas.log")
  if [[ "$rc" == "$esp_rc" && "$criou" == "$esp_criou" ]]; then
    echo "  ok    ($rc) $descricao"
  else
    echo "  FALHA $descricao: rc=$rc (esperado $esp_rc), issues criadas=$criou (esperado $esp_criou)" >&2
    falhas=$((falhas + 1))
  fi
}

echo "▶ abrir-issue-ci: abre uma issue só se não houver outra aberta"
caso "sem issue aberta: abre uma"            0 1
caso "com 1 issue aberta: não duplica"       0 0 FAKE_ABERTAS=1
caso "com 3 issues abertas: não duplica"     0 0 FAKE_ABERTAS=3

echo "▶ abrir-issue-ci: erros"
caso "sem RUN_URL (vazia): erro de uso (2)"  2 0 RUN_URL=
caso "consulta falhou: não abre às cegas (1)" 1 0 FAKE_LISTA=erro
caso "criar falhou: propaga o erro (1)"      1 1 FAKE_CRIAR=erro

echo "▶ abrir-issue-ci: o que vai na issue"
: > "$FALSO/chamadas.log"
RUN_URL="$URL" SHA=abc123 PATH="$FALSO:$PATH" "$SCRIPT" >/dev/null 2>&1
criar=$(awk '/^issue create/ {p=1} p' "$FALSO/chamadas.log")
if grep -q -- '--label incidente' <<<"$criar" && grep -q "$URL" <<<"$criar" \
  && grep -q abc123 <<<"$criar"; then
  echo "  ok    etiqueta incidente, link do log e commit"
else
  echo "  FALHA a issue não leva a etiqueta incidente, o link do log e o commit" >&2
  falhas=$((falhas + 1))
fi

echo "▶ abrir-issue-ci: a consulta olha só issues abertas, com a etiqueta"
: > "$FALSO/chamadas.log"
RUN_URL="$URL" SHA=abc123 PATH="$FALSO:$PATH" "$SCRIPT" >/dev/null 2>&1
lista=$(grep '^issue list' "$FALSO/chamadas.log")
if grep -q -- '--state open' <<<"$lista" && grep -q -- '--label incidente' <<<"$lista"; then
  echo "  ok    issue list com --state open e --label incidente"
else
  echo "  FALHA a consulta não filtra por issues abertas e pela etiqueta incidente" >&2
  falhas=$((falhas + 1))
fi

if [[ $falhas -gt 0 ]]; then echo "✖ $falhas caso(s) falharam" >&2; exit 1; fi
echo "✔ todos os casos passaram"
