#!/usr/bin/env bash
# complexidade.sh — aproxima a complexidade ciclomática das funções de scripts bash (plano 001, T7f).
# Uso: scripts/complexidade.sh [-l LIMITE] arquivo.sh...   (LIMITE padrão: 10)
# Conta 1 + os pontos de decisão de cada função: if, elif, while, until, for, && , || e cada ramo de case.
# É uma APROXIMAÇÃO por texto, não a métrica oficial: serve para ver a tendência e apontar função grande demais.
# Saída: "pontos função (arquivo)", da maior para a menor. Sai com 1 se alguma função passa do limite e com 2 se
# faltar argumento.
set -uo pipefail

limite=10
if [[ "${1:-}" == "-l" ]]; then limite="${2:?falta o valor de -l}"; shift 2; fi
(($# > 0)) || { echo "uso: $0 [-l LIMITE] arquivo.sh..." >&2; exit 2; }

awk -v limite="$limite" '
  function indent(s) { match(s, /^[ \t]*/); return RLENGTH }
  FNR == 1 { nome = ""; case_ind = -1 }
  /^[a-zA-Z_][a-zA-Z0-9_]*\(\)[ \t]*\{/ { nome = $1; n = 1; case_ind = -1; next }
  /^\}/ { if (nome != "") { printf "%d %s (%s)\n", n, nome, FILENAME; if (n > limite) ruim = 1 }; nome = ""; next }
  nome == "" { next }
  {
    linha = $0
    gsub(/"[^"]*"|'\''[^'\'']*'\''/, "", linha)   # texto entre aspas não é decisão
    sub(/[ \t]#.*/, "", linha)                     # comentário também não
    if (linha ~ /^[ \t]*#/) next
    n += gsub(/(^|[ ;({])(if|elif|while|until|for)[ (]/, "&", linha)
    n += gsub(/&&|\|\|/, "&", linha)
    if (case_ind >= 0) {
      if (linha ~ /^[ \t]*esac/) { case_ind = -1 }
      else if (indent(linha) == case_ind + 2 && linha ~ /\)/) n++    # um ramo do case
    } else if (linha ~ /(^|[ \t;])case .* in([ \t]|$)/) case_ind = indent(linha)
  }
  END { exit ruim }
' "$@" | sort -rn
exit "${PIPESTATUS[0]}"
