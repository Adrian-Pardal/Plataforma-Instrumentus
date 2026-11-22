# Eventos do harness (pesquisa)
`tail -n 20 .claude/pesquisa/eventos.jsonl` — lê o registro que os hooks gravam quando bloqueiam algo e quando uma sessão começa.

Última verificação: 2026-11-22 · Testado com: Claude Code 2.1.330 e `scripts/tests/eventos.test.sh`; comandos `jq` conferidos em arquivo de exemplo

## PARA QUE SERVE
Alimenta o protocolo da pesquisa (docs/pesquisa/protocolo.md): M4 (qual peça do harness pegou cada erro)
e M11 (início de cada sessão, com a versão do Claude Code). Cada bloqueio dos hooks `protect-files`,
`protect-push`, `protect-merge` e `stop-verify` vira UMA linha; cada início de sessão também. Sem isso, "qual
peça pegou" dependeria de memória. Decisão: ADR 0007. Plano: docs/plans/005.

O que NÃO é gravado, de propósito: conteúdo de arquivo, o comando inteiro, valores de variáveis, o remoto do
push (pode ser uma URL com credencial) e o número ou a URL do PR. Só entram o hook, um código fixo de motivo
e o alvo (caminho de arquivo ou nome de branch).

## QUANDO FAZER
- **Gravar:** nada a fazer, é automático (hooks no `.claude/settings.json`).
- **Olhar:** ao fim de cada sessão, para anotar na pesquisa o que o harness barrou.
- **Guardar:** ao fim de cada fase e antes de trocar de máquina. O arquivo está no `.gitignore`, então NÃO vai
  para o repositório e só existe na sua máquina.

## PRÉ-REQUISITOS
- `jq` instalado.
- Uma sessão do Claude Code aberta DEPOIS de os hooks entrarem no `settings.json`.
- O Claude Code aberto na pasta do projeto (os hooks usam `CLAUDE_PROJECT_DIR`).

## PASSO A PASSO
Rode os comandos na raiz do projeto.
1. Ver que o hook de início de sessão está registrado (a lista deve ter `SessionStart`).
   ```bash
   jq -c '.hooks | keys' .claude/settings.json
   ```
2. Ver os últimos eventos.
   ```bash
   tail -n 10 .claude/pesquisa/eventos.jsonl
   ```
3. Contar bloqueios por hook e motivo.
   ```bash
   jq -r 'select(.tipo=="bloqueio") | [.hook,.motivo] | @tsv' .claude/pesquisa/eventos.jsonl | sort | uniq -c | sort -rn
   ```
4. Listar as sessões (data, versão do Claude Code, branch).
   ```bash
   jq -r 'select(.tipo=="sessao") | [.quando,.versao,.branch] | @tsv' .claude/pesquisa/eventos.jsonl
   ```
5. Guardar uma cópia fora do repositório (troque a data).
   ```bash
   cp .claude/pesquisa/eventos.jsonl ~/pesquisa-instrumentus/eventos-AAAA-MM-DD.jsonl
   ```

## COMO CONFERIR QUE DEU CERTO
1. Depois de abrir uma sessão nova, o arquivo existe e tem uma linha `"tipo":"sessao"` com a versão e a branch:
   ```bash
   ls -la .claude/pesquisa && tail -n 1 .claude/pesquisa/eventos.jsonl
   ```
2. Todas as linhas são JSON válido (sem saída de erro e com o `ok` no fim):
   ```bash
   jq -e . .claude/pesquisa/eventos.jsonl >/dev/null && echo ok
   ```
3. Provocar um bloqueio de mentira SEM tocar no arquivo real (o evento vai para uma pasta temporária).
   Esperado: a mensagem do hook, `código de saída: 2` e uma linha com `"motivo":"arquivo-sensivel"`.
   ```bash
   D=$(mktemp -d)
   echo '{"tool_name":"Write","tool_input":{"file_path":".env","content":"x"},"cwd":"/"}' | CLAUDE_PROJECT_DIR="$D" .claude/hooks/protect-files.sh; echo "código de saída: $?"
   cat "$D/.claude/pesquisa/eventos.jsonl"
   ```

## CÓDIGOS DE MOTIVO
O campo `motivo` é sempre um destes códigos (nunca o texto da mensagem do hook).

| Hook | Códigos |
|------|---------|
| protect-files | `arquivo-sensivel`, `adr-aceito`, `bash-leitura-segredo`, `bash-escrita-sensivel`, `bash-escrita-adr-aceito`, `entrada-invalida` |
| protect-push | `push-forcado`, `push-opcao-destrutiva`, `push-opcao-proibida`, `push-delete`, `remoto-nao-permitido`, `destino-nao-permitido`, `entrada-invalida` |
| protect-merge | `merge-por-api`, `merge-admin`, `merge-auto`, `merge-squash-ou-rebase`, `opcao-desconhecida`, `sem-merge-commit`, `consulta-pr-falhou`, `base-nao-permitida`, `forma-nao-canonica`, `alias-set-import`, `prefixo-gh-repo-host`, `expansao-no-comando`, `entrada-invalida` |
| stop-verify | `testes-falharam`, `verify-ausente`, `raiz-desconhecida`, `entrada-invalida` |

Sem `jq` instalado, os hooks continuam bloqueando, mas não conseguem gravar o evento.

## SE DER ERRADO
- **O arquivo não aparece:** a sessão é anterior à mudança do `settings.json` (abra uma sessão nova), ou o
  `jq` não está instalado, ou a pasta `.claude/pesquisa` não aceita escrita. A gravação é silenciosa por
  desenho: nunca atrapalha o hook, então ela também não avisa quando falha.
- **Linha que não é JSON:** o passo "todas as linhas são JSON válido" aponta o problema. Guarde o arquivo e
  me avise; pode ser disco cheio no meio da gravação.
- **Evento com alvo `x` ou de teste:** não deveria existir (o `verify.sh` roda os testes sem
  `CLAUDE_PROJECT_DIR`). Se aparecer, é bug: registre com `/registrar-erro`.
- **Parar de registrar:** tire o bloco `SessionStart` do `.claude/settings.json`. Os hooks de bloqueio seguem
  bloqueando igual; se a lib `.claude/hooks/lib/eventos.sh` faltar, eles só deixam de registrar.
- **Apagar os dados:** `rm .claude/pesquisa/eventos.jsonl`. Cuidado: são dados da pesquisa e não voltam.

## VER TAMBÉM
- docs/pesquisa/protocolo.md (métricas M4 e M11)
- docs/adr/0007-registro-de-dados-para-pesquisa.md e docs/plans/005-registro-de-eventos-do-harness.md
- docs/help/ferramentas/telemetria.md (outra fonte da pesquisa: tokens e tempo)
- docs/help/ferramentas/testes-dos-hooks.md (como rodar os testes dos hooks)
