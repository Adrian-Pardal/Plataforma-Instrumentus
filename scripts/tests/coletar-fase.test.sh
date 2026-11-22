#!/usr/bin/env bash
# coletar-fase.test.sh — testes de scripts/pesquisa/coletar-fase.sh (plano 006, ADR 0007).
# Cada caso monta um projeto temporário (repositório git com commits de data fixa, ERR, sessões e eventos de
# exemplo) e aponta COLETA_RAIZ para ele. O "gh" é falso e o "claude" também: nenhum caso usa a rede nem uma IA.
# Uso: scripts/tests/coletar-fase.test.sh   (sai com 1 se algum caso falhar)
set -uo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$RAIZ/scripts/pesquisa/coletar-fase.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
falhas=0

if ! command -v git >/dev/null || ! command -v jq >/dev/null; then
  echo "• git ou jq não instalado: testes pulados"
  exit 0
fi

confere() {   # confere <esperado> <obtido> <descrição>
  if [[ "$1" == "$2" ]]; then
    echo "  ok    $3"
  else
    echo "  FALHA $3 (esperado '$1', veio '$2')" >&2
    falhas=$((falhas + 1))
  fi
}

# --- Ferramentas falsas (vão na frente do PATH) ---------------------------------------------------------------
mkdir -p "$TMP/gh-ok" "$TMP/gh-falha" "$TMP/claude-falso"
# gh que responde ao "gh run list --created 2026-10-25..2026-10-28": 2 success, 1 failure, 1 em andamento.
cat > "$TMP/gh-ok/gh" <<'FIM'
#!/usr/bin/env bash
case "$*" in
  "run list "*"--created 2026-10-25..2026-10-28"*) ;;
  "run list "*"--created 2026-10-26..2026-10-26"*) echo '[]'; exit 0 ;;
  *) echo "gh falso: argumentos inesperados: $*" >&2; exit 1 ;;
esac
echo '[{"workflowName":"CI","conclusion":"success"},{"workflowName":"CI","conclusion":"success"},{"workflowName":"CI","conclusion":"failure"},{"workflowName":"CI","conclusion":""}]'
FIM
printf '%s\n' '#!/usr/bin/env bash' 'echo "HTTP 401: sem acesso" >&2' 'exit 1' > "$TMP/gh-falha/gh"
# claude que marca que foi chamado: o script NUNCA pode chamar uma IA.
printf '%s\n' '#!/usr/bin/env bash' "touch \"$TMP/claude-chamado\"" 'exit 99' > "$TMP/claude-falso/claude"
chmod +x "$TMP/gh-ok/gh" "$TMP/gh-falha/gh" "$TMP/claude-falso/claude"

# --- Montagem do projeto de exemplo ---------------------------------------------------------------------------
commit_em() {   # commit_em <pasta> <data ISO UTC>: commit vazio com a data fixa (sem assinatura nem hooks do git)
  GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git -C "$1" -c user.name=teste -c user.email=teste@exemplo.com \
    -c commit.gpgsign=false -c core.hooksPath=/dev/null commit -q --allow-empty -m "c $2" || { echo "FALHA: commit" >&2; exit 1; }
}
# Projeto com 5 commits: 2 FORA do intervalo 2026-10-25..2026-10-28 (um segundo antes e um segundo depois) e 3 dentro,
# dois deles exatamente nas bordas.
projeto() {   # projeto <nome>; deixa o caminho em P
  P="$TMP/$1"; mkdir -p "$P"
  git init -q -b main "$P" || { echo "FALHA: git init" >&2; exit 1; }
  commit_em "$P" "2026-10-24T23:59:59Z"
  commit_em "$P" "2026-10-25T00:00:00Z"
  commit_em "$P" "2026-10-26T12:00:00Z"
  commit_em "$P" "2026-10-28T23:59:59Z"
  commit_em "$P" "2026-10-29T00:00:00Z"
}

# coleta <args...>: roda o script no projeto P, com o gh de FAKE_GH (ok ou falha) e o claude falso; guarda RC e ERR.
coleta() {
  ERR=$(cd / && COLETA_RAIZ="$P" PATH="$TMP/gh-${FAKE_GH:-ok}:$TMP/claude-falso:$PATH" "$SCRIPT" "$@" 2>&1 >/dev/null); RC=$?
}
CSV() { echo "$P/docs/pesquisa/dados/$1.csv"; }
# celula <slug> <metrica> <detalhe> <valor|nota>: o conteúdo da célula (vazio se a linha não existe ou a célula está vazia)
celula() { awk -F, -v m="$2" -v d="$3" -v c="$4" '$4==m && $5==d { print (c=="valor" ? $6 : $7); exit }' "$(CSV "$1")"; }
tem_linha() { awk -F, -v m="$2" -v d="$3" '$4==m && $5==d { f=1 } END { print f ? "sim" : "nao" }' "$(CSV "$1")"; }

echo "▶ coletar-fase: argumentos inválidos (exit 2, mensagem de uso, nada gravado)"
projeto args
coleta;                                       confere 2 "$RC" "sem argumentos"
confere true "$([[ "$ERR" == *Uso:* ]] && echo true || echo false)" "sem argumentos: mostra a mensagem de uso"
confere false "$([[ -e "$P/docs/pesquisa/dados" ]] && echo true || echo false)" "sem argumentos: não grava nada"
coleta "Fase 1" 2026-10-25;                   confere 2 "$RC" "falta a data final"
coleta "Fase 1" 2026-10-25 2026-10-28 extra;  confere 2 "$RC" "argumento a mais"
coleta "Fase 1" 2026-13-45 2026-10-28;        confere 2 "$RC" "data inválida (mês 13)"
coleta "Fase 1" 2026-02-30 2026-10-28;        confere 2 "$RC" "data que não existe (30 de fevereiro)"
coleta "Fase 1" 26-10-25 2026-10-28;          confere 2 "$RC" "data fora do formato AAAA-MM-DD"
coleta "Fase 1" 2026-10-28 2026-10-25;        confere 2 "$RC" "início depois do fim"
coleta "" 2026-10-25 2026-10-28;              confere 2 "$RC" "nome da fase vazio"
coleta "!!!" 2026-10-25 2026-10-28;           confere 2 "$RC" "nome sem nenhuma letra ou número"
confere false "$([[ -e "$P/docs/pesquisa/dados" ]] && echo true || echo false)" "nenhum erro de uso gravou arquivo"

echo "▶ coletar-fase: csv, nome do arquivo e commits"
projeto basico
coleta "Fase 1" 2026-10-25 2026-10-28
confere 0 "$RC" "caso feliz: exit 0"
confere "fase,inicio,fim,metrica,detalhe,valor,nota" "$(head -1 "$(CSV fase-1)")" "cabeçalho do csv"
confere "Fase 1,2026-10-25,2026-10-28,commits,total,3," "$(grep ',commits,total,' "$(CSV fase-1)")" "commits: 3 (bordas dentro, 1 s fora não conta)"
coleta "Fase 1" 2026-10-26 2026-10-26
confere 1 "$(celula fase-1 commits total valor)" "commits: intervalo de um dia só"
cp "$(CSV fase-1)" "$TMP/antes.csv"; coleta "Fase 1" 2026-10-26 2026-10-26
confere true "$(cmp -s "$TMP/antes.csv" "$(CSV fase-1)" && echo true || echo false)" "rodar de novo dá o mesmo arquivo"
coleta "Fase de Testes!" 2026-10-25 2026-10-28
confere true "$([[ -f "$(CSV fase-de-testes)" ]] && echo true || echo false)" "nome vira fase-de-testes.csv"
coleta "Fase 1, teste" 2026-10-25 2026-10-28
confere "\"Fase 1, teste\",2026-10-25,2026-10-28,commits,total,3," "$(grep ',commits,total,' "$(CSV fase-1-teste)")" "nome com vírgula vai entre aspas"
P="$TMP/sem-git"; mkdir -p "$P"
coleta "Fase 1" 2026-10-25 2026-10-28
confere 0 "$RC" "fora de repositório git: exit 0"
confere "sim" "$(tem_linha fase-1 commits total)" "fora de repositório git: a linha existe"
confere "" "$(celula fase-1 commits total valor)" "fora de repositório git: valor vazio, nunca 0"
confere "não é um repositório git" "$(celula fase-1 commits total nota)" "fora de repositório git: a nota diz por quê"

if [[ $falhas -gt 0 ]]; then
  echo "✖ $falhas caso(s) de coletar-fase falharam" >&2
  exit 1
fi
echo "✔ todos os casos de coletar-fase passaram"
