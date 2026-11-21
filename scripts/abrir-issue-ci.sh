#!/usr/bin/env bash
# abrir-issue-ci.sh — abre uma issue "CI falhou na main" com o link do log, sem duplicar (plano 002, T2).
# Chamado pelo job registrar-falha do .github/workflows/ci.yml; usa o "gh" e a etiqueta "incidente".
# Entrada (variáveis): RUN_URL (obrigatória: link do log da execução), SHA e BRANCH (opcionais, só para o texto).
# Saída: 0 = abriu a issue ou já havia uma aberta · 1 = o gh falhou (não abre às cegas) · 2 = faltou RUN_URL.
set -uo pipefail

TITULO="CI falhou na main"
ETIQUETA="incidente"

[[ -n "${RUN_URL:-}" ]] || { echo "abrir-issue-ci: falta a variável RUN_URL (link do log)." >&2; exit 2; }

# Sem conseguir consultar, não dá para saber se já há uma issue aberta: falha em vez de abrir às cegas.
abertas=$(gh issue list --state open --label "$ETIQUETA" --search "$TITULO in:title" --json number --jq 'length') \
  || { echo "abrir-issue-ci: não consegui consultar as issues abertas." >&2; exit 1; }

if ((abertas > 0)); then
  echo "abrir-issue-ci: já existe uma issue aberta ($abertas); não abro outra."
  exit 0
fi

corpo="A execução do CI falhou na ${BRANCH:-main}.

- Log: $RUN_URL
- Commit: ${SHA:-desconhecido}

Leia o log, corrija e, com a causa raiz descoberta, registre o erro com /registrar-erro (docs/erros/).
Feche esta issue quando a main voltar a passar."

gh issue create --title "$TITULO" --label "$ETIQUETA" --body "$corpo" || exit 1
