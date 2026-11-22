# Plano: registro de eventos do harness para a pesquisa

- **Spec:** nenhuma. Fonte dos requisitos: ADR 0007 e o pedido do dono em 2026-11-22. Exceção autorizada pelo
  dono (a skill `planejar` exige spec Aprovada).
- **Status:** Concluído (aprovado pelo dono em 2026-11-22; 8 tasks feitas e verificadas pelo dono)
- **Data:** 2026-11-22

## Visão técnica
Os 4 hooks já têm um único ponto de saída para bloqueio (`bloquear`/`falhar`, `exit 2`). Uma lib nova,
`.claude/hooks/lib/eventos.sh`, oferece `registrar_evento`, que acrescenta UMA linha JSON a
`.claude/pesquisa/eventos.jsonl` (JSON montado com `jq -n`, nunca por concatenação de texto). Cada hook
chama a função dentro do seu ponto de saída, ANTES do `exit 2`, e nada mais muda. Um hook novo,
`session-start.sh`, grava a linha de início de sessão. Serve ao QP2 (qual peça do harness pegou o erro, M4)
e ao M11 do protocolo.

Formato (uma linha por evento, chaves em português):
- bloqueio: `{"quando":"2026-11-22T14:30:00Z","tipo":"bloqueio","hook":"protect-files","motivo":"adr-aceito","alvo":"docs/adr/0003-x.md"}`
- sessão: `{"quando":"...","tipo":"sessao","hook":"session-start","versao":"2.1.x (Claude Code)","branch":"docs/estudo-de-caso"}`

Decisões:
- **Motivo é um código fixo** (ex.: `adr-aceito`, `push-forcado`, `testes-falharam`), não o texto da mensagem:
  a mensagem pode conter trechos do comando, e o dono pediu nunca gravar conteúdo.
- **Alvo** é só caminho (protect-files), branch de destino (protect-push), branch de base do PR (protect-merge)
  ou branch atual (stop-verify); vazio quando não se sabe. Truncado em 200 caracteres.
- **Melhor esforço:** a função nunca falha: erros de gravação são silenciados e o código de saída do hook não
  depende dela. Se a lib não existir, o hook usa uma função vazia e bloqueia igual.
- **Só grava com `CLAUDE_PROJECT_DIR` definida** (numa sessão real ela aponta para o projeto). Sem ela, não grava.
- **Atenção ao poluir dados:** o hook Stop roda `verify.sh test` com `CLAUDE_PROJECT_DIR` definida, e os testes dos
  hooks gravariam no arquivo real. `verify.sh` passa a rodar os testes dos scripts sem essa variável.
- **Linhas curtas** (< 4 KB): o acréscimo (`>>`) de linha curta é seguro mesmo com hooks rodando em paralelo.
- **SessionStart:** não imprime nada (stdout vira contexto do Claude), roda rápido (`timeout` de 5 s no
  `claude --version`), e se faltar `claude` ou `git` grava "desconhecida".
- **Branch:** o dono manteve tudo na `docs/estudo-de-caso`.

## Modelo de dados
Arquivo `.claude/pesquisa/eventos.jsonl` (no .gitignore; dados privados, ver ADR 0007). Esquema acima.

## Interfaces
- `registrar_evento <tipo> <hook> <motivo> <alvo>` em `lib/eventos.sh` (diretiva `# shellcheck shell=bash`,
  exigida pelo verify.sh para libs). Para `tipo=sessao`, o 3º e o 4º argumentos são versão e branch.
- `.claude/settings.json`: novo `SessionStart` chamando `session-start.sh` (matcher `startup|resume|clear|compact`).
- `.gitignore`: `.claude/pesquisa/`.

## Decisões
- Não é decisão de arquitetura nova: segue o ADR 0007 (registro de dados para pesquisa).

## Riscos
- Gravar conteúdo sensível por engano → só códigos fixos + alvo truncado; teste com "segredo" no conteúdo e
  no valor de variável, provando que não aparece no arquivo.
- Mudar a lógica de bloqueio sem querer → testes existentes rodam SEM edição; casos novos conferem o mesmo
  código de saída e o mesmo stderr de antes.
- Hook lento atrasa a sessão → SessionStart com `timeout`; teste de duração com `claude` ausente.
- Concorrência (hooks em paralelo) → linha única e curta com `>>`.
- Arquivo ignorado pelo Git é perdido ao trocar de máquina → copiar derivados para docs/estudo-de-caso/dados/.

## Critérios de aceite (CA)
- CA-1: cada bloqueio dos 4 hooks acrescenta UMA linha JSON válida com quando (UTC), hook, motivo, alvo.
- CA-2: motivo é código fixo; alvo é caminho ou branch (≤ 200 caracteres); nunca conteúdo de arquivo, comando
  inteiro nem valor de variável.
- CA-3: a lógica de bloqueio não muda: mesmos códigos de saída e mesmo stderr; testes existentes passam sem edição.
- CA-4: falha ao gravar nunca muda o código de saída nem imprime algo.
- CA-5: sem `CLAUDE_PROJECT_DIR` nada é gravado; `verify.sh` remove a variável dos testes dos scripts.
- CA-6: SessionStart grava quando, versão e branch; stdout vazio; sem `claude` ou `git` grava "desconhecida".
- CA-7: `.claude/pesquisa/` está no .gitignore.
- CA-8: página em docs/help e o protocolo (M4) apontam para o arquivo de eventos.

## Tasks
Marque com 🎓 as tasks que você faz à mão. TDD: teste vermelho, depois código.

- [x] T1 [ambos] — lib `eventos.sh` com `registrar_evento` · Cobre: CA-1, CA-2, CA-4 · Teste: `scripts/tests/eventos.test.sh` (JSON válido, escape de aspas e quebra de linha, truncamento, sem variável não grava, pasta sem permissão não falha, nada em stdout/stderr)
- [x] T2 [ambos] — `verify.sh` roda os testes dos scripts sem `CLAUDE_PROJECT_DIR` · Cobre: CA-5 · Teste: caso novo em `scripts/tests/verify.test.sh`
- [x] T3 [ambos] — protect-files grava o evento nos bloqueios · Cobre: CA-1, CA-2, CA-3 · Teste: `eventos.test.sh` (casos por motivo; permitido não grava; conteúdo e valor de variável não aparecem)
- [x] T4 [ambos] — protect-push grava o evento · Cobre: CA-1, CA-2, CA-3 · Teste: `eventos.test.sh`
- [x] T5 [ambos] — protect-merge grava o evento · Cobre: CA-1, CA-2, CA-3 · Teste: `eventos.test.sh`
- [x] T6 [ambos] — stop-verify grava o evento (testes falharam e falhas internas) · Cobre: CA-1, CA-2, CA-3 · Teste: `eventos.test.sh`
- [x] T7 [ambos] — `session-start.sh` + entrada no settings.json · Cobre: CA-6 · Teste: `eventos.test.sh` (stdout vazio; versão e branch; `claude` ausente; fora de repositório git) e `config.test.sh` (hook registrado)
- [x] T8 [ambos] — `.gitignore` e documentação (help, protocolo M4) · Cobre: CA-7, CA-8 · Teste: caso em `config.test.sh` (.gitignore contém a pasta)

## Rastreabilidade
| Requisito | Critério | Task | Teste |
|-----------|----------|------|-------|
| Pedido/ADR 0007 | CA-1 | T1, T3–T6 | eventos.test.sh |
| Pedido/ADR 0007 | CA-2 | T1, T3–T6 | eventos.test.sh |
| Pedido | CA-3 | T3–T6 | testes existentes + eventos.test.sh |
| Pedido | CA-4 | T1 | eventos.test.sh |
| Pedido | CA-5 | T1, T2 | eventos.test.sh, verify.test.sh |
| Pedido | CA-6 | T7 | eventos.test.sh |
| Pedido | CA-7 | T8 | config.test.sh |
| CLAUDE.md §6 | CA-8 | T8 | revisão (/revisar) |

## Perguntas em aberto
- O `claude --version` funciona de dentro de um hook (PATH do hook)? Conferir na T7, antes de afirmar.
- Gravar também o `source` do SessionStart (startup, resume, clear)? Não foi pedido; fica de fora.
