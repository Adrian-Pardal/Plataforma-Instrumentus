#!/usr/bin/env bash
# session-start.sh — hook SessionStart do Claude Code (plano 005, ADR 0007).
# Grava em .claude/pesquisa/eventos.jsonl a data e hora, a versão do Claude Code ("claude --version") e a branch atual.
# NÃO IMPRIME NADA: o stdout de um hook SessionStart entra no contexto do Claude. Por isso tudo o que sai deste
# script (stdout e stderr) é descartado logo no início. Sempre sai com 0: registrar é só observar, nunca barrar.
# Rápido: este hook atrasa a primeira resposta da sessão. O "claude --version" tem limite de 5 segundos
# (PESQUISA_TIMEOUT_CLAUDE muda o limite; só os testes usam). Sem claude, git ou branch, grava "desconhecida".
set -uo pipefail   # sem -e de propósito: nada aqui pode impedir a sessão de começar
exec >/dev/null 2>&1

# shellcheck source=/dev/null  # a lib é conferida à parte pelo verify.sh (.claude/hooks/lib/*.sh)
source "${BASH_SOURCE[0]%/*}/lib/eventos.sh" || exit 0
[[ -t 0 ]] || cat >/dev/null   # esvazia o JSON da entrada (este hook não precisa dele)

# A saída do claude vai para um arquivo, não para um pipe: se o limite de tempo matar o claude, um processo
# filho que sobrar não segura o hook esperando o pipe fechar.
VERSAO=""
if command -v claude >/dev/null && command -v timeout >/dev/null; then
  SAIDA_CLAUDE=$(mktemp) && {
    timeout "${PESQUISA_TIMEOUT_CLAUDE:-5}" claude --version >"$SAIDA_CLAUDE"
    VERSAO=$(head -1 "$SAIDA_CLAUDE")
    rm -f "$SAIDA_CLAUDE"
  }
fi

BRANCH=$(git -C "${CLAUDE_PROJECT_DIR:-.}" branch --show-current)

registrar_evento sessao session-start "${VERSAO:-desconhecida}" "${BRANCH:-desconhecida}"
exit 0
