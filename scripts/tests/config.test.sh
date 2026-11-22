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

# Imprime cada comando de envio que algum "allow" do arquivo libera. O padrão do allow é lido como glob do
# bash ("*" casa qualquer coisa), então "Bash(*)", "Bash(curl*)" e "Bash(c* *)" são pegos. "$cmd x" cobre o
# padrão com argumento ("curl *").
ENVIO=(curl wget nc ncat netcat telnet ssh scp sftp rsync "npm publish" "gh gist")
allow_libera_envio() {   # allow_libera_envio <settings.json>
  local regra padrao cmd
  while IFS= read -r regra; do
    if   [[ "$regra" == "Bash" ]];      then padrao='*'
    elif [[ "$regra" == "Bash("*")" ]]; then padrao="${regra#Bash(}"; padrao="${padrao%)}"
    else continue; fi
    for cmd in "${ENVIO[@]}"; do
      # shellcheck disable=SC2053  # glob de propósito: o padrão fica sem aspas
      if [[ "$cmd" == $padrao || "$cmd x" == $padrao ]]; then echo "$cmd"; fi
    done
  done < <(jq -r '.permissions.allow[]' "$1")
}

echo "▶ config: proteção do agente (plano 004)"
# Comandos que enviam dados para fora pedem confirmação (permissions.ask do settings.json). Cada um nas duas
# formas, "Bash(x)" e "Bash(x *)": não está confirmado que "x *" casa "x" sem argumentos.
for cmd in curl wget nc ncat netcat telnet ssh scp sftp rsync "npm publish" "gh gist"; do
  for regra in "Bash($cmd)" "Bash($cmd *)"; do
    jq -e --arg r "$regra" '.permissions.ask | index($r) != null' "$RAIZ/.claude/settings.json" >/dev/null 2>&1
    confere "settings.json pede confirmação para $regra" "$?"
  done
  # Um "allow" desses comandos anularia o espírito da regra (o ask vence, mas não deve haver o conflito).
  jq -e --arg c "$cmd" '[.permissions.allow[] | select(. == "Bash(" + $c + ")" or startswith("Bash(" + $c + " "))] | length == 0' \
    "$RAIZ/.claude/settings.json" >/dev/null 2>&1
  confere "settings.json não libera '$cmd' em allow" "$?"
done

for amplo in 'Bash(*)' 'Bash' 'Bash(curl*)' 'Bash(c* *)'; do
  jq -n --arg r "$amplo" '{permissions: {allow: [$r]}}' > "$TMP/amplo.json"
  [[ -n "$(allow_libera_envio "$TMP/amplo.json")" ]]; confere "allow amplo '$amplo' é pego pelo teste" "$?"
done
printf '{"permissions":{"allow":["Bash(git status *)"]}}' > "$TMP/estreito.json"
[[ -z "$(allow_libera_envio "$TMP/estreito.json")" ]]; confere "allow estreito (git status) não é pego" "$?"
[[ -z "$(allow_libera_envio "$RAIZ/.claude/settings.json")" ]]; confere "settings.json não tem allow que cubra comando de envio" "$?"

AGENTE="$RAIZ/docs/seguranca/agente.md"
[[ -f "$AGENTE" ]]; confere "docs/seguranca/agente.md existe" "$?"
for secao in "## Riscos" "## Defesas" "## Limites" "## Servidores MCP aprovados"; do
  grep -qxF "$secao" "$AGENTE" 2>/dev/null; confere "agente.md tem a seção '$secao'" "$?"
done

# A lista de servidores MCP aprovados é a seção "Servidores MCP aprovados" do agente.md.
aprovados="$(awk '/^## Servidores MCP aprovados/ {f = 1; next} /^## / {f = 0} f' "$AGENTE" 2>/dev/null)"
servidores=0
while IFS= read -r servidor; do
  servidores=$((servidores + 1))
  grep -qF "\`$servidor\`" <<<"$aprovados"; confere "servidor MCP '$servidor' do .mcp.json está aprovado em agente.md" "$?"
done < <(jq -r '.mcpServers | keys[]' "$RAIZ/.mcp.json")
[[ $servidores -gt 0 ]]; confere "achou servidores no .mcp.json ($servidores)" "$?"
# O settings.json só libera (allow) ferramentas de servidor MCP aprovado.
while IFS= read -r nome; do
  grep -qF "\`$nome\`" <<<"$aprovados"; confere "allow de mcp__${nome}__* é de servidor aprovado" "$?"
done < <(jq -r '.permissions.allow[] | select(startswith("mcp__")) | split("__")[1]' "$RAIZ/.claude/settings.json")

if [[ $falhas -gt 0 ]]; then echo "✖ $falhas caso(s) falharam" >&2; exit 1; fi
echo "✔ todos os casos passaram"
