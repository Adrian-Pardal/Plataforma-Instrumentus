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
  local seg="$1" tam="${#1}" i c prox atual="" mascara="" tem=0 citado=0 aspa=""
  TOK=(); TOK_CITADO=(); TOK_MASCARA=(); ININTERPRETAVEL=0; MOTIVO=""
  for ((i = 0; i < tam; i++)); do
    c="${seg:i:1}"
    prox="${seg:i+1:1}"

    if [[ "$aspa" == "'" ]]; then        # aspas simples: tudo é literal até a aspa que fecha
      if [[ "$c" == "'" ]]; then aspa=""; else atual+="$c"; mascara+="1"; fi
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
      fi
    else                                 # fora de aspas
      case "$c" in
        "'" | '"') aspa="$c"; tem=1; citado=1 ;;   # abriu aspas (a palavra existe, mesmo vazia: "")
        $'\\')
          if [[ "$prox" == $'\n' ]]; then
            i=$((i + 1))                           # barra + quebra de linha: continuação, some
          else
            tem=1; citado=1
            if [[ -n "$prox" ]]; then atual+="$prox"; mascara+="1"; fi   # a barra protege a letra seguinte
            i=$((i + 1))
          fi ;;
        ' ' | $'\t' | $'\n') _tokenizar_fechar ;;
        *) atual+="$c"; mascara+="0"; tem=1 ;;
      esac
    fi
  done
  _tokenizar_fechar                      # guarda a última palavra
  if [[ -n "$aspa" ]]; then
    ININTERPRETAVEL=1
    MOTIVO="aspas sem fechar (${aspa})"
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
  TOK=(); TOK_CITADO=(); TOK_MASCARA=(); REDIR_ESCRITA=(); REDIR_LEITURA=()
  for ((k = 0; k < ${#tok[@]}; k++)); do
    t="${tok[k]}"; m="${msk[k]}"; n=${#t}; palavra=""; pmasc=""
    if ((n == 0)); then _redir_emitir "" "" 1; continue; fi   # palavra vazia entre aspas: ""
    for ((i = 0; i < n; i++)); do
      c="${t:i:1}"
      if [[ "${m:i:1}" != 0 || ( "$c" != '<' && "$c" != '>' ) ]]; then
        palavra+="$c"; pmasc+="${m:i:1}"                      # letra comum (ou < > protegido por aspas ou barra)
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
      op="$c"; j=$((i + 1)); nx="${t:j:1}"
      if [[ "$c" == '>' ]]; then
        if [[ "${m:j:1}" == 0 && ( "$nx" == '>' || "$nx" == '|' || "$nx" == '&' ) ]]; then op+="$nx"; j=$((j + 1)); fi
      elif [[ "${m:j:1}" == 0 ]]; then
        case "$nx" in
          '<')
            op+="<"; j=$((j + 1))
            if [[ "${m:j:1}" == 0 && "${t:j:1}" == '<' ]]; then op+="<"; j=$((j + 1))
            elif [[ "${m:j:1}" == 0 && "${t:j:1}" == '-' ]]; then op+="-"; j=$((j + 1)); fi ;;
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

# Entra nos "embrulhos" do comando e deixa em TOK o comando de dentro: env, command, builtin, nohup, time, sudo,
# xargs (sem flags) e grupo "( ... )" ou "{ ...". Deixa em WRAPPERS o que foi tirado, na ordem. "command -v" só
# consulta e não executa: não se desembrulha. "xargs" com flags não é desembrulhado e fica em WRAPPER_NAO_SUPORTADO.
desembrulhar() {   # usa TOK, TOK_CITADO e TOK_MASCARA (depois de separar_redirecionamentos)
  local -a tok=("${TOK[@]}") cit=("${TOK_CITADO[@]}") msk=("${TOK_MASCARA[@]}")
  local p w u mudou=1 abriu=0
  WRAPPERS=(); WRAPPER_NAO_SUPORTADO=""
  while ((mudou && ${#tok[@]} > 0)); do
    mudou=0
    # Grupo de comandos: "(" solto no começo da palavra (colado ou não) e "{" sozinho.
    if [[ "${msk[0]:0:1}" == 0 && "${tok[0]}" == '('* ]]; then
      tok[0]="${tok[0]:1}"; msk[0]="${msk[0]:1}"
      if ((${#tok[0]} == 0)); then _desemb_remover 0 1; fi
      WRAPPERS+=("("); abriu=1; mudou=1; continue
    fi
    if [[ "${tok[0]}" == '{' && "${msk[0]}" == 0 ]]; then
      _desemb_remover 0 1; WRAPPERS+=("{"); mudou=1; continue
    fi
    p=0                                                  # o wrapper vem depois de eventuais "VAR=valor"
    while ((p < ${#tok[@]})) && [[ "${tok[p]}" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]]; do p=$((p + 1)); done
    ((p < ${#tok[@]})) || break
    w="${tok[p]##*/}"
    case "$w" in
      env)
        _desemb_remover "$p" 1
        while ((p < ${#tok[@]})) && [[ "${tok[p]}" == -* ]]; do
          case "${tok[p]}" in
            -u | -C | --unset | --chdir) _desemb_remover "$p" 2 ;;   # opções com valor no token seguinte
            *) _desemb_remover "$p" 1 ;;                            # -i, -0, -v...: booleanas
          esac
        done ;;
      command)
        case "${tok[p + 1]:-}" in -v | -V) break ;; esac            # "command -v gh" só consulta: não executa
        _desemb_remover "$p" 1
        if [[ "${tok[p]:-}" == -p ]]; then _desemb_remover "$p" 1; fi ;;
      builtin | nohup) _desemb_remover "$p" 1 ;;
      time)
        _desemb_remover "$p" 1
        if [[ "${tok[p]:-}" == -p ]]; then _desemb_remover "$p" 1; fi ;;
      sudo)
        _desemb_remover "$p" 1
        while ((p < ${#tok[@]})) && [[ "${tok[p]}" == -* ]]; do
          case "${tok[p]}" in
            -u | -g | -h | -p | -C | -D | -r | -t | -U | -T | --user | --group | --host | --prompt | --chdir) _desemb_remover "$p" 2 ;;
            --) _desemb_remover "$p" 1; break ;;
            *) _desemb_remover "$p" 1 ;;
          esac
        done ;;
      xargs)
        if [[ "${tok[p + 1]:-}" == -* ]]; then WRAPPER_NAO_SUPORTADO="xargs"; break; fi   # com flags, não sabemos o que ele faz
        _desemb_remover "$p" 1 ;;
      *) break ;;
    esac
    WRAPPERS+=("$w"); mudou=1
  done
  if ((abriu && ${#tok[@]} > 0)); then                   # o ")" que fecha o grupo, colado à última palavra
    u=$((${#tok[@]} - 1))
    if [[ "${tok[u]}" == *')' && "${msk[u]: -1}" == 0 ]]; then
      tok[u]="${tok[u]%)}"; msk[u]="${msk[u]%?}"
      if ((${#tok[u]} == 0)); then _desemb_remover "$u" 1; fi
    fi
  fi
  TOK=("${tok[@]}"); TOK_CITADO=("${cit[@]}"); TOK_MASCARA=("${msk[@]}")
}

# Tira $2 palavras a partir da posição $1 de tok, cit e msk (os arrays de quem chamou: ver _divisor_fechar).
_desemb_remover() {
  tok=("${tok[@]:0:$1}" "${tok[@]:$(($1 + $2))}")
  cit=("${cit[@]:0:$1}" "${cit[@]:$(($1 + $2))}")
  msk=("${msk[@]:0:$1}" "${msk[@]:$(($1 + $2))}")
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
