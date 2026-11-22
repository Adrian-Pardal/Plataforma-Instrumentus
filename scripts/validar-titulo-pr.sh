#!/usr/bin/env bash
# validar-titulo-pr.sh — confere se o título de um PR segue Conventional Commits (plano 003, T2).
# Chamado pelo job titulo-do-pr do .github/workflows/ci.yml. O título entra pela variável TITULO.
# Mesmo padrão do commit-msg do lefthook: tipo, escopo opcional, "!" opcional e ": " antes da descrição.
# Saída: 0 = título válido · 1 = fora do padrão · 2 = faltou a variável TITULO.
set -uo pipefail

PADRAO='^(feat|fix|docs|test|refactor|chore|ci|build|perf)(\([a-z0-9._/-]+\))?!?: .+'

[[ -v TITULO ]] || { echo "validar-titulo-pr: falta a variável TITULO." >&2; exit 2; }

# O título é texto digitado por qualquer um: nunca vai para eval nem para uma linha de comando.
if [[ "$TITULO" =~ $PADRAO && "$TITULO" == *[![:space:]]* ]]; then
  exit 0
fi

echo "O título do PR não segue Conventional Commits: \"$TITULO\"" >&2
echo "Formato: tipo(escopo opcional): descrição. Tipos: feat, fix, docs, test, refactor, chore, ci, build, perf." >&2
echo "Exemplos: \"feat: abre pesquisa\", \"fix(ci): corrige o job\", \"feat!: troca a escala\"." >&2
exit 1
