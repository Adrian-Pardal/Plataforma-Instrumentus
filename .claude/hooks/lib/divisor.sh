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

# Parte um texto em letras (bytes) e guarda no array cujo nome vem em $2: array[i] é a letra i.
# Existe porque ${texto:i:1} custa O(tamanho) a cada chamada, e um laço que o usa em cada letra fica
# quadrático (20 KB levavam ~2 s por etapa). Aqui o texto é lido uma única vez (linear); depois,
# array[i] é instantâneo. Depois da última letra vêm 3 posições vazias: quem olha à frente (i+1, i+2)
# recebe vazio no fim do texto, como ${texto:i:1} dava, e não "unbound variable" sob "set -u".
_divisor_letras() {   # $1 = o texto, $2 = o nome do array que recebe as letras
  local LC_ALL=C
  local -n _letras="$2"
  local texto="$1" n=${#1} k c
  _letras=()
  for ((k = 0; k < n; k++)); do IFS= read -r -N1 c; _letras[k]="$c"; done <<<"$texto"
  _letras[n]=""; _letras[n + 1]=""; _letras[n + 2]=""
}

# Lê o delimitador de um heredoc ("<<EOF","<<-EOF", "<<'EOF'", "<<\EOF") a partir de cmd[i] e o guarda em
# hd_delim, com hd_quoted (1 se o delimitador veio entre aspas ou com barra: o corpo é literal) e hd_tab (1 se
# "<<-": o terminador pode vir com tabs na frente). Usa L (as letras de cmd), i, tam e os hd_* de quem chamou.
_divisor_registrar_heredoc() {
  local j=$((i + 2)) tab=0 quoted=0 delim="" ch q
  if [[ "${L[j]}" == '-' ]]; then tab=1; j=$((j + 1)); fi
  while [[ "${L[j]}" == ' ' || "${L[j]}" == $'\t' ]]; do j=$((j + 1)); done
  while ((j < tam)); do               # o delimitador é uma palavra: aspas e barras podem aparecer no meio (E"O"F)
    ch="${L[j]}"
    case "$ch" in
      "'" | '"')                        # entre aspas: o shell tira as aspas e fica só o que está dentro
        quoted=1; q="$ch"; j=$((j + 1))
        while ((j < tam)) && [[ "${L[j]}" != "$q" ]]; do delim+="${L[j]}"; j=$((j + 1)); done
        j=$((j + 1)); continue ;;
      $'\\') quoted=1; j=$((j + 1)); delim+="${L[j]}"; j=$((j + 1)); continue ;;   # "<<\EOF", "<<EO\F"
      ' ' | $'\t' | $'\n' | ';' | '&' | '|' | '<' | '>' | '(' | ')') break ;;
    esac
    delim+="$ch"; j=$((j + 1))
  done
  hd_delim+=("$delim"); hd_quoted+=("$quoted"); hd_tab+=("$tab")
}

# Pula o corpo dos heredocs da linha que acabou: do início da próxima linha até a linha do terminador, e deixa
# i no fim dessa linha. O corpo é texto, não comando, e por isso não vira segmento. Exceção: com o delimitador
# SEM aspas o shell expande $( e crase no corpo; cada linha assim vira um segmento, para os hooks a verem.
# Sem terminador, o corpo vai até o fim do texto. Usa cmd, i, tam, atual e os hd_* de quem chamou.
_divisor_ler_corpos() {
  local h pos resto linha fim cmp achou
  for ((h = 0; h < ${#hd_delim[@]}; h++)); do
    pos=$((i + 1)); achou=0
    while ((pos <= tam)); do
      resto="${cmd:pos}"; linha="${resto%%$'\n'*}"; fim=$((pos + ${#linha}))
      cmp="$linha"
      if ((hd_tab[h])); then cmp="${linha#"${linha%%[!$'\t']*}"}"; fi   # "<<-": tira os tabs do começo
      if [[ "$cmp" == "${hd_delim[h]}" ]]; then achou=1; i=$fim; break; fi
      if ((hd_quoted[h] == 0)) && [[ "$linha" == *$'$('* || "$linha" == *'`'* ]]; then
        atual="$linha"; _divisor_fechar
      fi
      pos=$((fim + 1))
    done
    if ((achou == 0)); then i=$tam; break; fi
  done
  hd_delim=(); hd_quoted=(); hd_tab=()
}

# Os helpers _divisor_* abaixo são as regras de dividir_comando, uma por função. Eles não têm variáveis próprias
# de estado: leem e mudam as locais de dividir_comando (L, i, c, ant, prox, atual, aspa, dolar*, escapou*, arit,
# hd_*), porque em bash uma função enxerga as variáveis locais de quem a chamou (ver _divisor_fechar).

# Prepara a letra i: c (ela), prox (a seguinte, vazia no fim do texto), ant (a anterior, vazia no começo) e o
# contexto vindo da letra anterior.
_divisor_contexto() {
  c="${L[i]}"
  prox="${L[i+1]}"
  ant=""; ((i > 0)) && ant="${L[i-1]}"
  dolar_prev=$dolar; dolar=0           # a letra anterior foi um "$" solto? (para reconhecer $'...')
  escapou_prev=$escapou; escapou=0     # a letra anterior foi protegida por barra?
}

# Dentro de aspas nada separa: só acumula a letra e acompanha onde as aspas fecham.
_divisor_em_aspas() {
  if [[ "$aspa" != "'" && "$c" == $'\\' ]]; then
    atual+="$c$prox"; i=$((i + 1))     # em aspas duplas e em $'...', a barra protege a letra seguinte
    return 0
  fi
  atual+="$c"
  if [[ "$aspa" == "A" ]]; then        # "A" = $'...' (ANSI-C): fecha na aspa simples
    [[ "$c" == "'" ]] && aspa=""
  else
    [[ "$c" == "$aspa" ]] && aspa=""   # achou a aspa que fecha
  fi
  return 0
}

# Fora de aspas: a barra protege a letra seguinte e as aspas abrem um trecho protegido.
_divisor_protecao() {
  case "$c" in
    $'\\') atual+="$c$prox"; i=$((i + 1)); escapou=1 ;;
    '"') aspa='"'; atual+="$c" ;;
    "'") if ((dolar_prev)); then aspa="A"; else aspa="'"; fi; atual+="$c" ;;   # $'...' (ANSI-C) ou aspas simples
  esac
}

# Devolve 0 se a letra anterior deixa um # abrir comentário (começo do texto, espaço, tab, quebra, ; & | ou "(").
_divisor_inicio_de_palavra() {
  case "$ant" in
    '' | ' ' | $'\t' | $'\n' | ';' | '&' | '|' | '(') return 0 ;;
  esac
  return 1
}

# Um # no começo de palavra abre comentário até o fim da linha; em "a#b" ou "$#" é só uma letra.
_divisor_comentario() {
  if ((escapou_prev == 0)) && _divisor_inicio_de_palavra; then
    while ((i + 1 < tam)) && [[ "${L[i+1]}" != $'\n' ]]; do i=$((i + 1)); done   # some até a quebra de linha
  else
    atual+="$c"
  fi
}

# "$((": aritmética, o "<<" de dentro não é heredoc. Qualquer outro "$" só avisa a letra seguinte (dolar).
_divisor_dolar() {
  atual+="$c"; dolar=1
  if [[ "$prox" == '(' && "${L[i+2]}" == '(' ]]; then
    atual+="(("; i=$((i + 2)); arit=2; dolar=0
  fi
}

# "(" e ")" só importam para fechar a aritmética aberta por "$((".
_divisor_parenteses() {
  atual+="$c"
  ((arit > 0)) || return 0
  if [[ "$c" == '(' ]]; then arit=$((arit + 1)); else arit=$((arit - 1)); fi
}

# "<<" que não é "<<<" (here-string) e fora de aritmética é heredoc: guarda o delimitador; o corpo é lido no
# fim da linha.
_divisor_menor() {
  atual+="$c"
  if ((arit == 0)) && [[ "$prox" == '<' && "${L[i+2]}" != '<' && "$ant" != '<' ]]; then
    _divisor_registrar_heredoc
  fi
}

# As letras que mexem na aritmética ou abrem heredoc.
_divisor_expansoes() {
  case "$c" in
    '$') _divisor_dolar ;;
    '(' | ')') _divisor_parenteses ;;
    '<') _divisor_menor ;;
  esac
}

# "|": pipe simples, "||" e "|&" (2 letras) ou o ">|" de um redirecionamento.
_divisor_pipe() {
  if [[ "$ant" == '>' ]]; then
    atual+="$c"                        # ">|" é redirecionamento, não pipe
  elif [[ "$prox" == '|' || "$prox" == '&' ]]; then
    _divisor_fechar; i=$((i + 1))      # "||" e "|&" têm 2 letras: pula a segunda
  else
    _divisor_fechar                    # pipe simples
  fi
}

# "&": "&&" (2 letras), redirecionamento ("2>&1", ">&", "&>") ou comando em segundo plano.
_divisor_e_comercial() {
  if [[ "$prox" == '&' ]]; then
    _divisor_fechar; i=$((i + 1))      # "&&" tem 2 letras: pula a segunda
  elif [[ "$ant" == '>' || "$prox" == '>' ]]; then
    atual+="$c"                        # "2>&1", ">&" e "&>" são redirecionamentos
  else
    _divisor_fechar                    # "&" sozinho: comando em segundo plano
  fi
}

# As letras que separam comandos: ; quebra de linha | &.
_divisor_separador() {
  case "$c" in
    ';') _divisor_fechar ;;
    $'\n')
      _divisor_fechar
      if ((${#hd_delim[@]} > 0)); then _divisor_ler_corpos; fi   # o corpo do heredoc começa na linha seguinte
      ;;
    '|') _divisor_pipe ;;
    '&') _divisor_e_comercial ;;
  esac
}

# Divide um comando do shell em segmentos (um por comando) e deixa o resultado em SEGMENTOS.
# Lê o texto uma letra por vez. Separadores: & && || ; | |& e quebra de linha, fora de aspas.
# A barra \ protege a letra seguinte (fora de aspas, em aspas duplas e em $'...', não em aspas simples):
# "\;" não separa, "\"" não abre nem fecha aspas, e "\" + quebra de linha continua o comando.
# Um # no começo de palavra abre comentário até o fim da linha ("echo x # it's" não deixa aspa aberta).
dividir_comando() {   # $1 = o texto do comando
  # Letra por letra em bytes (LC_ALL=C): só os separadores importam e todos são ASCII; os bytes de acentos
  # passam inteiros. As letras vêm de _divisor_letras (array L), porque ${cmd:i:1} é quadrático (ver lá).
  local LC_ALL=C
  local cmd="$1" tam="${#1}" i c ant prox atual="" aspa=""
  local dolar=0 dolar_prev=0 escapou=0 escapou_prev=0 arit=0   # contexto da letra anterior e $((...)) aberto
  local -a hd_delim=() hd_quoted=() hd_tab=()   # heredocs da linha, à espera do corpo (ver _divisor_ler_corpos)
  local -a L
  _divisor_letras "$cmd" L
  SEGMENTOS=()
  for ((i = 0; i < tam; i++)); do
    _divisor_contexto
    if [[ -n "$aspa" ]]; then _divisor_em_aspas; continue; fi   # dentro de aspas: nada separa, só acumula
    case "$c" in
      $'\\' | '"' | "'") _divisor_protecao ;;
      '#') _divisor_comentario ;;
      '$' | '(' | ')' | '<') _divisor_expansoes ;;
      ';' | $'\n' | '|' | '&') _divisor_separador ;;
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
    TOK_MASCARA+=("$mascara")
  fi
  atual=""; mascara=""; tem=0; citado=0
}

# Quebra UM segmento em palavras, como o shell as entregaria ao programa (sem aspas nem barras de proteção).
# Deixa em TOK as palavras, em TOK_CITADO (1 se a palavra teve aspas ou barra), em TOK_MASCARA (uma letra por
# letra da palavra: 1 se veio de aspas ou barra, 0 se foi escrita solta), em ININTERPRETAVEL (1 se há aspa sem
# fechar) e em MOTIVO (o porquê, ou vazio). As palavras se separam em espaço, tab e quebra de linha.
tokenizar_segmento() {   # $1 = um segmento (o que dividir_comando entrega)
  local LC_ALL=C   # em bytes, pelo mesmo motivo de dividir_comando
  local seg="$1" tam="${#1}" i c prox atual="" mascara="" tem=0 citado=0 aspa="" expande=0 obscuro=0
  local dolar=0 dolar_prev=0 escapou=0 escapou_prev=0   # contexto da letra anterior (ver dividir_comando)
  local -a L
  _divisor_letras "$seg" L
  TOK=(); TOK_CITADO=(); TOK_MASCARA=(); ININTERPRETAVEL=0; MOTIVO=""
  for ((i = 0; i < tam; i++)); do
    c="${L[i]}"
    prox="${L[i+1]}"
    dolar_prev=$dolar; dolar=0; escapou_prev=$escapou; escapou=0

    if [[ "$aspa" == "'" ]]; then        # aspas simples: tudo é literal até a aspa que fecha
      if [[ "$c" == "'" ]]; then aspa=""; else atual+="$c"; mascara+="1"; fi
    elif [[ "$aspa" == "A" ]]; then      # $'...' (ANSI-C): a barra escreve uma letra especial
      if [[ "$c" == "'" ]]; then
        aspa=""
      elif [[ "$c" == $'\\' ]]; then
        case "$prox" in
          $'\\' | "'" | '"') atual+="$prox"; mascara+="1"; i=$((i + 1)) ;;
          n) atual+=$'\n'; mascara+="1"; i=$((i + 1)) ;;
          t) atual+=$'\t'; mascara+="1"; i=$((i + 1)) ;;
          r) atual+=$'\r'; mascara+="1"; i=$((i + 1)) ;;
          *) atual+="$c"; mascara+="1"; obscuro=1 ;;   # \x70, \101, \u...: não decodificamos; o hook não pode confiar
        esac
      else
        atual+="$c"; mascara+="1"
      fi
    elif [[ "$aspa" == '"' ]]; then      # aspas duplas: só a barra tem efeito
      if [[ "$c" == '"' ]]; then
        aspa=""
      elif [[ "$c" == $'\\' ]]; then
        case "$prox" in
          '"' | $'\\' | '$' | '`') atual+="$prox"; mascara+="1"; i=$((i + 1)) ;;   # a barra protege só estas 4 letras
          *) atual+="$c"; mascara+="1" ;;                                          # em "\b" a barra fica
        esac
      else
        atual+="$c"; mascara+="1"
        if [[ "$c" == '`' || ( "$c" == '$' && "$prox" == '(' ) ]]; then expande=1; fi   # o shell executa isto
      fi
    else                                 # fora de aspas
      case "$c" in
        '"') aspa="$c"; tem=1; citado=1 ;;         # abriu aspas duplas (a palavra existe, mesmo vazia: "")
        "'")
          if ((dolar_prev)); then                  # $'...': o "$" que acabou de entrar não é da palavra
            atual="${atual%$}"; mascara="${mascara%?}"; aspa="A"
          else
            aspa="'"
          fi
          tem=1; citado=1 ;;
        $'\\')
          escapou=1
          if [[ "$prox" == $'\n' ]]; then
            i=$((i + 1))                           # barra + quebra de linha: continuação, some
          else
            tem=1; citado=1
            if [[ -n "$prox" ]]; then atual+="$prox"; mascara+="1"; fi   # a barra protege a letra seguinte
            i=$((i + 1))
          fi ;;
        ' ' | $'\t' | $'\n') _tokenizar_fechar ;;
        '#')
          if ((tem == 0 && escapou_prev == 0)); then
            while ((i + 1 < tam)) && [[ "${L[i+1]}" != $'\n' ]]; do i=$((i + 1)); done   # comentário: ignora até a quebra
          else
            atual+="$c"; mascara+="0"; tem=1         # "a#b": faz parte da palavra
          fi ;;
        '`') atual+="$c"; mascara+="0"; tem=1; expande=1 ;;           # crase: o shell executa o que está dentro
        '$') atual+="$c"; mascara+="0"; tem=1; dolar=1; [[ "$prox" == '(' ]] && expande=1 ;;   # "$(": idem
        '<' | '>') atual+="$c"; mascara+="0"; tem=1; [[ "$prox" == '(' ]] && expande=1 ;;      # "<(" e ">(": idem
        *) atual+="$c"; mascara+="0"; tem=1 ;;
      esac
    fi
  done
  _tokenizar_fechar                      # guarda a última palavra
  if [[ -n "$aspa" ]]; then
    ININTERPRETAVEL=1
    if [[ "$aspa" == "A" ]]; then MOTIVO="aspas sem fechar (\$')"; else MOTIVO="aspas sem fechar (${aspa})"; fi
  elif ((expande)); then                 # em aspas simples ou com barra não conta: o shell não executa
    ININTERPRETAVEL=1
    MOTIVO="expansão \$(, crase ou <( >(: o que roda só se sabe depois do shell"
  elif ((obscuro)); then
    ININTERPRETAVEL=1
    MOTIVO="escape de \$'...' que o divisor não decodifica (\\x, \\u, octal...)"
  fi
}

# Trata um trecho de palavra achado por separar_redirecionamentos: se um operador está esperando o alvo, o
# trecho é o alvo; senão, é uma palavra. Usa a variável "alvo" de quem chamou (ver _divisor_fechar).
_redir_emitir() {   # $1 = o trecho, $2 = a máscara dele, $3 = 1 para emitir mesmo vazio (palavra "")
  local p="$1" mk="$2" forcar="${3:-0}" cit=0
  [[ -z "$p" && "$forcar" -ne 1 ]] && return 0
  [[ "$mk" == *1* ]] && cit=1
  case "$alvo" in
    esc) REDIR_ESCRITA+=("$p"); alvo="" ;;
    lei) REDIR_LEITURA+=("$p"); alvo="" ;;
    ign) alvo="" ;;
    dup_esc | dup_lei)
      if ! [[ "$p" =~ ^[0-9]+$ || "$p" == - ]]; then   # ">&2" e ">&-" duplicam um descritor; ">& out" é arquivo
        if [[ "$alvo" == dup_esc ]]; then REDIR_ESCRITA+=("$p"); else REDIR_LEITURA+=("$p"); fi
      fi
      alvo="" ;;
    *) TOK+=("$p"); TOK_CITADO+=("$cit"); TOK_MASCARA+=("$mk") ;;
  esac
}

# Tira de TOK os redirecionamentos (>, >>, >|, &>, >&, <, <<, <<<, 2>&1...) e os alvos deles.
# Deixa em REDIR_ESCRITA os arquivos em que se escreve e em REDIR_LEITURA os que se leem. Só conta o operador
# escrito solto: um ">" dentro de aspas ou protegido por barra (máscara 1 em TOK_MASCARA) é texto.
# Se faltar o alvo do operador (por exemplo "echo x >"), marca ININTERPRETAVEL: é erro de sintaxe no shell.
# Regras: o operador é > >> >| >& &> &>> < <& <> << <<- <<<; "2>" e "1>" têm um descritor na frente, que não
# é palavra; ">&" e "<&" seguidos de número ou "-" duplicam um descritor e não têm arquivo; "<<" e "<<<" têm
# delimitador ou texto, não arquivo, e por isso não entram em REDIR_LEITURA.
separar_redirecionamentos() {   # usa TOK, TOK_CITADO e TOK_MASCARA (o que tokenizar_segmento deixou)
  local LC_ALL=C
  local -a tok=("${TOK[@]}") msk=("${TOK_MASCARA[@]}")
  local k i j n t m c nx op palavra pmasc alvo=""
  local -a LT LM   # as letras da palavra e as da máscara (ver _divisor_letras)
  TOK=(); TOK_CITADO=(); TOK_MASCARA=(); REDIR_ESCRITA=(); REDIR_LEITURA=()
  for ((k = 0; k < ${#tok[@]}; k++)); do
    t="${tok[k]}"; m="${msk[k]}"; n=${#t}; palavra=""; pmasc=""
    if ((n == 0)); then _redir_emitir "" "" 1; continue; fi   # palavra vazia entre aspas: ""
    if [[ "$t" != *[\<\>]* || "$m" != *0* ]]; then
      palavra="$t"; pmasc="$m"; n=0                           # sem < nem > soltos: a palavra passa inteira, não há o que separar
    else
      _divisor_letras "$t" LT; _divisor_letras "$m" LM
    fi
    for ((i = 0; i < n; i++)); do
      c="${LT[i]}"
      if [[ "${LM[i]}" != 0 || ( "$c" != '<' && "$c" != '>' ) ]]; then
        palavra+="$c"; pmasc+="${LM[i]}"                      # letra comum (ou < > protegido por aspas ou barra)
        continue
      fi
      # Achou um operador solto. O que veio antes dele, colado:
      if [[ "$c" == '>' && "$palavra" == *'&' && "${pmasc: -1}" == 0 ]]; then
        palavra="${palavra%&}"; pmasc="${pmasc%?}"            # "--squash&>x": o & é do operador (&>)
      elif [[ "$palavra" =~ ^[0-9]+$ && "$pmasc" != *1* ]]; then
        palavra=""; pmasc=""                                  # "2>", "1>": descritor solto, não é palavra
      fi
      [[ -n "$palavra" ]] && _redir_emitir "$palavra" "$pmasc"
      palavra=""; pmasc=""
      if [[ -n "$alvo" ]]; then                               # um operador sem alvo antes deste
        ININTERPRETAVEL=1; MOTIVO="redirecionamento sem alvo"; alvo=""
      fi
      # Lê o operador inteiro.
      op="$c"; j=$((i + 1)); nx="${LT[j]}"
      if [[ "$c" == '>' ]]; then
        if [[ "${LM[j]}" == 0 && ( "$nx" == '>' || "$nx" == '|' || "$nx" == '&' ) ]]; then op+="$nx"; j=$((j + 1)); fi
      elif [[ "${LM[j]}" == 0 ]]; then
        case "$nx" in
          '<')
            op+="<"; j=$((j + 1))
            if [[ "${LM[j]}" == 0 && "${LT[j]}" == '<' ]]; then op+="<"; j=$((j + 1))
            elif [[ "${LM[j]}" == 0 && "${LT[j]}" == '-' ]]; then op+="-"; j=$((j + 1)); fi ;;
          '&') op+="&"; j=$((j + 1)) ;;
          '>') op+=">"; j=$((j + 1)) ;;
        esac
      fi
      case "$op" in
        '>' | '>>' | '>|' | '<>') alvo=esc ;;
        '>&') alvo=dup_esc ;;
        '<') alvo=lei ;;
        '<&') alvo=dup_lei ;;
        *) alvo=ign ;;                                        # << <<- <<<
      esac
      i=$((j - 1))
    done
    [[ -n "$palavra" ]] && _redir_emitir "$palavra" "$pmasc"
  done
  if [[ -n "$alvo" ]]; then ININTERPRETAVEL=1; MOTIVO="redirecionamento sem alvo"; fi
}

# Acha, em TOK, o programa (gh ou git), as variáveis "VAR=valor" que vêm antes dele, as flags globais e o
# subcomando. Deixa em PROG (gh, git ou vazio), ENV_PREFIXO, FLAGS_GLOBAIS (cada flag e o valor dela, na ordem),
# DIR_GIT (o valor de "-C"), SUB, SUB2 (o 2º nível de "gh pr" e "gh alias": merge, view, set...) e ARGS (o resto).
# Flag desconhecida é tratada como booleana; a regra de forma da opção B (ERR-003) continua como rede extra nos hooks.
achar_subcomando() {   # usa TOK (depois de tokenizar_segmento e separar_redirecionamentos)
  local i=0 j base
  PROG=""; SUB=""; SUB2=""; ARGS=(); FLAGS_GLOBAIS=(); ENV_PREFIXO=(); DIR_GIT=""
  while ((i < ${#TOK[@]})) && [[ "${TOK[i]}" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]]; do
    ENV_PREFIXO+=("${TOK[i]}"); i=$((i + 1))             # "VAR=valor gh ...": o shell põe VAR no ambiente do gh
  done
  ((i < ${#TOK[@]})) || return 0
  base="${TOK[i]##*/}"                                   # "/usr/bin/gh" vale como "gh"
  case "$base" in
    gh | git) PROG="$base" ;;
    *) return 0 ;;
  esac
  j=$((i + 1))
  _achar_pular_flags
  if ((j < ${#TOK[@]})); then SUB="${TOK[j]}"; j=$((j + 1)); fi
  if [[ "$PROG" == gh && ( "$SUB" == pr || "$SUB" == alias ) ]]; then   # 2º nível: "gh pr merge", "gh alias set"
    _achar_pular_flags
    if ((j < ${#TOK[@]})) && [[ "${TOK[j]}" != -* ]]; then SUB2="${TOK[j]}"; j=$((j + 1)); fi
  fi
  ARGS=("${TOK[@]:j}")
}

# Os helpers _desemb_* usam as variáveis locais de desembrulhar (tok, cit, msk, p, w), como _divisor_fechar.
# Convenção dos passos: devolvem 0 quando tiraram algo (o laço tenta de novo) e 1 quando é para parar.

# Grupo de comandos: "(" solto no começo da palavra (colado ou não) e "{" sozinho.
_desemb_grupo() {
  if [[ "${msk[0]:0:1}" == 0 && "${tok[0]}" == '('* ]]; then
    tok[0]="${tok[0]:1}"; msk[0]="${msk[0]:1}"
    if ((${#tok[0]} == 0)); then _desemb_remover 0 1; fi
    WRAPPERS+=("("); return 0
  fi
  if [[ "${tok[0]}" == '{' && "${msk[0]}" == 0 ]]; then
    _desemb_remover 0 1; WRAPPERS+=("{"); return 0
  fi
  return 1
}

# O wrapper vem depois de eventuais "VAR=valor": deixa em p a posição da primeira palavra que não é atribuição.
# Devolve 1 se não sobrou palavra.
_desemb_pular_variaveis() {
  p=0
  while ((p < ${#tok[@]})) && [[ "${tok[p]}" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]]; do p=$((p + 1)); done
  ((p < ${#tok[@]}))
}

# "b) git push": o padrão de um case termina em ")" solto e é tirado.
_desemb_padrao_de_case() {
  if [[ "${tok[p]}" == *')' && "${msk[p]: -1}" == 0 ]]; then
    _desemb_remover "$p" 1; WRAPPERS+=("case"); return 0
  fi
  return 1
}

# Palavras reservadas (só valem soltas: "then" entre aspas é um comando com esse nome) e "case x in padrão)".
_desemb_sintaxe() {
  if [[ "$w" == case ]]; then _desemb_case; return; fi
  [[ "${msk[p]}" == *1* ]] && return 1
  _desemb_remover "$p" 1
}

# Tira "case x in padrão)". Sem o ")" do padrão não há como saber o que vem: não suportado.
_desemb_case() {
  local q=$p
  while ((q < ${#tok[@]})) && ! [[ "${tok[q]}" == *')' && "${msk[q]: -1}" == 0 ]]; do q=$((q + 1)); done
  if ((q >= ${#tok[@]})); then WRAPPER_NAO_SUPORTADO="case"; return 1; fi
  _desemb_remover "$p" $((q - p + 1))
}

# env, command, xargs, find e os que rodam um texto ou outro comando que não abrimos.
_desemb_especial() {
  case "$w" in
    env) _desemb_env ;;
    command) _desemb_command ;;
    xargs) _desemb_xargs ;;
    find) _desemb_find ;;
    *) WRAPPER_NAO_SUPORTADO="$w"; return 1 ;;   # eval, watch, coproc, parallel
  esac
}

_desemb_env() {
  if _desemb_env_tem_s; then WRAPPER_NAO_SUPORTADO="env"; return 1; fi   # "env -S 'git push'": uma palavra só
  _desemb_remover "$p" 1; _desemb_opcoes "-u -C --unset --chdir"
  return 0
}

_desemb_command() {
  case "${tok[p + 1]:-}" in -v | -V) return 1 ;; esac        # "command -v gh" só consulta: não executa
  _desemb_remover "$p" 1; _desemb_opcoes ""
  return 0
}

_desemb_xargs() {
  if [[ "${tok[p + 1]:-}" == -* ]]; then WRAPPER_NAO_SUPORTADO="xargs"; return 1; fi   # com flags, não sabemos o que ele faz
  _desemb_remover "$p" 1
}

# "find" não é desembrulhado; só se anota se tem -exec e afins (que rodam outro comando).
_desemb_find() {
  local u
  for ((u = p + 1; u < ${#tok[@]}; u++)); do
    case "${tok[u]}" in -exec | -execdir | -ok | -okdir) WRAPPER_NAO_SUPORTADO="find" ;; esac
  done
  return 1
}

# Wrappers que levam opções: tira o wrapper e as opções dele (as que levam valor ficam na lista de cada um).
_desemb_com_opcoes() {
  local opcoes=""   # setsid não tem opção com valor
  case "$w" in
    time) opcoes="-f -o --format --output" ;;
    exec) opcoes="-a" ;;
    sudo) opcoes="-u -g -h -p -C -D -r -t -U -T --user --group --host --prompt --chdir" ;;
    timeout) opcoes="-s -k --signal --kill-after" ;;
    nice) opcoes="-n --adjustment" ;;
    stdbuf) opcoes="-i -o -e --input --output --error" ;;
    ionice) opcoes="-c -n --class --classdata" ;;
  esac
  _desemb_remover "$p" 1; _desemb_opcoes "$opcoes"
  _desemb_duracao
  return 0
}

# O "timeout" tem, depois das opções, a duração ("5", "1m"), que também sai.
_desemb_duracao() {
  [[ "$w" == timeout ]] || return 0
  if ((p < ${#tok[@]})); then _desemb_remover "$p" 1; fi
  return 0
}

# Tira UM wrapper do comando que começa em tok[p]. Devolve 1 se não é wrapper (ou não dá para abrir).
_desemb_wrapper() {
  w="${tok[p]##*/}"                    # "/usr/bin/sudo" vale como "sudo"
  case "$w" in
    if | then | else | elif | do | while | until | '!' | case) _desemb_sintaxe ;;
    env | command | xargs | find | eval | watch | coproc | parallel) _desemb_especial ;;
    builtin | nohup | noglob) _desemb_remover "$p" 1 ;;
    time | setsid | exec | sudo | timeout | nice | stdbuf | ionice) _desemb_com_opcoes ;;
    *) return 1 ;;
  esac || return 1
  WRAPPERS+=("$w")
}

# Entra nos "embrulhos" do comando e deixa em TOK o comando de dentro: env, command, builtin, nohup, time, sudo,
# xargs (sem flags) e grupo "( ... )" ou "{ ...". Deixa em WRAPPERS o que foi tirado, na ordem. "command -v" só
# consulta e não executa: não se desembrulha. "xargs" com flags não é desembrulhado e fica em WRAPPER_NAO_SUPORTADO.
desembrulhar() {   # usa TOK, TOK_CITADO e TOK_MASCARA (depois de separar_redirecionamentos)
  local -a tok=("${TOK[@]}") cit=("${TOK_CITADO[@]}") msk=("${TOK_MASCARA[@]}")
  local p w
  WRAPPERS=(); WRAPPER_NAO_SUPORTADO=""
  while ((${#tok[@]} > 0)); do
    _desemb_grupo && continue
    _desemb_pular_variaveis || break
    _desemb_padrao_de_case && continue
    _desemb_wrapper || break
  done
  _desemb_aparar_parenteses
  TOK=("${tok[@]}"); TOK_CITADO=("${cit[@]}"); TOK_MASCARA=("${msk[@]}")
}

# Tira as opções de um wrapper a partir de tok[p]. $1 = as opções que levam um valor no token seguinte (separadas
# por espaço); as demais são booleanas. "--" encerra as opções. Usa tok, cit, msk e p de quem chamou.
_desemb_opcoes() {
  local com_valor=" $1 "
  while ((p < ${#tok[@]})) && [[ "${tok[p]}" == -* && "${tok[p]}" != '-' ]]; do
    if [[ "${tok[p]}" == '--' ]]; then _desemb_remover "$p" 1; break; fi
    if [[ "$com_valor" == *" ${tok[p]} "* ]]; then _desemb_remover "$p" 2; else _desemb_remover "$p" 1; fi
  done
}

# "env -S 'texto'" (também "-iS", "-vS", "--split-string") entrega o comando todo numa palavra só.
# Devolve 0 se alguma opção do env em tok[p] é -S. Usa tok e p de quem chamou.
_desemb_env_tem_s() {
  local u=$((p + 1))
  while ((u < ${#tok[@]})) && [[ "${tok[u]}" == -* ]]; do
    case "${tok[u]}" in
      -u | -C | --unset | --chdir) u=$((u + 1)) ;;                # o valor não é opção
      --split-string* | -S* | -[!-]*S*) return 0 ;;
    esac
    u=$((u + 1))
  done
  return 1
}

# Se sobraram mais ")" soltos do que "(" soltos (o divisor cortou um "( cd /x; git push --force)" no ";"), tira os
# ")" a mais do fim da última palavra. ")" e "(" entre aspas ou protegidos por barra não contam.
_desemb_aparar_parenteses() {
  local LC_ALL=C   # em bytes, pelo mesmo motivo de dividir_comando
  local k c n abre=0 fecha=0 u
  local -a LT LM   # as letras da palavra e as da máscara (ver _divisor_letras)
  for ((k = 0; k < ${#tok[@]}; k++)); do
    n=${#tok[k]}
    [[ "${tok[k]}" == *[\(\)]* && "${msk[k]}" == *0* ]] || continue   # só conta parêntese solto: sem ele não há o que contar
    _divisor_letras "${tok[k]}" LT; _divisor_letras "${msk[k]}" LM
    for ((c = 0; c < n; c++)); do
      [[ "${LM[c]}" == 0 ]] || continue
      case "${LT[c]}" in '(') abre=$((abre + 1)) ;; ')') fecha=$((fecha + 1)) ;; esac
    done
  done
  while ((fecha > abre && ${#tok[@]} > 0)); do
    u=$((${#tok[@]} - 1))
    [[ "${tok[u]}" == *')' && "${msk[u]: -1}" == 0 ]] || break
    tok[u]="${tok[u]%)}"; msk[u]="${msk[u]%?}"
    if ((${#tok[u]} == 0)); then _desemb_remover "$u" 1; fi
    fecha=$((fecha - 1))
  done
}

# Tira $2 palavras a partir da posição $1 de tok, cit e msk (os arrays de quem chamou: ver _divisor_fechar).
_desemb_remover() {
  tok=("${tok[@]:0:$1}" "${tok[@]:$(($1 + $2))}")
  cit=("${cit[@]:0:$1}" "${cit[@]:$(($1 + $2))}")
  msk=("${msk[@]:0:$1}" "${msk[@]:$(($1 + $2))}")
}

# Analisa UM segmento de ponta a ponta: tokeniza, tira os redirecionamentos, desembrulha os wrappers e acha o
# programa e o subcomando. É só a composição das funções acima; o resultado fica nas variáveis delas
# (PROG, SUB, SUB2, ARGS, ININTERPRETAVEL...). Guarda o texto cru em SEGMENTO_CRU.
analisar_segmento() {   # $1 = um segmento (o que dividir_comando entrega)
  SEGMENTO_CRU="$1"
  tokenizar_segmento "$1"
  separar_redirecionamentos
  desembrulhar
  achar_subcomando
}

# A regra da falha fechada (ADR 0005): quando o segmento não se deixa interpretar, o hook decide se bloqueia.
# Devolve 0 = bloquear, 1 = liberar. O hook define PROTEGIDOS, a lista de ações que protege (por exemplo
# ("git push" "gh pr merge" "gh api" "gh alias")). Usa o que analisar_segmento deixou.
# Só age quando o segmento é ininterpretável (aspa aberta, $( ou crase) ou tem um wrapper que não sabemos abrir
# (xargs com flags, env -S). Então: se o programa e a ação se acham, bloqueia só se a ação é protegida
# ("git commit -m \"$(...)\"" passa; "git push \"$(...)\"" não). Se o programa não se acha (a primeira palavra é uma
# expansão, ou o wrapper não abre), bloqueia quando o texto cru cita gh ou git.
falha_fechada() {
  local simples='^[a-z][a-z0-9-]*$'
  # O subcomando tem de ser um nome simples: "git $(echo push)", "git {push,}" e "gh pr $(echo mer)ge" escondem a ação.
  if [[ -n "$PROG" ]]; then
    [[ -z "$SUB" || "$SUB" =~ $simples ]] || return 0
    [[ -z "$SUB2" || "$SUB2" =~ $simples ]] || return 0
  fi
  [[ "$ININTERPRETAVEL" == 1 || -n "$WRAPPER_NAO_SUPORTADO" ]] || return 1
  ((${#PROTEGIDOS[@]} > 0)) || return 0                   # sem lista de ações protegidas não há como decidir: bloqueia
  # Ininterpretável (aspa aberta, $( crase <( >() ou wrapper que não abrimos: bloqueia se o texto MOSTRA uma ação
  # protegida em qualquer posição (dentro de $(...), de aspas, depois de um wrapper...). O texto cru e as palavras
  # tokenizadas entram os dois: "g"it push só aparece como "git push" nas palavras.
  _falha_mostra_acao_protegida "$SEGMENTO_CRU ${TOK[*]}"
}

# Devolve 0 se o texto contém alguma ação de PROTEGIDOS com as palavras na ordem e inteiras, com qualquer coisa entre
# elas: "git push" casa em "git -C /x push" e em "$(echo git) push", mas não em "legit pushes". Falsos positivos: um
# texto que apenas cita "git ... push" (a opção A do plano aceita isso). Usa PROTEGIDOS de quem chamou.
_falha_mostra_acao_protegida() {   # $1 = o texto
  local a b="[^[:alnum:]_]" re w
  local -a palavras
  for a in "${PROTEGIDOS[@]}"; do
    read -ra palavras <<<"$a"
    re="(^|$b)${palavras[0]}"
    for w in "${palavras[@]:1}"; do re+="($b|$b.*$b)$w"; done
    re+="($b|\$)"
    [[ "$1" =~ $re ]] && return 0
  done
  return 1
}

# Flags que levam um valor no token seguinte ("-C dir", "-R dono/repo"). Com "=" ("--git-dir=/x") o valor já vem junto.
_flag_leva_valor() {   # $1 = programa, $2 = flag
  case "$1:$2" in
    git:-C | git:-c | git:--git-dir | git:--work-tree | git:--namespace | git:--config-env | git:--attr-source) return 0 ;;
    gh:-R | gh:--repo) return 0 ;;
  esac
  return 1
}

# Pula as flags a partir de TOK[j]: guarda cada uma (e o valor dela) em FLAGS_GLOBAIS e avança j.
# Usa j, TOK e PROG de quem chamou; "-C" também deixa o valor em DIR_GIT.
_achar_pular_flags() {
  local f
  while ((j < ${#TOK[@]})) && [[ "${TOK[j]}" == -* ]]; do
    f="${TOK[j]}"; FLAGS_GLOBAIS+=("$f"); j=$((j + 1))
    if [[ "$f" != *=* ]] && _flag_leva_valor "$PROG" "$f" && ((j < ${#TOK[@]})); then
      FLAGS_GLOBAIS+=("${TOK[j]}")
      [[ "$f" == -C ]] && DIR_GIT="${TOK[j]}"
      j=$((j + 1))
    fi
  done
}
