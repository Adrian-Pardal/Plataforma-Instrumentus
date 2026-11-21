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

caso_sub() {   # caso_sub <descrição> <segmento> <esperado: "PROG=.. SUB=.. SUB2=.. ARGS=.. FLAGS=.. DIR=.. ENV=..">
  local descricao="$1" seg="$2" esperado="$3" a="" f="" e="" x obtido
  tokenizar_segmento "$seg"
  separar_redirecionamentos
  desembrulhar
  achar_subcomando
  for x in "${ARGS[@]}"; do a+="[$x]"; done
  for x in "${FLAGS_GLOBAIS[@]}"; do f+="[$x]"; done
  for x in "${ENV_PREFIXO[@]}"; do e+="[$x]"; done
  obtido="PROG=$PROG SUB=$SUB SUB2=$SUB2 ARGS=$a FLAGS=$f DIR=$DIR_GIT ENV=$e"
  if [[ "$obtido" == "$esperado" ]]; then
    echo "  ok    $descricao"
  else
    echo "  FALHA $descricao: esperado '$esperado', veio '$obtido'" >&2
    falhas=$((falhas + 1))
  fi
}

echo "▶ subcomando: git"
caso_sub "git push"                          'git push origin main'  'PROG=git SUB=push SUB2= ARGS=[origin][main] FLAGS= DIR= ENV='
caso_sub "-C leva um valor"                  'git -C /tmp push'      'PROG=git SUB=push SUB2= ARGS= FLAGS=[-C][/tmp] DIR=/tmp ENV='
caso_sub "-c leva um valor"                  'git -c k=v push origin' 'PROG=git SUB=push SUB2= ARGS=[origin] FLAGS=[-c][k=v] DIR= ENV='
caso_sub "--config-env leva um valor (furo do protect-push)" 'git --config-env a=B push origin main' \
  'PROG=git SUB=push SUB2= ARGS=[origin][main] FLAGS=[--config-env][a=B] DIR= ENV='
caso_sub "--attr-source leva um valor (furo do protect-push)" 'git --attr-source HEAD push origin main' \
  'PROG=git SUB=push SUB2= ARGS=[origin][main] FLAGS=[--attr-source][HEAD] DIR= ENV='
caso_sub "--git-dir=valor não consome o próximo" 'git --git-dir=/x push' 'PROG=git SUB=push SUB2= ARGS= FLAGS=[--git-dir=/x] DIR= ENV='
caso_sub "--git-dir valor consome o próximo" 'git --git-dir /x push'  'PROG=git SUB=push SUB2= ARGS= FLAGS=[--git-dir][/x] DIR= ENV='
caso_sub "flag sem valor é booleana"         'git --no-pager log'    'PROG=git SUB=log SUB2= ARGS= FLAGS=[--no-pager] DIR= ENV='
caso_sub "git sozinho"                       'git'                   'PROG=git SUB= SUB2= ARGS= FLAGS= DIR= ENV='
caso_sub "flag com valor faltando"           'git -c'                'PROG=git SUB= SUB2= ARGS= FLAGS=[-c] DIR= ENV='
caso_sub "dois -C: vale o último"            'git -C a -C b push'    'PROG=git SUB=push SUB2= ARGS= FLAGS=[-C][a][-C][b] DIR=b ENV='
caso_sub "-C com valor entre aspas"          'git -C "/tmp/a b" push' 'PROG=git SUB=push SUB2= ARGS= FLAGS=[-C][/tmp/a b] DIR=/tmp/a b ENV='
caso_sub "flag entre aspas continua flag"    'git "-C" /x push'      'PROG=git SUB=push SUB2= ARGS= FLAGS=[-C][/x] DIR=/x ENV='
caso_sub "redirecionamento não é argumento"  'git push origin main > log' 'PROG=git SUB=push SUB2= ARGS=[origin][main] FLAGS= DIR= ENV='

echo "▶ subcomando: gh"
caso_sub "gh pr merge"                       'gh pr merge 1 --merge' 'PROG=gh SUB=pr SUB2=merge ARGS=[1][--merge] FLAGS= DIR= ENV='
caso_sub "flag antes do pr (-R x)"           'gh -R x pr merge 1 --squash' 'PROG=gh SUB=pr SUB2=merge ARGS=[1][--squash] FLAGS=[-R][x] DIR= ENV='
caso_sub "flag entre pr e merge (-R x)"      'gh pr -R x merge 12 --squash' 'PROG=gh SUB=pr SUB2=merge ARGS=[12][--squash] FLAGS=[-R][x] DIR= ENV='
caso_sub "flag antes de api"                 'gh --paginate=true api -X PUT repos/o/r/pulls/12/merge' \
  'PROG=gh SUB=api SUB2= ARGS=[-X][PUT][repos/o/r/pulls/12/merge] FLAGS=[--paginate=true] DIR= ENV='
caso_sub "--hostname=valor antes de api"     'gh --hostname=github.com api repos/o/r' 'PROG=gh SUB=api SUB2= ARGS=[repos/o/r] FLAGS=[--hostname=github.com] DIR= ENV='
caso_sub "flag antes de alias"               'gh --clobber=true alias set m x' 'PROG=gh SUB=alias SUB2=set ARGS=[m][x] FLAGS=[--clobber=true] DIR= ENV='
caso_sub "subcomando entre aspas"            'gh pr "merge" 12'      'PROG=gh SUB=pr SUB2=merge ARGS=[12] FLAGS= DIR= ENV='
caso_sub "merge como argumento, não como ação" 'gh pr view merge'   'PROG=gh SUB=pr SUB2=view ARGS=[merge] FLAGS= DIR= ENV='
caso_sub "flags depois da ação são argumentos" 'gh pr merge --merge 1 -R o/r' 'PROG=gh SUB=pr SUB2=merge ARGS=[--merge][1][-R][o/r] FLAGS= DIR= ENV='

echo "▶ subcomando: variáveis na frente e programa por caminho"
caso_sub "VAR=valor antes do gh"             'FOO=1 gh pr merge 12 --merge' 'PROG=gh SUB=pr SUB2=merge ARGS=[12][--merge] FLAGS= DIR= ENV=[FOO=1]'
caso_sub "GH_REPO antes do gh"               'GH_REPO=o/r gh pr merge 1 --merge' 'PROG=gh SUB=pr SUB2=merge ARGS=[1][--merge] FLAGS= DIR= ENV=[GH_REPO=o/r]'
caso_sub "programa por caminho"              '/usr/bin/gh pr view 1' 'PROG=gh SUB=pr SUB2=view ARGS=[1] FLAGS= DIR= ENV='
caso_sub "outro programa"                    'ls -la'                'PROG= SUB= SUB2= ARGS= FLAGS= DIR= ENV='
caso_sub "git como argumento de outro programa" 'echo git push'      'PROG= SUB= SUB2= ARGS= FLAGS= DIR= ENV='

caso_wrap() {   # caso_wrap <descrição> <segmento> <palavras> <wrappers tirados> [não suportado]
  local descricao="$1" seg="$2" esp_tok="$3" esp_wr="$4" esp_ns="${5:-}" tok="" wr="" x alinhado=1
  tokenizar_segmento "$seg"
  separar_redirecionamentos
  desembrulhar
  for x in "${TOK[@]}"; do tok+="[$x]"; done
  for x in "${WRAPPERS[@]}"; do wr+="[$x]"; done
  [[ ${#TOK[@]} -eq ${#TOK_CITADO[@]} && ${#TOK[@]} -eq ${#TOK_MASCARA[@]} ]] || alinhado=0
  if [[ "$tok" == "$esp_tok" && "$wr" == "$esp_wr" && "$WRAPPER_NAO_SUPORTADO" == "$esp_ns" && $alinhado -eq 1 ]]; then
    echo "  ok    $descricao"
  else
    echo "  FALHA $descricao: esperado palavras='$esp_tok' wrappers='$esp_wr' não-suportado='$esp_ns'," \
      "veio palavras='$tok' wrappers='$wr' não-suportado='$WRAPPER_NAO_SUPORTADO' alinhado=$alinhado" >&2
    falhas=$((falhas + 1))
  fi
}

echo "▶ wrappers: env, command, xargs, sudo, nohup, time"
caso_wrap "env"                              'env gh pr merge 1'          '[gh][pr][merge][1]'      '[env]'
caso_wrap "env com VAR=valor"                'env FOO=1 gh pr merge'      '[FOO=1][gh][pr][merge]'  '[env]'
caso_wrap "env -i"                           'env -i gh pr'               '[gh][pr]'                '[env]'
caso_wrap "env -u NOME"                      'env -u X gh pr'             '[gh][pr]'                '[env]'
caso_wrap "VAR=valor antes do env"           'VAR=1 env gh pr'            '[VAR=1][gh][pr]'         '[env]'
caso_wrap "command"                          'command gh pr merge 1'      '[gh][pr][merge][1]'      '[command]'
caso_wrap "command -p"                       'command -p gh pr'           '[gh][pr]'                '[command]'
caso_wrap "command -v só consulta"           'command -v gh'              '[command][-v][gh]'       ''
caso_wrap "builtin"                          'builtin gh pr'              '[gh][pr]'                '[builtin]'
caso_wrap "nohup"                            'nohup gh pr merge 1'        '[gh][pr][merge][1]'      '[nohup]'
caso_wrap "time"                             'time gh pr merge 1'         '[gh][pr][merge][1]'      '[time]'
caso_wrap "time -p"                          'time -p gh pr'              '[gh][pr]'                '[time]'
caso_wrap "sudo"                             'sudo gh pr merge 1'         '[gh][pr][merge][1]'      '[sudo]'
caso_wrap "sudo -u usuário"                  'sudo -u root gh pr'         '[gh][pr]'                '[sudo]'
caso_wrap "xargs sem flags"                  'xargs gh pr merge 1'        '[gh][pr][merge][1]'      '[xargs]'
caso_wrap "xargs com flags não é desembrulhado" 'xargs -n1 gh pr merge 1' '[xargs][-n1][gh][pr][merge][1]' '' 'xargs'
caso_wrap "vários wrappers"                  'env sudo nohup gh pr merge' '[gh][pr][merge]'         '[env][sudo][nohup]'
caso_wrap "wrapper sozinho"                  'env'                        ''                        '[env]'
caso_wrap "comando sem wrapper"              'ls -la'                     '[ls][-la]'               ''
caso_wrap "env como argumento"               'echo env gh'                '[echo][env][gh]'         ''

caso_wrap "env -S entrega o comando numa palavra só: não suportado" 'env -S "gh pr merge 1"' '[env][-S][gh pr merge 1]' '' 'env'

echo "▶ wrappers: grupos de comandos"
caso_wrap "subshell aninhado"                '( ( gh pr merge 1 ) )'      '[gh][pr][merge][1]'      '[(][(]'
caso_wrap "dois ( colados"                   '((gh pr merge 1))'          '[gh][pr][merge][1]'      '[(][(]'
caso_wrap "subshell colado"                  '(gh pr merge 1)'            '[gh][pr][merge][1]'      '[(]'
caso_wrap "subshell com espaços"             '( gh pr merge 1 )'          '[gh][pr][merge][1]'      '[(]'
caso_wrap "chaves"                           '{ gh pr merge 1'            '[gh][pr][merge][1]'      '[{]'
caso_wrap "( entre aspas não é subshell"     '"(gh" pr'                   '[(gh][pr]'               ''

echo "▶ wrappers: o comando de dentro é achado"
caso_sub "env com GH_REPO"                   'env GH_REPO=o/r gh pr merge 1' 'PROG=gh SUB=pr SUB2=merge ARGS=[1] FLAGS= DIR= ENV=[GH_REPO=o/r]'
caso_sub "sudo -u e git push"                'sudo -u root git push origin main' 'PROG=git SUB=push SUB2= ARGS=[origin][main] FLAGS= DIR= ENV='
caso_sub "xargs sem flags"                   'xargs gh pr merge 1'        'PROG=gh SUB=pr SUB2=merge ARGS=[1] FLAGS= DIR= ENV='
caso_sub "subshell com git -C"               '(git -C /x push)'           'PROG=git SUB=push SUB2= ARGS= FLAGS=[-C][/x] DIR=/x ENV='
caso_sub "xargs com flags: programa desconhecido" 'xargs -n1 git push'    'PROG= SUB= SUB2= ARGS= FLAGS= DIR= ENV='

echo "▶ tokens: \$( e crase fora de aspas simples são ininterpretáveis"
caso_tokens "substituição de comando em aspas duplas" $'echo "$(date)"'   $'[echo][$(date)]'   '0,1' 1
caso_tokens "substituição de comando solta"           $'echo $(date)'     $'[echo][$(date)]'   '0,0' 1
caso_tokens "crase solta"                             $'echo `date`'      $'[echo][`date`]'    '0,0' 1
caso_tokens "crase em aspas duplas"                   $'echo "a`date`b"'  $'[echo][a`date`b]'  '0,1' 1
caso_tokens "em aspas simples é literal"              $'echo \'$(date)\'' $'[echo][$(date)]'   '0,1'
caso_tokens "barra protege o \$( (literal)"           $'echo \\$(date)'   $'[echo][$(date)]'   '0,1'
caso_tokens "barra dentro de aspas duplas protege o \$( (literal)" $'echo "\\$(date)"' $'[echo][$(date)]' '0,1'
caso_tokens "variável simples não é ininterpretável"  $'echo "$VAR"'      $'[echo][$VAR]'      '0,1'

caso_falha_fechada() {   # caso_falha_fechada <descrição> <segmento> <bloquear|liberar>
  local descricao="$1" seg="$2" esperado="$3" obtido
  # shellcheck disable=SC2034  # PROTEGIDOS é lida por falha_fechada, em divisor.sh
  PROTEGIDOS=("git push" "gh pr merge" "gh api" "gh alias")
  analisar_segmento "$seg"
  if falha_fechada; then obtido=bloquear; else obtido=liberar; fi
  if [[ "$obtido" == "$esperado" ]]; then
    echo "  ok    $descricao"
  else
    echo "  FALHA $descricao: esperado $esperado, veio $obtido (PROG=$PROG SUB=$SUB SUB2=$SUB2 ininterpretável=$ININTERPRETAVEL)" >&2
    falhas=$((falhas + 1))
  fi
}

echo "▶ falha fechada: só bloqueia comando protegido ou programa que não se acha"
caso_falha_fechada "git commit com \$( na mensagem libera"  $'git commit -m "feat: $(date)"'          liberar
caso_falha_fechada "git commit com heredoc libera"          $'git commit -m "$(cat <<\'EOF\'\nmsg\nEOF\n)"' liberar
caso_falha_fechada "echo com \$(git ...) libera"            $'echo "$(git rev-parse HEAD)"'           liberar
caso_falha_fechada "git commit -m \$(git log) libera"       $'git commit -m "$(git log -1)"'          liberar
caso_falha_fechada "primeira palavra é expansão sem gh/git libera" $'$(whoami) -l'                    liberar
caso_falha_fechada "aspas abertas em comando comum libera"  'echo "abc'                              liberar
caso_falha_fechada "aspas simples: não há expansão"         "echo '\$(git push)'"                    liberar
caso_falha_fechada "tudo interpretável: a regra não age"    'git push origin main'                   liberar
caso_falha_fechada "xargs com flags sem gh/git libera"      'xargs -n1 ls'                           liberar
caso_falha_fechada "git push com \$( no argumento"          $'git push "$(echo origin)" main'         bloquear
caso_falha_fechada "git -C x push com \$( no argumento"     $'git -C /x push "$(echo o)"'             bloquear
caso_falha_fechada "gh pr merge com aspas abertas"          'gh pr merge 1 --body "abc'              bloquear
caso_falha_fechada "git push com aspas abertas"             'git push origin "main'                  bloquear
caso_falha_fechada "gh api com \$( na query"                $'gh api graphql -f query="$(cat q.txt)"' bloquear
caso_falha_fechada "gh alias set com \$("                   $'gh alias set x "$(y)"'                  bloquear
caso_falha_fechada "sudo git push com \$("                  $'sudo git push "$(x)"'                   bloquear
caso_falha_fechada "primeira palavra é \$(echo git)"        $'$(echo git) push origin main'           bloquear
caso_falha_fechada "primeira palavra é crase com gh"        $'`echo gh` pr merge 1'                   bloquear
caso_falha_fechada "xargs com flags e git"                  'xargs -n1 git push'                     bloquear
caso_falha_fechada "env -S com gh"                          'env -S "gh pr merge 1"'                 bloquear

echo "▶ heredoc: o corpo não é comando"
caso_segmentos "heredoc simples"                   $'cat <<EOF\nlinha\nEOF\nls'                    '[cat <<EOF][ls]'
caso_segmentos "delimitador entre aspas simples"   $'cat <<\'EOF\'\ngit push origin main\nEOF'     "[cat <<'EOF']"
caso_segmentos "<<- aceita tab no fim"             $'cat <<-EOF\n\tx\n\tEOF\nls'                  '[cat <<-EOF][ls]'
caso_segmentos "comando depois do <<EOF na mesma linha" $'cat <<EOF && ls\nx\nEOF'               '[cat <<EOF][ls]'
caso_segmentos "heredoc dentro de aspas é uma palavra só" $'git commit -m "$(cat <<\'EOF\'\nmsg\nEOF\n)"' $'[git commit -m "$(cat <<\'EOF\'\nmsg\nEOF\n)"]'
caso_segmentos "<<< não é heredoc"                 $'cat <<< x\nls'                              '[cat <<< x][ls]'
caso_segmentos "heredoc sem terminador"            $'cat <<EOF\nx'                               '[cat <<EOF]'
caso_segmentos "dois heredocs na mesma linha"      $'cat <<A <<B\n1\nA\n2\nB\nls'                '[cat <<A <<B][ls]'
caso_segmentos "comandos depois do terminador"     $'cat <<EOF\nx\nEOF\nls && pwd'               '[cat <<EOF][ls][pwd]'
caso_segmentos "<< dentro de aspas não é heredoc"  "echo '<<EOF' && ls"                          "[echo '<<EOF'][ls]"
caso_segmentos "corpo com \$( e delimitador solto vira segmento" $'cat <<EOF\n$(git push origin main)\nEOF' $'[cat <<EOF][$(git push origin main)]'
caso_segmentos "corpo com \$( e delimitador entre aspas é literal" $'cat <<\'EOF\'\n$(git push origin main)\nEOF' "[cat <<'EOF']"

echo "▶ lexer: comentário com # (só no começo de palavra)"
caso_segmentos "comentário com apóstrofo não abre aspas"    $'echo x # it\'s\ngit push origin main'  '[echo x][git push origin main]'
caso_segmentos "# no meio da palavra não é comentário"      'echo a#b && ls'                            '[echo a#b][ls]'
caso_segmentos "linha só de comentário"                     '# só comentário'                           ''
caso_segmentos "# entre aspas não é comentário"             'echo "# não é comentário"'                 '[echo "# não é comentário"]'
caso_segmentos "comentário entre comandos"                  $'ls # c1\n# c2\nls'                         '[ls][ls]'
caso_segmentos "o ; dentro do comentário não separa"        'echo a # x; git push'                      '[echo a]'
caso_segmentos "\$# não é comentário"                       $'echo $#'                                   $'[echo $#]'
caso_segmentos "espaço protegido por barra não abre comentário" 'echo a\ #b'                            '[echo a\ #b]'
caso_tokens "comentário no fim do segmento"   'echo a # b c'      '[echo][a]'      '0,0'
caso_tokens "# no meio da palavra"            'echo a#b'          '[echo][a#b]'    '0,0'
caso_tokens "# entre aspas"                   'echo "#x"'         '[echo][#x]'     '0,1'

echo "▶ lexer: \$'...' (ANSI-C: a barra protege a letra seguinte)"
caso_segmentos "\$'\\'' não fecha a aspa antes da hora" $'echo $\'\\\'\'; git push origin main' $'[echo $\'\\\'\'][git push origin main]'
caso_segmentos "; dentro de \$'...'"            $'echo $\'a;b\' && ls'                 $'[echo $\'a;b\'][ls]'
caso_segmentos "\\\$ escapado e depois aspas simples" $'echo \\$\'a;b\''                 $'[echo \\$\'a;b\']'
caso_tokens "\$'push' vale push"                $'git $\'push\' origin'                '[git][push][origin]'   '0,1,0'
caso_tokens "\$'a\\tb' decodifica o tab"        $'echo $\'a\\tb\''                     $'[echo][a\tb]'         '0,1'
caso_tokens "\$'it\\'s' decodifica a aspa"      $'echo $\'it\\\'s\''                   "[echo][it's]"          '0,1'
caso_tokens "\$'\\x70ush' não é decodificado (ininterpretável)" $'git $\'\\x70ush\' origin' $'[git][\\x70ush][origin]' '0,1,0' 1
caso_tokens "\\\$ escapado não abre \$'...'"    $'echo \\$\'a b\''                     $'[echo][$a b]'         '0,1'

echo "▶ lexer: <(...) e >(...) são ininterpretáveis, como \$("
caso_tokens "process substitution de leitura"   'cat <(ls)'            '[cat][<(ls)]'   '0,0' 1
caso_tokens "process substitution de escrita"   'echo >(cat)'          '[echo][>(cat)]' '0,0' 1
caso_tokens "<( entre aspas é texto"            'echo "<(ls)"'         '[echo][<(ls)]'  '0,1'

echo "▶ lexer: heredoc com delimitador de aspas parciais e << que não é heredoc"
caso_segmentos "delimitador E\"O\"F"                 $'cat <<E"O"F\nx\nEOF\ngit push origin main'    '[cat <<E"O"F][git push origin main]'
caso_segmentos "delimitador E'O'F"                   $'cat <<E\'O\'F\nx\nEOF\nls'                      "[cat <<E'O'F][ls]"
caso_segmentos "delimitador entre aspas duplas"      $'cat <<"EOF"\n$(git push origin main)\nEOF\nls'  '[cat <<"EOF"][ls]'
caso_segmentos "delimitador com barra na frente"     $'cat <<\\EOF\n$(git push)\nEOF\nls'               '[cat <<\EOF][ls]'
caso_segmentos "delimitador com barra no meio"       $'cat <<EO\\F\nx\nEOF\nls'                         '[cat <<EO\F][ls]'
caso_segmentos "<< aritmético não é heredoc"         $'x=$((1<<3))\ngit push origin main'              $'[x=$((1<<3))][git push origin main]'
caso_segmentos "<< aritmético no meio do comando"    $'echo $((2<<1)) && ls'                            $'[echo $((2<<1))][ls]'
caso_segmentos "<< dentro de comentário não é heredoc" $'echo hi # usa <<EOF\ngit push origin main'    '[echo hi][git push origin main]'

if [[ $falhas -gt 0 ]]; then echo "✖ $falhas caso(s) falharam" >&2; exit 1; fi
echo "✔ todos os casos passaram"
