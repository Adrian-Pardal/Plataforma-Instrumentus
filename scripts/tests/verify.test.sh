#!/usr/bin/env bash
# verify.test.sh — testes da detecção de testes desativados/isolados do verify.sh.
# Cria um projeto falso numa pasta temporária e aponta VERIFY_RAIZ para ele.
# Uso: scripts/tests/verify.test.sh   (sai com 1 se algum caso falhar)
set -uo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
VERIFY="$RAIZ/scripts/verify.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
falhas=0

caso() {   # caso <código esperado> <descrição> <conteúdo do arquivo de teste>
  local esperado="$1" descricao="$2" conteudo="$3" obtido
  mkdir -p "$TMP/src/test"
  printf '%s\n' "$conteudo" > "$TMP/src/test/a.test.ts"
  VERIFY_RAIZ="$TMP" "$VERIFY" test >/dev/null 2>&1
  obtido=$?
  if [[ "$obtido" == "$esperado" ]]; then
    echo "  ok    ($esperado) $descricao"
  else
    echo "  FALHA (esperado $esperado, veio $obtido) $descricao" >&2
    falhas=$((falhas + 1))
  fi
}

echo "▶ verify.sh: testes desativados ou isolados"
caso 0 "teste normal passa"                       "it('x', () => {});"
caso 1 "it.only reprova"                          "it.only('x', () => {});"
caso 1 "xit reprova"                              "xit('x', () => {});"
caso 1 "fit reprova"                              "fit('x', () => {});"
caso 1 "fdescribe reprova"                        "fdescribe('x', () => {});"
caso 0 "fit com DEBT na linha anterior passa"     $'// DEBT-001\nfit(\'x\', () => {});'
caso 0 "benefit( não é falso positivo"            "const b = benefit(2);"

# Projeto falso com scripts/tests/*.test.sh e scripts/*.sh próprios.
TMP2="$(mktemp -d)"
trap 'rm -rf "$TMP" "$TMP2"' EXIT

caso_scripts() {   # caso_scripts <esperado> <modo> <descrição> <conteúdo do teste> <conteúdo do script>
  local esperado="$1" modo="$2" descricao="$3" teste="$4" script="$5" obtido
  rm -rf "$TMP2/scripts"; mkdir -p "$TMP2/scripts/tests"
  printf '%s\n' "$teste" > "$TMP2/scripts/tests/a.test.sh"; chmod +x "$TMP2/scripts/tests/a.test.sh"
  printf '%s\n' "$script" > "$TMP2/scripts/b.sh"
  VERIFY_RAIZ="$TMP2" "$VERIFY" "$modo" >/dev/null 2>&1
  obtido=$?
  if [[ "$obtido" == "$esperado" ]]; then
    echo "  ok    ($esperado) $descricao"
  else
    echo "  FALHA (esperado $esperado, veio $obtido) $descricao" >&2
    falhas=$((falhas + 1))
  fi
}

TESTE_OK=$'#!/usr/bin/env bash\nexit 0'
TESTE_RUIM=$'#!/usr/bin/env bash\nexit 1'
SCRIPT_OK=$'#!/usr/bin/env bash\necho "oi"'
SCRIPT_RUIM=$'#!/usr/bin/env bash\ncd $1'   # SC2086/SC2164: shellcheck reclama

echo "▶ verify.sh: roda scripts/tests/*.test.sh nos modos test e full"
caso_scripts 0 test "test: teste de script que passa"  "$TESTE_OK"   "$SCRIPT_OK"
caso_scripts 1 test "test: teste de script que falha"  "$TESTE_RUIM" "$SCRIPT_OK"
caso_scripts 1 full "full: teste de script que falha"  "$TESTE_RUIM" "$SCRIPT_OK"

# Plano 005, T2: o hook Stop roda verify.sh com CLAUDE_PROJECT_DIR apontando para o projeto real; se os testes
# dos hooks a herdassem, gravariam eventos falsos no arquivo da pesquisa. O verify.sh tira a variável deles.
TESTE_SEM_VARIAVEL=$'#!/usr/bin/env bash\n[[ -z "${CLAUDE_PROJECT_DIR:-}" ]]'   # passa só se a variável NÃO existir
echo "▶ verify.sh: os testes dos scripts não enxergam CLAUDE_PROJECT_DIR"
CLAUDE_PROJECT_DIR=/projeto/real caso_scripts 0 test "test: a variável não chega ao teste de script" "$TESTE_SEM_VARIAVEL" "$SCRIPT_OK"
CLAUDE_PROJECT_DIR=/projeto/real caso_scripts 0 full "full: a variável não chega ao teste de script" "$TESTE_SEM_VARIAVEL" "$SCRIPT_OK"

echo "▶ verify.sh: shellcheck só no modo full"
caso_scripts 0 test "test: não roda shellcheck"        "$TESTE_OK" "$SCRIPT_RUIM"
if command -v shellcheck >/dev/null; then
  caso_scripts 0 full "full: script limpo passa"       "$TESTE_OK" "$SCRIPT_OK"
  caso_scripts 1 full "full: shellcheck reprova"       "$TESTE_OK" "$SCRIPT_RUIM"
else
  echo "  • shellcheck não instalado: casos do modo full pulados"
fi

# Biblioteca sem shebang (.claude/hooks/lib/*.sh): o shellcheck do modo full também precisa olhá-la.
# Sem a diretiva "# shellcheck shell=bash", o próprio shellcheck reprova (SC2148). Plano 001, T0.
caso_lib() {   # caso_lib <esperado> <modo> <descrição> <conteúdo do lib>
  local esperado="$1" modo="$2" descricao="$3" lib="$4" obtido
  rm -rf "$TMP2/scripts" "$TMP2/.claude"; mkdir -p "$TMP2/scripts/tests" "$TMP2/.claude/hooks/lib"
  printf '%s\n' "$lib" > "$TMP2/.claude/hooks/lib/x.sh"
  VERIFY_RAIZ="$TMP2" "$VERIFY" "$modo" >/dev/null 2>&1
  obtido=$?
  if [[ "$obtido" == "$esperado" ]]; then
    echo "  ok    ($esperado) $descricao"
  else
    echo "  FALHA (esperado $esperado, veio $obtido) $descricao" >&2
    falhas=$((falhas + 1))
  fi
}

LIB_OK=$'# shellcheck shell=bash\nf() { echo "oi"; }'
LIB_SEM_DIRETIVA='f() { echo "oi"; }'
LIB_RUIM=$'# shellcheck shell=bash\ncd $1'   # SC2086/SC2164: shellcheck reclama

echo "▶ verify.sh: o shellcheck também olha .claude/hooks/lib/*.sh"
if command -v shellcheck >/dev/null; then
  caso_lib 0 full "full: lib limpo, com a diretiva shell=bash, passa"  "$LIB_OK"
  caso_lib 1 full "full: lib com erro de shellcheck reprova"           "$LIB_RUIM"
  caso_lib 1 full "full: lib sem a diretiva shell=bash reprova"        "$LIB_SEM_DIRETIVA"
  caso_lib 0 test "test: não roda shellcheck no lib"                   "$LIB_RUIM"
else
  echo "  • shellcheck não instalado: casos do lib pulados"
fi
rm -rf "$TMP2/.claude"   # os casos do actionlint abaixo reaproveitam esta pasta

# Plano 006, T6: o shellcheck do modo full também olha as subpastas de scripts/ (scripts/pesquisa/ e scripts/tests/).
caso_subpasta() {   # caso_subpasta <esperado> <modo> <descrição> <conteúdo de scripts/pesquisa/c.sh>
  local esperado="$1" modo="$2" descricao="$3" script="$4" obtido
  rm -rf "$TMP2/scripts" "$TMP2/.claude"; mkdir -p "$TMP2/scripts/tests" "$TMP2/scripts/pesquisa"
  printf '%s\n' "$script" > "$TMP2/scripts/pesquisa/c.sh"
  VERIFY_RAIZ="$TMP2" "$VERIFY" "$modo" >/dev/null 2>&1
  obtido=$?
  if [[ "$obtido" == "$esperado" ]]; then
    echo "  ok    ($esperado) $descricao"
  else
    echo "  FALHA (esperado $esperado, veio $obtido) $descricao" >&2
    falhas=$((falhas + 1))
  fi
}

echo "▶ verify.sh: o shellcheck também olha scripts/pesquisa/*.sh"
if command -v shellcheck >/dev/null; then
  caso_subpasta 0 full "full: script limpo em scripts/pesquisa passa"   "$SCRIPT_OK"
  caso_subpasta 1 full "full: script com erro em scripts/pesquisa reprova" "$SCRIPT_RUIM"
  caso_subpasta 0 test "test: não roda shellcheck em scripts/pesquisa"  "$SCRIPT_RUIM"
else
  echo "  • shellcheck não instalado: casos de scripts/pesquisa pulados"
fi
rm -rf "$TMP2/scripts"

# actionlint: usa um "actionlint" falso no PATH e um projeto com (ou sem) .github/workflows.
caso_actionlint() {   # caso_actionlint <esperado> <modo> <descrição> <saída do actionlint falso> <com workflows: sim|nao>
  local esperado="$1" modo="$2" descricao="$3" saida="$4" com_wf="$5" obtido FALSO3
  FALSO3="$(mktemp -d)"
  rm -rf "$TMP2/scripts" "$TMP2/.github"; mkdir -p "$TMP2/scripts/tests"
  [[ "$com_wf" == sim ]] && mkdir -p "$TMP2/.github/workflows"
  printf '%s\n' '#!/usr/bin/env bash' "exit $saida" > "$FALSO3/actionlint"; chmod +x "$FALSO3/actionlint"
  PATH="$FALSO3:$PATH" VERIFY_RAIZ="$TMP2" "$VERIFY" "$modo" >/dev/null 2>&1
  obtido=$?
  rm -rf "$FALSO3"
  if [[ "$obtido" == "$esperado" ]]; then
    echo "  ok    ($esperado) $descricao"
  else
    echo "  FALHA (esperado $esperado, veio $obtido) $descricao" >&2
    falhas=$((falhas + 1))
  fi
}

echo "▶ verify.sh: actionlint só no modo full, só se houver .github/workflows"
caso_actionlint 0 test "test: não roda actionlint"              1 sim
caso_actionlint 0 full "full: actionlint limpo passa"           0 sim
caso_actionlint 1 full "full: actionlint reprova"               1 sim
caso_actionlint 0 full "full: sem .github/workflows, não roda"  1 nao

if [[ $falhas -gt 0 ]]; then echo "✖ $falhas caso(s) falharam" >&2; exit 1; fi
echo "✔ todos os casos passaram"
