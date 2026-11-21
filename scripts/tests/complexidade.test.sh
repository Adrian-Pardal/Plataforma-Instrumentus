#!/usr/bin/env bash
# complexidade.test.sh — testes do scripts/complexidade.sh (aproximação da complexidade ciclomática).
# Uso: scripts/tests/complexidade.test.sh   (sai com 1 se algum caso falhar)
set -uo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FERRAMENTA="$RAIZ/scripts/complexidade.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
falhas=0

caso() {   # caso <descrição> <código esperado> <início da saída esperada> <conteúdo> [opções...]
  local descricao="$1" esp_rc="$2" esp_saida="$3" conteudo="$4" saida rc
  shift 4
  printf '%s\n' "$conteudo" > "$TMP/f.sh"
  saida=$("$FERRAMENTA" "$@" "$TMP/f.sh" 2>&1); rc=$?
  if [[ "$rc" == "$esp_rc" && "$saida" == "$esp_saida"* ]]; then
    echo "  ok    ($rc) $descricao"
  else
    echo "  FALHA $descricao: rc=$rc (esperado $esp_rc), saída: $saida" >&2
    falhas=$((falhas + 1))
  fi
}

echo "▶ complexidade.sh: contagem por função"
caso "função sem decisão vale 1"            0 "1 f()"  $'f() {\n  echo oi\n}'
caso "if, elif, while, for, && e ||"        0 "7 f()"  $'f() {\n  if a; then b; elif c; then d; fi\n  while e; do f; done\n  for g in h; do :; done\n  x && y || z\n}'
caso "cada ramo de case conta 1"            0 "4 f()"  $'f() {\n  case "$1" in\n    a) x ;;\n    b) y ;;\n    *) z ;;\n  esac\n}'
caso "if em aspas ou comentário não conta"  0 "1 f()"  $'f() {\n  echo "if a && b"   # while x\n}'
caso "palavra reservada no padrão do case não conta" 0 "4 f()" $'f() {\n  case "$1" in\n    if | while | until) x ;;\n    elif | for) y ;;\n    *) z ;;\n  esac\n}'

echo "▶ complexidade.sh: limite e uso"
caso "acima do limite reprova (1)"          1 "3 f()"  $'f() {\n  if a; then b; fi\n  if c; then d; fi\n}' -l 2
caso "no limite passa (0)"                  0 "3 f()"  $'f() {\n  if a; then b; fi\n  if c; then d; fi\n}' -l 3

if "$FERRAMENTA" >/dev/null 2>&1; then rc=0; else rc=$?; fi
if [[ "$rc" == 2 ]]; then
  echo "  ok    (2) sem argumentos é erro de uso"
else
  echo "  FALHA sem argumentos: rc=$rc (esperado 2)" >&2
  falhas=$((falhas + 1))
fi

if [[ $falhas -gt 0 ]]; then echo "✖ $falhas caso(s) falharam" >&2; exit 1; fi
echo "✔ todos os casos passaram"
