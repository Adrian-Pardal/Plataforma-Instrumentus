#!/usr/bin/env bash
# validar-titulo-pr.test.sh — testes do scripts/validar-titulo-pr.sh (não chama o GitHub).
# Uso: scripts/tests/validar-titulo-pr.test.sh   (sai com 1 se algum caso falhar)
set -uo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$RAIZ/scripts/validar-titulo-pr.sh"
falhas=0

caso() {   # caso <descrição> <código esperado> <título>
  local descricao="$1" esperado="$2" titulo="$3" rc
  TITULO="$titulo" "$SCRIPT" >/dev/null 2>&1
  rc=$?
  if [[ "$rc" == "$esperado" ]]; then
    echo "  ok    ($rc) $descricao"
  else
    echo "  FALHA $descricao: rc=$rc (esperado $esperado), título: '$titulo'" >&2
    falhas=$((falhas + 1))
  fi
}

echo "▶ validar-titulo-pr: títulos válidos"
caso "tipo e descrição"                       0 "feat: abre pesquisa"
caso "com escopo"                             0 "fix(ci): corrige o job"
caso "mudança incompatível (!)"               0 "feat!: troca a escala"
caso "escopo com ponto, barra e hífen"        0 "chore(deps-dev/x.y): atualiza"
caso "cada tipo da lista (docs)"              0 "docs: atualiza o help"
caso "cada tipo da lista (test)"              0 "test: cobre o caso"
caso "cada tipo da lista (refactor)"          0 "refactor: simplifica"
caso "cada tipo da lista (ci)"                0 "ci: fixa o runner"
caso "cada tipo da lista (build)"             0 "build: ajusta o pom"
caso "cada tipo da lista (perf)"              0 "perf: acelera o divisor"
caso "descrição com \$ e aspas é só texto"    0 'fix: não executa $(date) nem "aspas"'

echo "▶ validar-titulo-pr: títulos fora do padrão (1)"
caso "sem tipo"                               1 "abre pesquisa"
caso "tipo fora da lista"                     1 "feature: abre pesquisa"
caso "sem espaço depois do dois-pontos"       1 "feat:abre pesquisa"
caso "sem descrição"                          1 "feat:"
caso "só dois-pontos e espaço"                1 "feat: "
caso "tipo em maiúscula"                      1 "Feat: abre pesquisa"
caso "escopo vazio"                           1 "feat(): abre pesquisa"
caso "escopo em maiúscula"                    1 "feat(CI): abre pesquisa"
caso "espaço antes do dois-pontos"            1 "feat : abre pesquisa"
caso "título vazio"                           1 ""
caso "título de revert do GitHub"             1 'Revert "feat: abre pesquisa"'

echo "▶ validar-titulo-pr: erro de uso (2)"
env -u TITULO "$SCRIPT" >/dev/null 2>&1
rc=$?
if [[ "$rc" == 2 ]]; then
  echo "  ok    (2) sem a variável TITULO"
else
  echo "  FALHA sem TITULO: rc=$rc (esperado 2)" >&2
  falhas=$((falhas + 1))
fi

if [[ $falhas -gt 0 ]]; then echo "✖ $falhas caso(s) falharam" >&2; exit 1; fi
echo "✔ todos os casos passaram"
