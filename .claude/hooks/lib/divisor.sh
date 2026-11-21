# shellcheck shell=bash
# shellcheck disable=SC2034  # SEGMENTOS é lida pelos hooks que carregam este arquivo
# divisor.sh — divisor de comandos compartilhado pelos hooks (ADR 0005, plano 001).
# Carregado por "source"; não tem shebang e não roda sozinho.

# Guarda o segmento que estava sendo montado (sem espaços nas pontas, e só se não for vazio) e começa outro.
# Usa a variável "atual" de quem chamou: em bash, uma função enxerga as variáveis locais de quem a chamou.
_divisor_fechar() {
  local s="$atual"
  s="${s#"${s%%[![:space:]]*}"}"   # tira os espaços do começo
  s="${s%"${s##*[![:space:]]}"}"   # tira os espaços do fim
  [[ -n "$s" ]] && SEGMENTOS+=("$s")
  atual=""
}

# Divide um comando do shell em segmentos (um por comando) e deixa o resultado em SEGMENTOS.
# Lê o texto uma letra por vez. Separadores: & && || ; | |& e quebra de linha, fora de aspas.
# Versão simples: aspas simples e duplas, sem tratar escape (\). O resto vem nas próximas tasks.
dividir_comando() {   # $1 = o texto do comando
  local cmd="$1" i c ant prox atual="" aspa=""
  SEGMENTOS=()
  for ((i = 0; i < ${#cmd}; i++)); do
    c="${cmd:i:1}"
    prox="${cmd:i+1:1}"                  # a letra seguinte (vazia no fim do texto)
    ant=""; ((i > 0)) && ant="${cmd:i-1:1}"   # a letra anterior (vazia no começo)

    if [[ -n "$aspa" ]]; then            # dentro de aspas: nada separa, só acumula
      atual+="$c"
      [[ "$c" == "$aspa" ]] && aspa=""   # achou a aspa que fecha
      continue
    fi

    case "$c" in
      '"' | "'") aspa="$c"; atual+="$c" ;;   # abriu aspas
      ';' | $'\n') _divisor_fechar ;;
      '|')
        if [[ "$ant" == '>' ]]; then
          atual+="$c"                                      # ">|" é redirecionamento, não pipe
        elif [[ "$prox" == '|' || "$prox" == '&' ]]; then
          _divisor_fechar; i=$((i + 1))                    # "||" e "|&" têm 2 letras: pula a segunda
        else
          _divisor_fechar                                  # pipe simples
        fi ;;
      '&')
        if [[ "$prox" == '&' ]]; then
          _divisor_fechar; i=$((i + 1))                    # "&&" tem 2 letras: pula a segunda
        elif [[ "$ant" == '>' || "$prox" == '>' ]]; then
          atual+="$c"                                      # "2>&1", ">&" e "&>" são redirecionamentos
        else
          _divisor_fechar                                  # "&" sozinho: comando em segundo plano
        fi ;;
      *) atual+="$c" ;;
    esac
  done
  _divisor_fechar                        # guarda o último segmento
}
