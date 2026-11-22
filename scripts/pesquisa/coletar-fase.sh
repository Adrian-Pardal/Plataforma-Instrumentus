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

# Nome do arquivo: minúsculas, sem acento, tudo que não é letra ou número vira "-" ("Fase 1" -> fase-1).
SLUG=$(tr '[:upper:]' '[:lower:]' <<<"$NOME" \
  | sed -E 's/á|à|â|ã|ä|Á|À|Â|Ã|Ä/a/g; s/é|è|ê|ë|É|È|Ê|Ë/e/g; s/í|ì|î|ï|Í|Ì|Î|Ï/i/g; s/ó|ò|ô|õ|ö|Ó|Ò|Ô|Õ|Ö/o/g; s/ú|ù|û|ü|Ú|Ù|Û|Ü/u/g; s/ç|Ç/c/g' \
  | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')
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

coletar_commits
coletar_ci

DESTINO="$RAIZ/docs/pesquisa/dados/$SLUG.csv"
mkdir -p "${DESTINO%/*}"
{ echo "fase,inicio,fim,metrica,detalhe,valor,nota"; printf '%s\n' "${LINHAS[@]}"; } > "$DESTINO.tmp" && mv "$DESTINO.tmp" "$DESTINO"
echo "✔ gravado: ${DESTINO#"$RAIZ"/}"
