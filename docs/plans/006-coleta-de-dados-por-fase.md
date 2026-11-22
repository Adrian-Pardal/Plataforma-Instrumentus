# Plano: coleta de dados por fase da pesquisa

- **Spec:** nenhuma. Fonte dos requisitos: o pedido do dono em 2026-11-22, o ADR 0007 e o protocolo
  (docs/pesquisa/protocolo.md). Exceção autorizada pelo dono (a skill `planejar` exige spec Aprovada).
- **Status:** Aprovado (dono, 2026-11-22)
- **Data:** 2026-11-22

## Visão técnica
Um script bash, `scripts/pesquisa/coletar-fase.sh`, que lê as fontes da pesquisa e grava UM csv por fase.
Usa só `git`, `gh`, `jq` e `awk`; NENHUMA IA é chamada (o teste prova com um `claude` falso).

Uso: `scripts/pesquisa/coletar-fase.sh "<nome da fase>" <AAAA-MM-DD início> <AAAA-MM-DD fim>`
Saída: `docs/pesquisa/dados/<nome em minúsculas com hífen>.csv` ("Fase 1" gera `fase-1.csv`). Rodar de novo
sobrescreve (o csv é derivado).

Formato (csv longo, uma linha por número): `fase,inicio,fim,metrica,detalhe,valor,nota`

| metrica | detalhe | fonte |
|---------|---------|-------|
| commits | total | `git rev-list --count` do HEAD no intervalo |
| ci | total, `<workflow>/<conclusão>` (sem conclusão: `em-andamento`) | `gh run list --created A..B` |
| err | bug, erro-ia, ambiente, producao (e outras que existirem) | `data:` e `categoria:` de docs/erros/ERR-*.md |
| intervencoes | os 6 tipos do protocolo, `indefinido` (`?`), total, sessoes-lidas | tabela "Intervenções humanas" de docs/pesquisa/sessoes/*.md do intervalo |
| bloqueios | um por hook (protect-files, protect-push, protect-merge, stop-verify e outros) | .claude/pesquisa/eventos.jsonl |

Decisões:
- **Dado que não existe fica VAZIO, nunca 0**, e a coluna `nota` diz por quê. Vale para: `gh` indisponível,
  sem registros de sessão no período, arquivo de eventos ausente, e intervalo que termina antes do primeiro
  evento (nota "eventos só existem desde AAAA-MM-DD"). Se o intervalo começa antes mas termina depois do
  primeiro evento, as contagens saem com uma linha `bloqueios,cobertura` avisando que são parciais.
- **Intervalo fechado e em UTC** (`git --since/--until` e `gh --created` aceitam UTC). ERR e sessões são
  comparados pela data escrita neles.
- **Commits do HEAD** (branch atual), não de todas as branches: evita contar branches de bot.
- **Falha do `gh` não derruba a coleta:** o csv sai com a nota e um aviso no stderr (exit 0). Argumento
  faltando, data inválida ou início depois do fim: exit 2 com a mensagem de uso.
- Só números e nomes de hook/categoria/tipo no csv: nada de conteúdo de conversa (ADR 0007).
- `COLETA_RAIZ` troca a raiz do projeto (só os testes usam), como `VERIFY_RAIZ` no verify.sh.

## Modelo de dados
O csv acima. Nenhuma tabela nova.

## Interfaces
- Linha de comando acima; códigos de saída 0 (csv gravado) e 2 (uso incorreto ou ferramenta faltando).
- `scripts/verify.sh`: o shellcheck do modo full passa a olhar também `scripts/*/*.sh`.

## Decisões
- Não é decisão de arquitetura nova: segue o ADR 0007.

## Riscos
- Contar como zero o que é falta de dado → regra do vazio + nota, com teste para cada fonte ausente.
- Formato da tabela de intervenções mudar (a skill /handoff a gera) → teste com a tabela no formato da
  skill; tipo desconhecido vira `indefinido`, não some.
- `gh` sem rede ou sem login → nota e aviso; os testes usam `gh` falso e nunca chamam a rede.
- Fuso horário nas bordas do intervalo → UTC documentado e teste das duas bordas.
- Limite de 1000 execuções do `gh run list` → nota quando atingido.

## Critérios de aceite (CA)
- CA-1: gera `docs/pesquisa/dados/<slug>.csv` com o cabeçalho e as 5 métricas acima, e rodar de novo dá o mesmo arquivo.
- CA-2: os números batem com as fontes (intervalo fechado nas duas bordas, fora do intervalo não conta).
- CA-3: fonte ausente gera valor vazio e nota, nunca 0.
- CA-4: argumento inválido dá exit 2 com a mensagem de uso e não grava nada.
- CA-5: nenhuma IA é chamada.
- CA-6: o shellcheck do `verify.sh full` cobre `scripts/pesquisa/`.
- CA-7: página em docs/help e o protocolo apontam para o script.
- CA-8: teste real com a Fase 1.

## Tasks
Marque com 🎓 as tasks que você faz à mão. TDD: teste vermelho, depois código.

- [x] T1 [ambos] — argumentos, nome do arquivo, csv e `commits` · Cobre: CA-1, CA-2, CA-4 · Teste: `scripts/tests/coletar-fase.test.sh`
- [x] T2 [ambos] — `ci` via gh, incluindo a falha do gh · Cobre: CA-2, CA-3 · Teste: `coletar-fase.test.sh`
- [x] T3 [ambos] — `err` por categoria · Cobre: CA-2, CA-3 · Teste: `coletar-fase.test.sh`
- [x] T4 [ambos] — `intervencoes` das sessões · Cobre: CA-2, CA-3 · Teste: `coletar-fase.test.sh`
- [x] T5 [ambos] — `bloqueios` por hook e nota de cobertura; sem IA · Cobre: CA-2, CA-3, CA-5 · Teste: `coletar-fase.test.sh`
- [x] T6 [ambos] — `verify.sh` confere `scripts/*/*.sh` com shellcheck · Cobre: CA-6 · Teste: caso novo em `scripts/tests/verify.test.sh`
- [x] T7 [ambos] — página de help, índice e protocolo §5 · Cobre: CA-7 · Teste: caso em `config.test.sh` (a página existe e o help a lista)
- [ ] T8 [ambos] — teste real com a Fase 1 · Cobre: CA-8 · Teste: execução real, saída mostrada

## Rastreabilidade
| Requisito | Critério | Task | Teste |
|-----------|----------|------|-------|
| Pedido | CA-1 | T1–T5 | coletar-fase.test.sh |
| Pedido | CA-2 | T1–T5 | coletar-fase.test.sh |
| Protocolo (retrospectivo) | CA-3 | T2–T5 | coletar-fase.test.sh |
| Pedido | CA-4 | T1 | coletar-fase.test.sh |
| Pedido (sem IA) | CA-5 | T5 | coletar-fase.test.sh |
| CLAUDE.md §4 | CA-6 | T6 | verify.test.sh |
| CLAUDE.md §6 | CA-7 | T7 | config.test.sh |
| Pedido | CA-8 | T8 | execução real |

## Perguntas em aberto
- Intervalo de datas da Fase 1: o dono ainda não informou. Candidato: 2026-10-25 a 2026-10-28 (primeiro bloco de commits).
- Fuso (achado na T8): o corte em UTC dá 53 commits para 2026-10-25 a 2026-10-28, contra 59 pela data local
  (UTC-3). Seis commits feitos entre 21:01 e 21:56 do dia 28 caem no dia 29 em UTC. Decidir com o dono se o
  intervalo passa a ser o dia local (convertido para UTC uma vez, para commits, CI e bloqueios).
- Quebrar `commits` por tipo Conventional (feat, fix, docs)? Não foi pedido; fica de fora.
