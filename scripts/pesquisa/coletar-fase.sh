#!/usr/bin/env bash
# coletar-fase.sh — coleta os números de uma fase da pesquisa e grava docs/pesquisa/dados/<fase>.csv.
# Uso: scripts/pesquisa/coletar-fase.sh "<nome da fase>" <AAAA-MM-DD início> <AAAA-MM-DD fim>
# Plano 006, ADR 0007, protocolo em docs/pesquisa/protocolo.md. Usa só git, gh, jq e awk: NENHUMA IA é chamada.
# Regras:
#   - intervalo FECHADO nas duas pontas e em UTC; ERR e sessões são comparados pela data escrita neles;
#   - dado que não existe fica VAZIO (nunca 0) e a coluna "nota" diz por quê;
#   - o csv só tem números e nomes de hook, categoria ou tipo: nada de conteúdo de conversa;
#   - COLETA_RAIZ troca a raiz do projeto (só os testes usam).
# Saída: 0 = csv gravado · 2 = uso incorreto (nada é gravado).
set -uo pipefail   # sem -e de propósito: uma fonte que falha não derruba as outras

RAIZ="${COLETA_RAIZ:-$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)}"

uso() { echo "Uso: scripts/pesquisa/coletar-fase.sh \"<nome da fase>\" <AAAA-MM-DD início> <AAAA-MM-DD fim>" >&2; exit 2; }
erro() { echo "✖ coletar-fase: $1" >&2; exit 2; }

# --- Argumentos -------------------------------------------------------------------------------------------------
[[ $# -eq 3 ]] || uso
NOME="$1"; INICIO="$2"; FIM="$3"
data_valida() { [[ "$1" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ && "$(date -u -d "$1" +%F 2>/dev/null)" == "$1" ]]; }
data_valida "$INICIO" || erro "data inicial inválida: use AAAA-MM-DD ('$INICIO')"
data_valida "$FIM" || erro "data final inválida: use AAAA-MM-DD ('$FIM')"
[[ ! "$INICIO" > "$FIM" ]] || erro "a data inicial ($INICIO) vem depois da final ($FIM)"

# Minúsculas e sem acento (lê o stdin). As alternâncias do sed funcionam byte a byte, em qualquer locale.
minusculas_sem_acento() {
  sed -E 's/á|à|â|ã|ä|Á|À|Â|Ã|Ä/a/g; s/é|è|ê|ë|É|È|Ê|Ë/e/g; s/í|ì|î|ï|Í|Ì|Î|Ï/i/g; s/ó|ò|ô|õ|ö|Ó|Ò|Ô|Õ|Ö/o/g; s/ú|ù|û|ü|Ú|Ù|Û|Ü/u/g; s/ç|Ç/c/g' \
    | tr '[:upper:]' '[:lower:]'
}

# Nome do arquivo: minúsculas, sem acento, tudo que não é letra ou número vira "-" ("Fase 1" -> fase-1).
SLUG=$(minusculas_sem_acento <<<"$NOME" | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')
[[ -n "$SLUG" ]] || erro "o nome da fase precisa ter pelo menos uma letra ou um número"

# --- Saída ------------------------------------------------------------------------------------------------------
csv() {   # csv <campo>...: uma linha csv; campo com vírgula, aspas ou quebra de linha vai entre aspas
  local c; local -a saida=()
  for c in "$@"; do
    [[ "$c" == *[,\"$'\n']* ]] && c="\"${c//\"/\"\"}\""
    saida+=("$c")
  done
  local IFS=,; echo "${saida[*]}"
}
LINHAS=()
linha() { LINHAS+=("$(csv "$NOME" "$INICIO" "$FIM" "$@")"); }   # linha <metrica> <detalhe> <valor> <nota>

# --- Commits ----------------------------------------------------------------------------------------------------
coletar_commits() {
  local n
  if ! git -C "$RAIZ" rev-parse --git-dir >/dev/null 2>&1; then
    linha commits total "" "não é um repositório git"
  elif n=$(git -C "$RAIZ" rev-list --count --since="${INICIO}T00:00:00Z" --until="${FIM}T23:59:59Z" HEAD 2>/dev/null); then
    linha commits total "$n" ""
  else
    linha commits total "" "o git não conseguiu contar os commits"
  fi
}

# --- Execuções de CI (gh) ---------------------------------------------------------------------------------------
# Total e, por workflow, o resultado ("CI/success"; sem conclusão = "em-andamento"). gh ausente ou falhando não
# derruba a coleta: o valor fica vazio, com a nota e um aviso no stderr.
coletar_ci() {
  local json total nota=""
  if ! command -v gh >/dev/null 2>&1; then
    linha ci total "" "gh não instalado"; return
  fi
  if ! json=$(cd "$RAIZ" && gh run list --created "${INICIO}..${FIM}" --limit 1000 --json workflowName,conclusion 2>/dev/null) \
     || ! jq -e 'type == "array"' >/dev/null 2>&1 <<<"$json"; then
    echo "aviso: 'gh run list' falhou; as execuções de CI ficam sem valor" >&2
    linha ci total "" "gh indisponível ou sem acesso"; return
  fi
  total=$(jq 'length' <<<"$json")
  [[ "$total" -lt 1000 ]] || nota="limite de 1000 execuções atingido; contagem pode estar incompleta"
  linha ci total "$total" "$nota"
  local n detalhe
  while IFS=$'\t' read -r n detalhe; do
    linha ci "$detalhe" "$n" ""
  done < <(jq -r 'map(.detalhe = (.workflowName + "/" + (if (.conclusion // "") == "" then "em-andamento" else .conclusion end)))
                  | group_by(.detalhe) | .[] | "\(length)\t\(.[0].detalhe)"' <<<"$json")
}

# --- Erros registrados (docs/erros/ERR-*.md) -------------------------------------------------------------------
# Conta por categoria os ERR cuja data (campo "data:" do frontmatter) cai no intervalo. As 4 categorias do template
# aparecem sempre, mesmo com 0 (a pasta existe, então 0 é um número de verdade). ERR sem data ou sem categoria
# não entra em nenhuma contagem, mas aparece numa linha própria: nada some em silêncio.
coletar_err() {
  local pasta="$RAIZ/docs/erros" arq data categoria sem=0 c
  if [[ ! -d "$pasta" ]]; then
    linha err total "" "pasta docs/erros ausente"; return
  fi
  local -A conta=([bug]=0 [erro-ia]=0 [ambiente]=0 [producao]=0)
  for arq in "$pasta"/ERR-*.md; do
    [[ -f "$arq" ]] || continue
    # lê só o frontmatter (entre o 1º e o 2º "---"): "data|categoria"
    IFS='|' read -r data categoria < <(awk 'NR == 1 { if ($0 != "---") exit; next }
                                            $0 == "---" { exit }
                                            $1 == "data:" { d = $2 }
                                            $1 == "categoria:" { c = $2 }
                                            END { print d "|" c }' "$arq")
    if [[ ! "$data" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ || -z "$categoria" ]]; then
      sem=$((sem + 1)); continue
    fi
    if [[ ! "$data" < "$INICIO" && ! "$data" > "$FIM" ]]; then
      conta[$categoria]=$(( ${conta[$categoria]:-0} + 1 ))
    fi
  done
  while IFS= read -r c; do
    linha err "$c" "${conta[$c]}" ""
  done < <(printf '%s\n' "${!conta[@]}" | sort)
  [[ $sem -eq 0 ]] || linha err sem-data-ou-categoria "$sem" "ERR com frontmatter incompleto, fora das contagens"
}

# --- Intervenções humanas (docs/pesquisa/sessoes/AAAA-MM-DD*.md) ------------------------------------------------
# Soma, por tipo, as linhas da tabela "Intervenções humanas" (3ª coluna) dos registros de sessão cuja data (o início
# do nome do arquivo) cai no intervalo. Os 6 tipos são os do protocolo (§3); "?" e qualquer tipo que não se
# reconhece contam como "indefinido". Só a tabela dessa seção conta (a próxima seção, com outras tabelas, não).
# Sessão sem a tabela aparece numa linha própria e fica fora das contagens: nada some em silêncio.
TIPOS_INTERVENCAO=(decisao aprovacao correcao operacao-manual desbloqueio aprendizado)
coletar_intervencoes() {
  local pasta="$RAIZ/docs/pesquisa/sessoes" arq base data tipos tipo t
  local lidas=0 sem_tabela=0 total=0
  local -A conta=([decisao]=0 [aprovacao]=0 [correcao]=0 [operacao-manual]=0 [desbloqueio]=0 [aprendizado]=0 [indefinido]=0)
  for arq in "$pasta"/*.md; do
    [[ -f "$arq" ]] || continue
    base="${arq##*/}"; data="${base:0:10}"
    [[ "$data" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || continue         # README.md e outros nomes ficam de fora
    [[ ! "$data" < "$INICIO" && ! "$data" > "$FIM" ]] || continue
    tipos=$(awk '/^#+[[:space:]]+Intervenções humanas/ { dentro = 1; achou = 1; next }
                 dentro && /^#/ { dentro = 0 }
                 dentro && /^\|/ {
                   split($0, c, "|"); tipo = c[4]; gsub(/^[ \t]+|[ \t]+$/, "", tipo)
                   if (c[2] ~ /^[ \t]*#[ \t]*$/ || tipo ~ /^[-: ]+$/) next      # cabeçalho e separador da tabela
                   print (tipo == "" ? "?" : tipo)                              # tipo em branco = indefinido
                 }
                 END { if (!achou) print "@@sem-secao@@" }' "$arq")
    if [[ "$tipos" == "@@sem-secao@@" ]]; then sem_tabela=$((sem_tabela + 1)); continue; fi
    lidas=$((lidas + 1))
    while IFS= read -r tipo; do
      [[ -n "$tipos" ]] || break                                          # tabela sem nenhuma linha
      t=$(minusculas_sem_acento <<<"$tipo" | sed -E 's/[[:space:]]+/-/g')
      [[ -v "conta[$t]" && "$t" != indefinido ]] || t=indefinido
      conta[$t]=$(( ${conta[$t]} + 1 )); total=$((total + 1))
    done <<<"$tipos"
  done
  if [[ $lidas -eq 0 ]]; then
    if [[ $sem_tabela -eq 0 ]]; then
      linha intervencoes total "" "sem registros de sessão no período"
    else
      linha intervencoes total "" "nenhuma sessão do período tem a tabela Intervenções humanas"
    fi
  else
    for t in "${TIPOS_INTERVENCAO[@]}" indefinido; do linha intervencoes "$t" "${conta[$t]}" ""; done
    linha intervencoes total "$total" ""
    linha intervencoes sessoes-lidas "$lidas" ""
  fi
  [[ $sem_tabela -eq 0 ]] || linha intervencoes sessoes-sem-tabela "$sem_tabela" "sessão sem a tabela Intervenções humanas; fora das contagens"
}

# --- Bloqueios dos hooks (.claude/pesquisa/eventos.jsonl) -------------------------------------------------------
# Conta os eventos "bloqueio" do intervalo por hook. O arquivo só existe desde que os hooks passaram a gravá-lo
# (plano 005), então a cobertura é conferida: intervalo inteiro antes do primeiro evento = sem valor; intervalo que
# começa antes dele = contagem sai com um aviso de que é parcial. Linhas que não são JSON são ignoradas.
HOOKS_CONHECIDOS=(protect-files protect-push protect-merge stop-verify)
coletar_bloqueios() {
  local arq="$RAIZ/.claude/pesquisa/eventos.jsonl" primeiro n hook
  local -A conta=()
  if [[ ! -f "$arq" ]]; then
    linha bloqueios total "" "arquivo de eventos ausente"; return
  fi
  primeiro=$(jq -Rr 'fromjson? | select(type == "object") | .quando // empty' "$arq" 2>/dev/null | sort | head -1)
  if [[ -z "$primeiro" ]]; then
    linha bloqueios total "" "arquivo de eventos vazio"; return
  fi
  primeiro="${primeiro:0:10}"
  if [[ "$FIM" < "$primeiro" ]]; then
    for hook in "${HOOKS_CONHECIDOS[@]}"; do linha bloqueios "$hook" "" "eventos só existem desde $primeiro"; done
    return
  fi
  for hook in "${HOOKS_CONHECIDOS[@]}"; do conta[$hook]=0; done
  while read -r n hook; do
    conta[$hook]=$n
  done < <(jq -Rr --arg ini "${INICIO}T00:00:00Z" --arg fim "${FIM}T23:59:59Z" \
             'fromjson? | select(type == "object" and .tipo == "bloqueio" and .quando >= $ini and .quando <= $fim) | .hook // empty' \
             "$arq" 2>/dev/null | sort | uniq -c | awk '{ print $1, $2 }')
  while IFS= read -r hook; do
    linha bloqueios "$hook" "${conta[$hook]}" ""
  done < <(printf '%s\n' "${!conta[@]}" | sort)
  [[ ! "$INICIO" < "$primeiro" ]] || linha bloqueios cobertura "" "eventos só existem desde $primeiro; contagens parciais"
}

coletar_commits
coletar_ci
coletar_err
coletar_intervencoes
coletar_bloqueios

DESTINO="$RAIZ/docs/pesquisa/dados/$SLUG.csv"
mkdir -p "${DESTINO%/*}"
{ echo "fase,inicio,fim,metrica,detalhe,valor,nota"; printf '%s\n' "${LINHAS[@]}"; } > "$DESTINO.tmp" && mv "$DESTINO.tmp" "$DESTINO"
echo "✔ gravado: ${DESTINO#"$RAIZ"/}"
