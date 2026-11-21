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
# A barra \ protege a letra seguinte (fora de aspas e dentro de aspas duplas, não dentro de aspas simples):
# "\;" não separa, "\"" não abre nem fecha aspas, e "\" + quebra de linha continua o comando.
dividir_comando() {   # $1 = o texto do comando
  # Letra por letra em bytes (LC_ALL=C): em UTF-8 o bash conta caracteres a cada ${cmd:i:1} e fica quadrático
  # (14 KB levava 5,5 s). Só os separadores importam e todos são ASCII; os bytes de acentos passam inteiros.
  local LC_ALL=C
  local cmd="$1" tam="${#1}" i c ant prox atual="" aspa=""
  SEGMENTOS=()
  for ((i = 0; i < tam; i++)); do
    c="${cmd:i:1}"
    prox="${cmd:i+1:1}"                  # a letra seguinte (vazia no fim do texto)
    ant=""; ((i > 0)) && ant="${cmd:i-1:1}"   # a letra anterior (vazia no começo)

    if [[ -n "$aspa" ]]; then            # dentro de aspas: nada separa, só acumula
      if [[ "$aspa" == '"' && "$c" == $'\\' ]]; then
        atual+="$c$prox"; i=$((i + 1))   # em aspas duplas, a barra protege a letra seguinte (\")
        continue
      fi
      atual+="$c"
      [[ "$c" == "$aspa" ]] && aspa=""   # achou a aspa que fecha
      continue
    fi

    case "$c" in
      $'\\') atual+="$c$prox"; i=$((i + 1)) ;;   # fora de aspas, a barra protege a letra seguinte
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

# Guarda a palavra que estava sendo montada (se começou alguma) e começa outra.
# Usa as variáveis "atual", "tem" e "citado" de quem chamou (ver _divisor_fechar).
_tokenizar_fechar() {
  if [[ $tem -eq 1 ]]; then
    TOK+=("$atual")
    TOK_CITADO+=("$citado")
  fi
  atual=""; tem=0; citado=0
}

# Quebra UM segmento em palavras, como o shell as entregaria ao programa (sem aspas nem barras de proteção).
# Deixa em TOK as palavras, em TOK_CITADO (1 se a palavra teve aspas ou barra), em ININTERPRETAVEL (1 se há
# aspa sem fechar) e em MOTIVO (o porquê, ou vazio). As palavras se separam em espaço, tab e quebra de linha.
tokenizar_segmento() {   # $1 = um segmento (o que dividir_comando entrega)
  local LC_ALL=C   # em bytes, pelo mesmo motivo de dividir_comando
  local seg="$1" tam="${#1}" i c prox atual="" tem=0 citado=0 aspa=""
  TOK=(); TOK_CITADO=(); TOK_MASCARA=(); ININTERPRETAVEL=0; MOTIVO=""
  for ((i = 0; i < tam; i++)); do
    c="${seg:i:1}"
    prox="${seg:i+1:1}"

    if [[ "$aspa" == "'" ]]; then        # aspas simples: tudo é literal até a aspa que fecha
      if [[ "$c" == "'" ]]; then aspa=""; else atual+="$c"; fi
    elif [[ "$aspa" == '"' ]]; then      # aspas duplas: só a barra tem efeito
      if [[ "$c" == '"' ]]; then
        aspa=""
      elif [[ "$c" == $'\\' ]]; then
        case "$prox" in
          '"' | $'\\' | '$' | '`') atual+="$prox"; i=$((i + 1)) ;;   # a barra protege só estas 4 letras
          *) atual+="$c" ;;                                          # em "\b" a barra fica
        esac
      else
        atual+="$c"
      fi
    else                                 # fora de aspas
      case "$c" in
        "'" | '"') aspa="$c"; tem=1; citado=1 ;;   # abriu aspas (a palavra existe, mesmo vazia: "")
        $'\\')
          if [[ "$prox" == $'\n' ]]; then
            i=$((i + 1))                           # barra + quebra de linha: continuação, some
          else
            atual+="$prox"; tem=1; citado=1; i=$((i + 1))   # a barra protege a letra seguinte
          fi ;;
        ' ' | $'\t' | $'\n') _tokenizar_fechar ;;
        *) atual+="$c"; tem=1 ;;
      esac
    fi
  done
  _tokenizar_fechar                      # guarda a última palavra
  if [[ -n "$aspa" ]]; then
    ININTERPRETAVEL=1
    MOTIVO="aspas sem fechar (${aspa})"
  fi
}

# Tira de TOK os redirecionamentos (>, >>, >|, &>, >&, <, <<, <<<, 2>&1...) e os alvos deles.
# Deixa em REDIR_ESCRITA os arquivos em que se escreve e em REDIR_LEITURA os que se leem. Só conta o operador
# escrito solto: um ">" dentro de aspas ou protegido por barra (máscara 1 em TOK_MASCARA) é texto.
# T4: esqueleto vazio; o corpo vem na fase verde.
separar_redirecionamentos() {   # usa TOK, TOK_CITADO e TOK_MASCARA (o que tokenizar_segmento deixou)
  REDIR_ESCRITA=(); REDIR_LEITURA=()
}
