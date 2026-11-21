#!/usr/bin/env bash
# divisor.test.sh — testes do divisor de comandos (.claude/hooks/lib/divisor.sh). Plano 001, T1.
# Uso: scripts/tests/divisor.test.sh   (sai com 1 se algum caso falhar)
set -uo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=/dev/null
source "$RAIZ/.claude/hooks/lib/divisor.sh"
falhas=0

caso_segmentos() {   # caso_segmentos <descrição> <comando> <esperado: cada segmento entre colchetes>
  local descricao="$1" cmd="$2" esperado="$3" obtido="" s
  dividir_comando "$cmd"
  for s in "${SEGMENTOS[@]}"; do obtido+="[$s]"; done
  if [[ "$obtido" == "$esperado" ]]; then
    echo "  ok    $descricao"
  else
    echo "  FALHA $descricao: esperado '$esperado', veio '$obtido'" >&2
    falhas=$((falhas + 1))
  fi
}

echo "▶ divisor: separadores"
caso_segmentos "um comando só"              'ls -la'            '[ls -la]'
caso_segmentos "&&"                         'a && b'            '[a][b]'
caso_segmentos "||"                         'a || b'            '[a][b]'
caso_segmentos ";"                          'a ; b'             '[a][b]'
caso_segmentos "| (pipe)"                   'a | b'             '[a][b]'
caso_segmentos "|& (pipe com stderr)"       'a |& b'            '[a][b]'
caso_segmentos "& (segundo plano)"          'a & b'             '[a][b]'
caso_segmentos "quebra de linha"            $'a\nb'             '[a][b]'
caso_segmentos "vários juntos"              'a && b | c ; d'    '[a][b][c][d]'
caso_segmentos "espaços sobrando"           '  a   &&   b  '    '[a][b]'
caso_segmentos "separador no fim"           'a ;'               '[a]'
caso_segmentos "comando vazio"              ''                  ''

echo "▶ divisor: o que NÃO separa (redirecionamentos)"
caso_segmentos "2>&1 é redirecionamento"    'ls 2>&1'           '[ls 2>&1]'
caso_segmentos "&> é redirecionamento"      'ls &> out'         '[ls &> out]'
caso_segmentos ">& é redirecionamento"      'ls >& out'         '[ls >& out]'
caso_segmentos ">| não é pipe"              'echo x >| f'       '[echo x >| f]'

echo "▶ divisor: aspas (versão simples)"
caso_segmentos "| entre aspas duplas"       'echo "a|b"'        '[echo "a|b"]'
caso_segmentos "; entre aspas simples"      "echo 'x;y' && ls"  "[echo 'x;y'][ls]"
caso_segmentos "&& entre aspas"             'echo "a && b" || c' '[echo "a && b"][c]'

echo "▶ divisor: o estado não vaza entre chamadas"
dividir_comando 'a ; b'
caso_segmentos "a segunda chamada começa do zero" 'c' '[c]'

if [[ $falhas -gt 0 ]]; then echo "✖ $falhas caso(s) falharam" >&2; exit 1; fi
echo "✔ todos os casos passaram"
