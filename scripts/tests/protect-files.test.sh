#!/usr/bin/env bash
# protect-files.test.sh — testes do hook protect-files.sh (ADR Aceito, .env e comandos Bash).
# Monta um projeto temporário com um ADR Aceito e roda o hook com o diretório do processo em "/",
# diferente do "cwd" do JSON: assim um caminho relativo só funciona se o hook o resolver com o cwd.
# Uso: scripts/tests/protect-files.test.sh   (sai com 1 se algum caso falhar)
set -uo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
HOOK="$RAIZ/.claude/hooks/protect-files.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
falhas=0

ADR_REL="docs/adr/0009-exemplo.md"
mkdir -p "$TMP/docs/adr"
ORIGINAL=$'# ADR 0009\n\n- **Status:** Aceito\n- **Data:** 2026-01-01\n\nTexto da decisão.'
printf '%s\n' "$ORIGINAL" > "$TMP/$ADR_REL"

# Segundo ADR Aceito (0001), usado nos casos de Edit e no glob docs/adr/0001-*.md do Bash.
ADR1_REL="docs/adr/0001-exemplo.md"
printf '# ADR 0001\n\n- **Status:** Aceito\n- **Data:** 2026-01-01\n\nTexto da decisão.\n' > "$TMP/$ADR1_REL"

caso() {   # caso <código esperado> <descrição> <file_path> <conteúdo novo do Write>
  local esperado="$1" descricao="$2" caminho="$3" conteudo="$4" obtido
  jq -n --arg p "$caminho" --arg c "$conteudo" --arg d "$TMP" \
    '{tool_name: "Write", tool_input: {file_path: $p, content: $c}, cwd: $d}' \
    | (cd / && "$HOOK") >/dev/null 2>&1
  obtido=$?
  if [[ "$obtido" == "$esperado" ]]; then
    echo "  ok    ($esperado) $descricao"
  else
    echo "  FALHA (esperado $esperado, veio $obtido) $descricao" >&2
    falhas=$((falhas + 1))
  fi
}

# Igual ao "caso", mas recebe o nome da ferramenta e o tool_input (JSON) prontos: serve para Edit e Bash.
caso_json() {   # caso_json <código esperado> <descrição> <tool_name> <tool_input em JSON>
  local esperado="$1" descricao="$2" ferramenta="$3" entrada="$4" obtido
  jq -n --arg t "$ferramenta" --argjson i "$entrada" --arg d "$TMP" \
    '{tool_name: $t, tool_input: $i, cwd: $d}' \
    | (cd / && "$HOOK") >/dev/null 2>&1
  obtido=$?
  if [[ "$obtido" == "$esperado" ]]; then
    echo "  ok    ($esperado) $descricao"
  else
    echo "  FALHA (esperado $esperado, veio $obtido) $descricao" >&2
    falhas=$((falhas + 1))
  fi
}

SO_STATUS="${ORIGINAL/'- **Status:** Aceito'/'- **Status:** Substituído por 0010'}"
OUTRA_LINHA="${SO_STATUS/Texto da decisão./Texto alterado.}"

echo "▶ protect-files: Write em ADR Aceito"
caso 0 "caminho relativo, só troca o Status"        "$ADR_REL"      "$SO_STATUS"
caso 0 "caminho absoluto, só troca o Status"        "$TMP/$ADR_REL" "$SO_STATUS"
caso 2 "caminho relativo, altera outra linha"       "$ADR_REL"      "$OUTRA_LINHA"
caso 2 "caminho absoluto, altera outra linha"       "$TMP/$ADR_REL" "$OUTRA_LINHA"

echo "▶ protect-files: Edit"
caso_json 2 "Edit em .env"                          Edit "$(jq -n --arg p "$TMP/.env" '{file_path: $p, old_string: "A=1", new_string: "A=2"}')"
caso_json 0 "Edit em src/App.java"                  Edit "$(jq -n --arg p "$TMP/src/App.java" '{file_path: $p, old_string: "a", new_string: "b"}')"
caso_json 2 "Edit no ADR 0001 Aceito (texto)"       Edit "$(jq -n --arg p "$ADR1_REL" '{file_path: $p, old_string: "Texto da decisão.", new_string: "Outro texto."}')"
caso_json 0 "Edit só trocando o Status para Substituído por 0004" Edit \
  "$(jq -n --arg p "$ADR1_REL" '{file_path: $p, old_string: "- **Status:** Aceito", new_string: "- **Status:** Substituído por 0004"}')"

echo "▶ protect-files: Bash"
caso_json 2 "cat .env"                              Bash '{"command": "cat .env"}'
caso_json 0 "cat .env.example"                      Bash '{"command": "cat .env.example"}'
caso_json 2 "sed -i em docs/adr/0001-*.md"          Bash '{"command": "sed -i s/Aceito/Rejeitado/ docs/adr/0001-*.md"}'

if [[ $falhas -gt 0 ]]; then echo "✖ $falhas caso(s) falharam" >&2; exit 1; fi
echo "✔ todos os casos passaram"
