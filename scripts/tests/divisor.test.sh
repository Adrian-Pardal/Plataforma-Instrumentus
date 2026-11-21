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

echo "▶ divisor: aspas, apóstrofos e escape"
# Já passam com a versão da T1 (guardas): o apóstrofo dentro de aspas duplas não fecha nada (ERR-003).
caso_segmentos "apóstrofo dentro de aspas duplas"   "echo \"it's\" && ls"        "[echo \"it's\"][ls]"
caso_segmentos "aspas duplas dentro de aspas simples" "echo 'say \"hi\"; ok' && ls" "[echo 'say \"hi\"; ok'][ls]"
caso_segmentos "dois apóstrofos em citações diferentes (ERR-003)" \
  "gh pr merge 1 --body \"it's\" --squash --subject \"x's\"" \
  "[gh pr merge 1 --body \"it's\" --squash --subject \"x's\"]"
caso_segmentos "aspas coladas na palavra"           'echo a"b;c"d'               '[echo a"b;c"d]'
caso_segmentos "barra dentro de aspas simples é literal" "echo 'a\\' && ls"       "[echo 'a\\'][ls]"
caso_segmentos "barra escapada e depois separador"  'echo a\\; ls'               '[echo a\\][ls]'
caso_segmentos "barra no fim do texto"              $'echo a\\'                  $'[echo a\\]'
# Falham com a versão da T1 (escape):
caso_segmentos "\; fora de aspas não separa"        'echo a\;b'                  '[echo a\;b]'
caso_segmentos "\& fora de aspas não separa"        'echo a\&b'                  '[echo a\&b]'
caso_segmentos "\" fora de aspas não abre aspas"    'echo \"a && b'              '[echo \"a][b]'
caso_segmentos "\" dentro de aspas duplas não fecha" 'echo "a\"b;c" && ls'       '[echo "a\"b;c"][ls]'
caso_segmentos "continuação de linha (\ + quebra) não separa" $'ls \\\n-la'     $'[ls \\\n-la]'

# Desempenho: o hook roda em TODO comando Bash. Medido antes da correção: 14 KB levava 5,5 s (quadrático).
# O limite é folgado de propósito (3 s), para não falhar em máquina lenta.
caso_desempenho() {   # caso_desempenho <descrição> <repetições> <limite em ms>
  local descricao="$1" n="$2" limite_ms="$3" cmd="" k ini fim ms
  for ((k = 0; k < n; k++)); do cmd+='echo "x;y" && '; done
  cmd+="ls"
  ini=${EPOCHREALTIME/./}; dividir_comando "$cmd"; fim=${EPOCHREALTIME/./}
  ms=$(((fim - ini) / 1000))
  if [[ ${#SEGMENTOS[@]} -eq $((n + 1)) && $ms -le $limite_ms ]]; then
    echo "  ok    $descricao (${ms} ms)"
  else
    echo "  FALHA $descricao: ${#SEGMENTOS[@]} segmentos (esperado $((n + 1))) em ${ms} ms (limite ${limite_ms} ms)" >&2
    falhas=$((falhas + 1))
  fi
}
echo "▶ divisor: desempenho"
caso_desempenho "comando de 14 KB (1000 comandos)" 1000 3000

if [[ $falhas -gt 0 ]]; then echo "✖ $falhas caso(s) falharam" >&2; exit 1; fi
echo "✔ todos os casos passaram"
