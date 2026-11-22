# shellcheck shell=bash
# eventos.sh — registro de eventos do harness para a pesquisa (plano 005, ADR 0007).
# Uso (dentro de um hook):  source eventos.sh  e depois
#   registrar_evento bloqueio <hook> <motivo> <alvo>     (motivo = código fixo; alvo = caminho ou branch)
#   registrar_evento sessao   <hook> <versao> <branch>
# Acrescenta UMA linha JSON a $CLAUDE_PROJECT_DIR/.claude/pesquisa/eventos.jsonl.
# Regras que não mudam:
#   - melhor esforço: NUNCA imprime nada e SEMPRE devolve 0, para não alterar o código de saída do hook;
#   - sem CLAUDE_PROJECT_DIR (ou com ela apontando para uma pasta que não existe) não grava, e não cria a pasta
#     (assim os testes não poluem o arquivo real);
#   - só guarda códigos e nomes (caminho ou branch, até 200 caracteres): nunca conteúdo de arquivo nem
#     valor de variável. O JSON é montado pelo jq, que escapa aspas e quebras de linha.

registrar_evento() {
  local tipo="${1:-}" hook="${2:-}" campo_a="${3:-}" campo_b="${4:-}"
  local pasta="${CLAUDE_PROJECT_DIR:-}" quando linha
  [[ -n "$pasta" && -d "$pasta" ]] || return 0   # pasta inexistente: não a cria (o mkdir -p criaria)
  command -v jq >/dev/null 2>&1 || return 0
  quando=$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null) || return 0
  campo_a="${campo_a:0:200}"
  campo_b="${campo_b:0:200}"
  case "$tipo" in
    bloqueio)
      linha=$(jq -cn --arg q "$quando" --arg h "$hook" --arg m "$campo_a" --arg a "$campo_b" \
        '{quando: $q, tipo: "bloqueio", hook: $h, motivo: $m, alvo: $a}' 2>/dev/null) || return 0 ;;
    sessao)
      linha=$(jq -cn --arg q "$quando" --arg h "$hook" --arg v "$campo_a" --arg b "$campo_b" \
        '{quando: $q, tipo: "sessao", hook: $h, versao: $v, branch: $b}' 2>/dev/null) || return 0 ;;
    *) return 0 ;;
  esac
  [[ -n "$linha" ]] || return 0
  { mkdir -p "$pasta/.claude/pesquisa" && printf '%s\n' "$linha" >> "$pasta/.claude/pesquisa/eventos.jsonl"; } 2>/dev/null
  return 0
}
