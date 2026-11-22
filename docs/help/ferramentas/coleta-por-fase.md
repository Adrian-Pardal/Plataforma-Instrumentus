# Coleta de dados por fase
`scripts/pesquisa/coletar-fase.sh "Fase 1" 2026-10-25 2026-10-28` — gera o csv com os números de uma fase da pesquisa, sem chamar nenhuma IA.

Última verificação: 2026-11-22 · Testado com: `scripts/tests/coletar-fase.test.sh` (com `gh` e `claude` falsos) e uma execução real com as datas candidatas da Fase 1

## PARA QUE SERVE
Reúne num só arquivo, por fase, os números que o protocolo pede (docs/pesquisa/protocolo.md): commits (M13),
execuções de CI (M7), erros por categoria (M3), intervenções humanas (M1) e bloqueios por hook (M4). Sem
ele, esses números ficam espalhados no Git, no `gh`, em docs/erros, nos registros de sessão e nos eventos dos hooks.

## QUANDO FAZER
- Ao fim de cada fase da pesquisa.
- De novo, se você corrigir um registro do período (um ERR ou uma sessão): o csv é derivado e pode ser refeito.
- Antes, rode `/handoff` nas últimas sessões da fase, para o registro de cada uma existir.

## PRÉ-REQUISITOS
- `git`, `jq` e `awk` instalados.
- `gh` instalado e logado (`gh auth status`), só para a parte do CI. Sem ele o csv sai, com o CI sem valor.
- Estar na branch que contém o trabalho da fase: os commits são contados a partir do `HEAD`.

## PASSO A PASSO
1. Rodar com o nome da fase e o intervalo (datas no formato AAAA-MM-DD, as duas pontas incluídas).
   ```bash
   scripts/pesquisa/coletar-fase.sh "Fase 1" 2026-10-25 2026-10-28
   ```
   O nome vira o nome do arquivo: `docs/pesquisa/dados/fase-1.csv` (minúsculas, sem acento, hífen no lugar de espaço).
2. Ler o resultado.
   ```bash
   cat docs/pesquisa/dados/fase-1.csv
   ```
3. Ver só uma métrica (a 4ª coluna é a métrica).
   ```bash
   awk -F, '$4=="err"' docs/pesquisa/dados/fase-1.csv
   ```

## COMO LER O CSV
Colunas: `fase,inicio,fim,metrica,detalhe,valor,nota`. Uma linha por número.

| metrica | detalhe | de onde vem |
|---------|---------|-------------|
| commits | total | `git`, branch atual |
| ci | total e `<workflow>/<resultado>` (sem resultado: `em-andamento`) | `gh run list` |
| err | bug, erro-ia, ambiente, producao (e outras que existirem), `sem-data-ou-categoria` | `data:` e `categoria:` de docs/erros/ERR-*.md |
| intervencoes | decisao, aprovacao, correcao, operacao-manual, desbloqueio, aprendizado, indefinido, total, sessoes-lidas, `sessoes-sem-tabela` | tabela "Intervenções humanas" de docs/pesquisa/sessoes/ |
| bloqueios | protect-files, protect-push, protect-merge, stop-verify (e outros), `cobertura` | .claude/pesquisa/eventos.jsonl |

**Valor vazio não é zero.** Quando a fonte não existe, o `valor` fica vazio e a `nota` explica o porquê
("sem registros de sessão no período", "arquivo de eventos ausente", "eventos só existem desde AAAA-MM-DD",
"gh indisponível ou sem acesso"). Zero só aparece quando a fonte existe e não achou nada. Para fases
anteriores a 2026-11-22, intervenções e bloqueios saem vazios: o protocolo não reconstrói o retrospectivo.

**O intervalo é em UTC** para commits, CI e bloqueios. Num fuso como UTC-3, um commit das 21:30 do último dia
do intervalo cai no dia seguinte em UTC e fica de fora. ERR e sessões são comparados pela data escrita neles
(a sua, local). Se um número parecer menor que o esperado, confira primeiro isso.

## COMO CONFERIR QUE DEU CERTO
1. A saída termina com `✔ gravado: docs/pesquisa/dados/fase-1.csv` e o código de saída é 0.
2. Os commits batem com o Git (troque as datas):
   ```bash
   git rev-list --count --since=2026-10-25T00:00:00Z --until=2026-10-28T23:59:59Z HEAD
   ```
3. As execuções de CI batem com o `gh`:
   ```bash
   gh run list --created "2026-10-25..2026-10-28" --limit 1000 --json databaseId | jq length
   ```
4. Os testes do script passam:
   ```bash
   scripts/tests/coletar-fase.test.sh
   ```

## SE DER ERRADO
- **Código de saída 2 e mensagem de uso:** faltou argumento, a data não existe ou o início vem depois do fim.
- **`ci` sem valor, nota "gh indisponível":** rode `gh auth status`; sem rede ou sem login o `gh` não responde.
  Corrija e rode de novo.
- **`ci` com a nota de limite de 1000 execuções:** a fase tem mais execuções do que o `gh` devolve; divida o intervalo.
- **Número diferente do esperado:** confira o fuso (UTC, acima) e a branch em que você está.
- **CSV errado ou desatualizado:** não edite à mão. Corrija a fonte (ERR, sessão) e rode de novo: o arquivo é sobrescrito.
- **Privacidade:** o csv só tem contagens e nomes de hook, categoria e tipo; pode ir para o Git (docs/pesquisa/dados/).
  Os eventos brutos (`.claude/pesquisa/eventos.jsonl`) NUNCA vão.

## VER TAMBÉM
- docs/pesquisa/protocolo.md (métricas) e docs/plans/006-coleta-de-dados-por-fase.md
- docs/help/ferramentas/eventos-do-harness.md (de onde vêm os bloqueios)
- docs/help/ferramentas/telemetria.md (tokens e tempo, que este csv não cobre)
- skill `/handoff` (gera os registros de sessão lidos aqui)
