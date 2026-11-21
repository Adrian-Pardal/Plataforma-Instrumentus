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

caso_tokens() {   # caso_tokens <descrição> <segmento> <tokens, cada um entre colchetes> <citado: 0/1 por vírgula> [ininterpretável: 0|1]
  local descricao="$1" seg="$2" esp_tok="$3" esp_cit="$4" esp_int="${5:-0}" tok="" cit="" t motivo_ok=1
  tokenizar_segmento "$seg"
  for t in "${TOK[@]}"; do tok+="[$t]"; done
  cit=$(IFS=,; echo "${TOK_CITADO[*]}")
  if [[ "$esp_int" == 1 ]]; then [[ -n "$MOTIVO" ]] || motivo_ok=0; else [[ -z "$MOTIVO" ]] || motivo_ok=0; fi
  if [[ "$tok" == "$esp_tok" && "$cit" == "$esp_cit" && "$ININTERPRETAVEL" == "$esp_int" && $motivo_ok -eq 1 ]]; then
    echo "  ok    $descricao"
  else
    echo "  FALHA $descricao: esperado tokens='$esp_tok' citado='$esp_cit' interpretável=$esp_int," \
      "veio tokens='$tok' citado='$cit' ininterpretável=$ININTERPRETAVEL motivo='$MOTIVO'" >&2
    falhas=$((falhas + 1))
  fi
}

echo "▶ tokens: palavras"
caso_tokens "palavras simples"                'ls -la'                   '[ls][-la]'               '0,0'
caso_tokens "espaços e tabs sobrando"         $'a  \t b'                 '[a][b]'                  '0,0'
caso_tokens "segmento vazio"                  ''                         ''                        ''

echo "▶ tokens: aspas"
caso_tokens "aspas duplas juntam"             'echo "a b"'               '[echo][a b]'             '0,1'
caso_tokens "aspas simples juntam"            "echo 'a b'"               '[echo][a b]'             '0,1'
caso_tokens "aspas coladas na palavra"        'a"b c"d'                  '[ab cd]'                 '1'
caso_tokens "aspas vazias são uma palavra"    'echo ""'                  '[echo][]'                '0,1'
caso_tokens "opção entre aspas continua opção" 'gh pr merge "--squash"'  '[gh][pr][merge][--squash]' '0,0,0,1'
caso_tokens "operador dentro de aspas"        'cmd --body "a > b"'       '[cmd][--body][a > b]'    '0,0,1'
caso_tokens "apóstrofo dentro de aspas duplas" "echo \"it's\""           "[echo][it's]"            '0,1'
caso_tokens "dois apóstrofos (ERR-003)" \
  "gh pr merge 1 --body \"it's\" --squash --subject \"x's\"" \
  "[gh][pr][merge][1][--body][it's][--squash][--subject][x's]" '0,0,0,0,0,1,0,0,1'

echo "▶ tokens: barra"
caso_tokens "barra protege o espaço"          'echo a\ b'                '[echo][a b]'             '0,1'
caso_tokens "barra protege o >"               'echo a\>b'                '[echo][a>b]'             '0,1'
caso_tokens "\" dentro de aspas duplas"       'echo "a\"b"'              '[echo][a"b]'             '0,1'
caso_tokens "\\ dentro de aspas duplas"       'echo "a\\b"'              '[echo][a\b]'             '0,1'
caso_tokens "barra comum dentro de aspas duplas fica" 'echo "a\b"'       '[echo][a\b]'             '0,1'
caso_tokens "barra dentro de aspas simples é literal" "echo 'a\\b'"      '[echo][a\b]'             '0,1'
caso_tokens "continuação de linha some"       $'ls \\\n-la'              '[ls][-la]'               '0,0'

echo "▶ tokens: aspas sem fechar (ininterpretável)"
caso_tokens "aspas duplas sem fechar"         'echo "abc'                '[echo][abc]'             '0,1' 1
caso_tokens "aspas simples sem fechar"        "echo 'abc"                '[echo][abc]'             '0,1' 1
tokenizar_segmento 'echo "abc'
caso_tokens "o estado não vaza (volta a interpretável)" 'echo ok'        '[echo][ok]'              '0,0'

caso_mascara() {   # caso_mascara <descrição> <segmento> <máscaras, cada uma entre colchetes>
  local descricao="$1" seg="$2" esperado="$3" obtido="" m
  tokenizar_segmento "$seg"
  for m in "${TOK_MASCARA[@]}"; do obtido+="[$m]"; done
  if [[ "$obtido" == "$esperado" ]]; then
    echo "  ok    $descricao"
  else
    echo "  FALHA $descricao: esperado '$esperado', veio '$obtido'" >&2
    falhas=$((falhas + 1))
  fi
}

echo "▶ máscara: 1 = letra que veio de aspas ou barra, 0 = letra escrita solta"
caso_mascara "palavras soltas"                   'ls -la'            '[00][000]'
caso_mascara "aspas duplas"                      'echo "a b"'        '[0000][111]'
caso_mascara "aspas coladas na palavra"          'a"b"c'             '[010]'
caso_mascara "opção entre aspas colada a um >"   "gh '--squash'>x"   '[00][1111111100]'
caso_mascara "barra protege o >"                 'echo a\>b'         '[0000][010]'
caso_mascara "aspas vazias"                      'echo ""'           '[0000][]'
caso_mascara "barra dentro de aspas duplas"      'echo "a\"b"'       '[0000][111]'

caso_redir() {   # caso_redir <descrição> <segmento> <palavras> <escrita> <leitura> [ininterpretável: 0|1]
  local descricao="$1" seg="$2" esp_tok="$3" esp_esc="$4" esp_lei="$5" esp_int="${6:-0}" tok="" esc="" lei="" t alinhado=1
  tokenizar_segmento "$seg"
  separar_redirecionamentos
  for t in "${TOK[@]}"; do tok+="[$t]"; done
  for t in "${REDIR_ESCRITA[@]}"; do esc+="[$t]"; done
  for t in "${REDIR_LEITURA[@]}"; do lei+="[$t]"; done
  [[ ${#TOK[@]} -eq ${#TOK_CITADO[@]} && ${#TOK[@]} -eq ${#TOK_MASCARA[@]} ]] || alinhado=0
  if [[ "$tok" == "$esp_tok" && "$esc" == "$esp_esc" && "$lei" == "$esp_lei" && "$ININTERPRETAVEL" == "$esp_int" && $alinhado -eq 1 ]]; then
    echo "  ok    $descricao"
  else
    echo "  FALHA $descricao: esperado palavras='$esp_tok' escrita='$esp_esc' leitura='$esp_lei' interpretável=$esp_int," \
      "veio palavras='$tok' escrita='$esc' leitura='$lei' ininterpretável=$ININTERPRETAVEL alinhado=$alinhado" >&2
    falhas=$((falhas + 1))
  fi
}

echo "▶ redirecionamentos: saída"
caso_redir "> separado"                  'ls > out'              '[ls]'      '[out]'      ''
caso_redir "> colado ao alvo"            'ls >out'               '[ls]'      '[out]'      ''
caso_redir "> colado à palavra"          'ls>out'                '[ls]'      '[out]'      ''
caso_redir ">>"                          'ls >> log'             '[ls]'      '[log]'      ''
caso_redir "2>&1 não tem alvo"           'ls 2>&1'               '[ls]'      ''           ''
caso_redir "> e depois 2>&1"             'ls > /tmp/log 2>&1'    '[ls]'      '[/tmp/log]' ''
caso_redir "&>"                          'ls &> out'             '[ls]'      '[out]'      ''
caso_redir "&>>"                         'ls &>> out'            '[ls]'      '[out]'      ''
caso_redir ">& com arquivo"              'ls >& out'             '[ls]'      '[out]'      ''
caso_redir ">&2 não tem alvo"            'ls >&2'                '[ls]'      ''           ''
caso_redir ">|"                          'echo x >| f'           '[echo][x]' '[f]'        ''
caso_redir "2> com espaço"               'ls 2> err'             '[ls]'      '[err]'      ''
caso_redir "2> colado"                   'ls 2>err'              '[ls]'      '[err]'      ''
caso_redir "dois >"                      'ls > a > b'            '[ls]'      '[a][b]'     ''
caso_redir "redirecionamento no começo"  '> out ls'              '[ls]'      '[out]'      ''
caso_redir "2 solto é uma palavra"       'ls 2 > out'            '[ls][2]'   '[out]'      ''

echo "▶ redirecionamentos: entrada"
caso_redir "<"                           'cat < in'              '[cat]'     ''           '[in]'
caso_redir "< colado"                    'cat <in'               '[cat]'     ''           '[in]'
caso_redir "< e >"                       'cat < in > out'        '[cat]'     '[out]'      '[in]'
caso_redir "<<< (here-string) não é arquivo" 'cat <<< x'         '[cat]'     ''           ''
caso_redir "<< (heredoc) não é arquivo"  'cat << EOF'            '[cat]'     ''           ''

echo "▶ redirecionamentos: o que é texto, não operador"
caso_redir "> dentro de aspas"           'echo "a > b"'          '[echo][a > b]' ''       ''
caso_redir '">" é só texto'              'echo ">"'              '[echo][>]' ''           ''
caso_redir "\> protegido por barra"      'echo a\>b'             '[echo][a>b]' ''         ''
caso_redir "alvo entre aspas"            'ls > "a b"'            '[ls]'      '[a b]'      ''
caso_redir "alvo com aspas coladas"      'ls >"a b"c'            '[ls]'      '[a bc]'     ''
caso_redir "dígito entre aspas não é descritor" 'echo "2">x'     '[echo][2]' '[x]'        ''

echo "▶ redirecionamentos: os casos do ERR-001 e ERR-002 (opção proibida colada a um operador)"
caso_redir "opção colada ao >"           'gh pr merge 1 --merge --squash>x'      '[gh][pr][merge][1][--merge][--squash]' '[x]' ''
caso_redir "opção entre aspas colada ao >" "gh pr merge 1 --merge '--squash'>x"  '[gh][pr][merge][1][--merge][--squash]' '[x]' ''
caso_redir "opção entre aspas e 2>&1"    'gh pr merge 1 --merge "--admin" 2>&1'  '[gh][pr][merge][1][--merge][--admin]'  ''    ''
caso_redir "--admin2 não é opção (2 colado à palavra)" 'gh pr merge 1 --merge "--admin"2>&1' '[gh][pr][merge][1][--merge][--admin2]' '' ''
caso_redir "número entre aspas colado ao >" 'gh pr merge 1 --merge "12">x'       '[gh][pr][merge][1][--merge][12]'      '[x]' ''
caso_redir "--body \">\" não é redirecionamento" 'gh pr merge 1 --merge --body ">" --squash' '[gh][pr][merge][1][--merge][--body][>][--squash]' '' ''
caso_redir "opção entre aspas colada ao <" 'gh pr merge 1 --merge "--squash"<x'  '[gh][pr][merge][1][--merge][--squash]' ''    '[x]'
caso_redir ">| separado"                 'gh pr merge 7 --merge >| x --squash'   '[gh][pr][merge][7][--merge][--squash]' '[x]' ''
caso_redir "2>| colado"                  'gh pr merge 7 --merge 2>|x --admin'    '[gh][pr][merge][7][--merge][--admin]'  '[x]' ''
caso_redir "opção colada ao &>"          'gh pr merge 7 --merge --squash&>x'     '[gh][pr][merge][7][--merge][--squash]' '[x]' ''

echo "▶ redirecionamentos: erro de sintaxe"
caso_redir "operador sem alvo"           'echo x >'              '[echo][x]' ''           ''  1

if [[ $falhas -gt 0 ]]; then echo "✖ $falhas caso(s) falharam" >&2; exit 1; fi
echo "✔ todos os casos passaram"
