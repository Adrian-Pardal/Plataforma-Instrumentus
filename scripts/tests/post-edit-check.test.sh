#!/usr/bin/env bash
# post-edit-check.test.sh — testes do hook post-edit-check.sh (hook PostToolUse: roda "verify.sh quick" depois de editar código).
# O projeto temporário usa um verify.sh FALSO: ele grava um arquivo-marcador (prova de que foi chamado)
# e sai com o código pedido. Assim o teste não depende de Maven/npm e sabe se o verify rodou ou não.
# Uso: scripts/tests/post-edit-check.test.sh   (sai com 1 se algum caso falhar)
set -uo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
HOOK="$RAIZ/.claude/hooks/post-edit-check.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
falhas=0

MARCADOR="$TMP/projeto/marcador"

# ok/falha de uma condição já avaliada
confere() {   # confere <descrição> <0 se passou | outro valor se falhou>
  if [[ "$2" == 0 ]]; then
    echo "  ok    $1"
  else
    echo "  FALHA $1" >&2
    falhas=$((falhas + 1))
  fi
}

resultado() {   # resultado <esperado> <obtido> <descrição>
  if [[ "$1" == "$2" ]]; then
    echo "  ok    ($1) $3"
  else
    echo "  FALHA (esperado $1, veio $2) $3" >&2
    falhas=$((falhas + 1))
  fi
}

# Recria o projeto com um verify.sh falso. $1 = código de saída · $2 = quantas linhas imprimir antes de sair.
verify_falso() {   # verify_falso <código> [linhas]
  rm -rf "$TMP/projeto"
  mkdir -p "$TMP/projeto/scripts"
  cat > "$TMP/projeto/scripts/verify.sh" <<EOF
#!/usr/bin/env bash
touch "$MARCADOR"
for i in \$(seq 1 ${2:-0}); do echo "linha \$i"; done
exit $1
EOF
  chmod +x "$TMP/projeto/scripts/verify.sh"
}

# Roda o hook para uma edição em $1. Sem CLAUDE_PROJECT_DIR (numa sessão real ele aponta para o projeto de verdade).
rodar_hook() {   # rodar_hook <file_path>
  jq -n --arg p "$1" --arg d "$TMP/projeto" '{tool_name: "Edit", tool_input: {file_path: $p}, cwd: $d}' \
    | env -u CLAUDE_PROJECT_DIR "$HOOK" 2>"$TMP/stderr" >/dev/null
}

echo "▶ post-edit-check: o que dispara o verify"
verify_falso 0
rodar_hook "$TMP/projeto/README.md"; resultado 0 "$?" "arquivo .md sai com 0"
[[ ! -e "$MARCADOR" ]]; confere ".md não rodou o verify.sh" "$?"

verify_falso 0
rodar_hook "$TMP/projeto/src/App.java"; resultado 0 "$?" "arquivo .java sai com 0 (verify passou)"
[[ -e "$MARCADOR" ]]; confere ".java rodou o verify.sh" "$?"

verify_falso 0
rodar_hook "$TMP/projeto/pom.xml"; resultado 0 "$?" "pom.xml sai com 0 (verify passou)"
[[ -e "$MARCADOR" ]]; confere "pom.xml rodou o verify.sh" "$?"

echo "▶ post-edit-check: verify falhando"
verify_falso 1 60
rodar_hook "$TMP/projeto/src/App.java"; resultado 2 "$?" "verify falhando dá 2"
grep -q '^linha 60$' "$TMP/stderr"; confere "mostra a última linha da saída (linha 60)" "$?"
grep -q '^linha 21$' "$TMP/stderr"; confere "mostra a 40ª linha contando do fim (linha 21)" "$?"
! grep -q '^linha 20$' "$TMP/stderr"; confere "não mostra a linha 20 (só as últimas 40)" "$?"

if [[ $falhas -gt 0 ]]; then echo "✖ $falhas caso(s) falharam" >&2; exit 1; fi
echo "✔ todos os casos passaram"
