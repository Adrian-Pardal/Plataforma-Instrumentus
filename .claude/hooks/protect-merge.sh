#!/usr/bin/env bash
# protect-merge.sh — hook PreToolUse (Bash).
# Libera "gh pr merge" só quando o PR mira a develop e a estratégia é merge commit (--merge).
# Bloqueia --squash, --rebase, --admin, --auto, qualquer PR cujo destino não seja a develop (main é só do dono)
# e os merges feitos por "gh api" (REST /pulls/N/merge e GraphQL mergePullRequest / enablePullRequestAutoMerge).
# Saída: 0 = liberado (ou não é merge) · 2 = bloqueado (o stderr é mostrado ao Claude e o comando NÃO roda).
set -uo pipefail   # sem -e de propósito: cada ramo decide seu próprio código de saída

bloquear() { echo "🚫 protect-merge: $1" >&2; exit 2; }

command -v jq >/dev/null || bloquear "jq não encontrado; não consegui ler o comando, então bloqueio por segurança."
ENTRADA=$(cat)
CMD=$(jq -r '.tool_input.command // empty' <<<"$ENTRADA") || bloquear "entrada JSON inválida."
[[ -n "$CMD" ]] || exit 0

CWD=$(jq -r '.cwd // empty' <<<"$ENTRADA")
[[ -n "$CWD" ]] || CWD="${CLAUDE_PROJECT_DIR:-.}"

# Um comando pode juntar vários ("cd x && gh pr merge ..."): separa em um segmento por linha.
CMD="${CMD//&&/$'\n'}"; CMD="${CMD//||/$'\n'}"; CMD="${CMD//;/$'\n'}"; CMD="${CMD//|/$'\n'}"

# Letras de opção curta que recebem um valor (-b texto, -R dono/repo...). As demais são booleanas.
CURTAS_COM_VALOR='AbFtR'

# Tira os redirecionamentos (>, >>, <, 2>, 2>&1, &>) e o alvo deles: o shell os consome antes de o gh
# rodar, então não são argumentos do "gh pr merge" (ERR-002). Um texto que veio entre aspas vem marcado
# com \x02 e por isso nunca casa: '--body ">" --squash' continua tendo o --squash como opção.
# Aqui o marcador \x02 também é removido, e tokens que ficam vazios ("") somem, como antes.
REDIR='^([0-9]*|&)(>>|>|<)'
tirar_redirecionamentos() {   # lê TOK e deixa nele o resultado
  local -a LIMPO=(); local T PULAR=0
  for T in "${TOK[@]}"; do
    if [[ $PULAR -eq 1 ]]; then PULAR=0; continue; fi      # alvo do operador anterior
    if [[ "$T" =~ $REDIR ]]; then
      [[ "$T" =~ ${REDIR}$ ]] && PULAR=1                    # operador sozinho (">"): o próximo token é o alvo
      continue                                              # "2>&1" e ">/tmp/log" já vêm com o alvo junto
    fi
    T="${T//$'\x02'/}"
    [[ -n "$T" ]] && LIMPO+=("$T")
  done
  TOK=("${LIMPO[@]}")
}

# Merge por "gh api": REST (PUT .../pulls/N/merge) ou GraphQL (mutations de merge).
analisar_api() {   # $1 = o segmento inteiro, sem aspas
  local re_rest='pulls/[^[:space:]]*/merge'
  if [[ "$1" =~ $re_rest || "$1" == *mergePullRequest* || "$1" == *enablePullRequestAutoMerge* ]]; then
    bloquear "merge por 'gh api' não é permitido; use 'gh pr merge --merge' em PR da develop."
  fi
}

analisar_merge() {   # $1 = pasta onde o gh roda; demais = argumentos depois de "merge"
  local DIR="$1"; shift
  local A ALVO="" REPO="" MERGE=0 L i
  while [[ $# -gt 0 ]]; do
    A="$1"; shift
    case "$A" in
      --admin|--admin=*) bloquear "--admin não é permitido (passa por cima das regras de proteção)." ;;
      --auto|--auto=*)   bloquear "--auto não é permitido (o merge aconteceria depois, sem você pedir)." ;;
      --squash|--squash=*|--rebase|--rebase=*) bloquear "só é permitido merge commit (--merge); '$A' não." ;;
      --merge|--merge=true) MERGE=1 ;;
      --repo=*) REPO="${A#--repo=}" ;;
      --repo) REPO="${1:-}"; shift || true ;;
      --body|--body-file|--author-email|--subject|--match-head-commit) shift || true ;;   # opções com valor
      --*) ;;                                      # outras longas (--delete-branch, --disable-auto...)
      -?*)                                         # curtas, possivelmente juntas (-dm, -ds)
        for ((i = 1; i < ${#A}; i++)); do
          L="${A:i:1}"
          case "$L" in
            s|r) bloquear "só é permitido merge commit (--merge); '-$L' não." ;;
            m) MERGE=1 ;;
            d) ;;
            [$CURTAS_COM_VALOR])
              # o valor é o resto do argumento ("-Rdono/repo") ou o próximo argumento
              if [[ $((i + 1)) -lt ${#A} ]]; then
                [[ "$L" == R ]] && REPO="${A:i+1}"
              else
                [[ "$L" == R ]] && REPO="${1:-}"
                shift || true
              fi
              break ;;
            *) bloquear "opção desconhecida '-$L' em 'gh pr merge'; bloqueio por segurança." ;;
          esac
        done ;;
      *) ALVO="$A" ;;                              # número, URL ou nome da branch do PR
    esac
  done

  [[ "$MERGE" == 1 ]] || bloquear "use 'gh pr merge --merge' (merge commit)."

  # Pergunta ao GitHub para onde o PR vai. Sem ALVO, o gh usa o PR da branch atual (igual ao "gh pr merge").
  local -a ARGS=(pr view)
  [[ -z "$ALVO" ]] || ARGS+=("$ALVO")
  [[ -z "$REPO" ]] || ARGS+=(-R "$REPO")
  ARGS+=(--json baseRefName --jq .baseRefName)
  local BASE
  BASE=$(cd "$DIR" && gh "${ARGS[@]}" 2>/dev/null) || bloquear "não consegui consultar o destino do PR com 'gh pr view'; bloqueio por segurança."
  [[ "$BASE" == "develop" ]] || bloquear "o PR mira '${BASE:-?}'. Só é permitido merge em 'develop'; merge na 'main' é só do dono."
}

while IFS= read -r SEG; do
  # Um texto entre aspas ("texto --squash") é UM argumento: troca os espaços de dentro por \x01, tira as aspas
  # e põe o marcador \x02 na frente (para tirar_redirecionamentos não confundir '">"' com um redirecionamento).
  re_aspas='"[^"]*"|'"'[^']*'"
  while [[ "$SEG" =~ $re_aspas ]]; do
    TRECHO="${BASH_REMATCH[0]}"
    NOVO="${TRECHO:1:${#TRECHO}-2}"; NOVO=$'\x02'"${NOVO//[[:space:]]/$'\x01'}"
    SEG="${SEG/"$TRECHO"/$NOVO}"
  done
  read -ra TOK <<<"$SEG"
  tirar_redirecionamentos
  [[ ${#TOK[@]} -gt 0 ]] || continue

  i=0
  while [[ $i -lt ${#TOK[@]} && "${TOK[$i]}" == *=* ]]; do i=$((i+1)); done   # pula "VAR=valor gh ..."
  [[ "${TOK[$i]:-}" == "gh" || "${TOK[$i]:-}" == */gh ]] || continue

  case "${TOK[$((i+1))]:-}" in
    api) analisar_api "${SEG//$'\x02'/}" ;;
    pr)  [[ "${TOK[$((i+2))]:-}" == "merge" ]] && analisar_merge "$CWD" "${TOK[@]:$((i+3))}" ;;
  esac
done <<<"$CMD"

exit 0
