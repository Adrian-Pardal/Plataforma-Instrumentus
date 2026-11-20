#!/usr/bin/env bash
# config.test.sh — valida os arquivos de configuração do harness:
#   · .claude/settings.json e .mcp.json são JSON válido (jq);
#   · lefthook.yml é válido ("lefthook validate", se o lefthook estiver instalado);
#   · todo SKILL.md e todo .claude/agents/*.md tem frontmatter com name e description;
#   · skills "manual" do docs/skills.md têm disable-model-invocation: true; as "automática" não.
# Uso: scripts/tests/config.test.sh   (sai com 1 se algum caso falhar)
set -uo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
falhas=0

confere() {   # confere <descrição> <0 se passou | outro valor se falhou>
  if [[ "$2" == 0 ]]; then
    echo "  ok    $1"
  else
    echo "  FALHA $1" >&2
    falhas=$((falhas + 1))
  fi
}

# Imprime só o frontmatter (entre o 1º e o 2º "---"); vazio se o arquivo não começa com "---"
# ou se falta o "---" de fechamento (senão o corpo do arquivo seria lido como frontmatter).
frontmatter() {
  awk 'NR == 1 { if ($0 != "---") exit; next }
       $0 == "---" { fechou = 1; exit }
       { buf = buf $0 "\n" }
       END { if (fechou) printf "%s", buf }' "$1"
}

echo "▶ config: o parser de frontmatter"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
printf -- '---\nname: x\ndescription: y\n' > "$TMP/aberto.md"
[[ -z "$(frontmatter "$TMP/aberto.md")" ]]; confere "sem o --- de fechamento, o frontmatter vem vazio" "$?"
printf -- '---\nname: x\ndescription: y\n---\ncorpo\n' > "$TMP/ok.md"
[[ "$(frontmatter "$TMP/ok.md")" == $'name: x\ndescription: y' ]]; confere "com fechamento, devolve só o bloco" "$?"

echo "▶ config: JSON"
jq empty "$RAIZ/.claude/settings.json" >/dev/null 2>&1; confere ".claude/settings.json é JSON válido" "$?"
jq empty "$RAIZ/.mcp.json" >/dev/null 2>&1;             confere ".mcp.json é JSON válido" "$?"

echo "▶ config: lefthook.yml"
# DEBT-001: o CI não instala o lefthook, então esta parte é pulada lá.
if command -v lefthook >/dev/null; then
  (cd "$RAIZ" && lefthook validate) >/dev/null 2>&1; confere "lefthook validate aceita o lefthook.yml" "$?"
else
  echo "  • lefthook não instalado: validação pulada"
fi

echo "▶ config: frontmatter de skills e subagentes"
arquivos=("$RAIZ"/.claude/skills/*/SKILL.md "$RAIZ"/.claude/agents/*.md)
for arq in "${arquivos[@]}"; do
  rotulo="${arq#"$RAIZ"/}"
  if [[ ! -f "$arq" ]]; then
    confere "$rotulo existe" 1
    continue
  fi
  fm="$(frontmatter "$arq")"
  grep -qE '^name: .+' <<<"$fm";        confere "$rotulo tem name" "$?"
  grep -qE '^description: .+' <<<"$fm"; confere "$rotulo tem description" "$?"
done

echo "▶ config: skills manuais x automáticas (docs/skills.md)"
manuais=0
automaticas=0
while IFS='|' read -r _ col_skill _ col_tipo _; do
  tipo="$(xargs <<<"$col_tipo")"
  [[ "$tipo" == "manual" || "$tipo" == "automática" ]] || continue
  nome="$(sed -E 's/^ *\[([^]]+)\].*/\1/' <<<"$col_skill")"
  arq="$RAIZ/.claude/skills/$nome/SKILL.md"
  if [[ ! -f "$arq" ]]; then
    confere "skill $nome listada em docs/skills.md tem SKILL.md" 1
    continue
  fi
  if [[ "$tipo" == "manual" ]]; then
    manuais=$((manuais + 1))
    frontmatter "$arq" | grep -qE '^disable-model-invocation: true$'
    confere "skill manual $nome tem disable-model-invocation: true" "$?"
  else
    automaticas=$((automaticas + 1))
    ! frontmatter "$arq" | grep -qE '^disable-model-invocation:'
    confere "skill automática $nome não tem disable-model-invocation" "$?"
  fi
done < "$RAIZ/docs/skills.md"
# Trava: se o formato da tabela mudar e o parser não achar nada, o teste não pode passar em silêncio.
[[ $manuais -gt 0 ]];     confere "achou skills manuais na tabela ($manuais)" "$?"
[[ $automaticas -gt 0 ]]; confere "achou skills automáticas na tabela ($automaticas)" "$?"

if [[ $falhas -gt 0 ]]; then echo "✖ $falhas caso(s) falharam" >&2; exit 1; fi
echo "✔ todos os casos passaram"
