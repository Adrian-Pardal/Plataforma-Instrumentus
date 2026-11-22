---
titulo: Protocolo do estudo de caso: Plataforma Instrumentus feita com IA
proposito: Definir, antes de coletar, o que se quer saber, o que se mede e de onde vem cada número.
status: rascunho
atualizado: 2026-11-22
mantido-por: manual
relacionados: [ADR-0007, ADR-0001, ../erros/README.md, ../handoff/README.md]
---

# Protocolo do estudo de caso: Plataforma Instrumentus feita com IA

## 1. Objeto e método
Estudo de caso único, descritivo: o desenvolvimento da Plataforma Instrumentus
por um operador (estudante) trabalhando quase todo com Claude Code, sob um
harness (CLAUDE.md, hooks, skills, subagentes, CI, scripts/verify.sh).
Não há grupo de controle: os resultados descrevem este caso, não generalizam.

## 2. Questões de pesquisa
| ID | Questão |
|----|---------|
| QP1 | Que proporção do trabalho foi feita pela IA e que proporção pelo operador? |
| QP2 | Que erros a IA cometeu e qual peça do harness pegou cada um (ou nenhuma)? |
| QP3 | Como a qualidade do produto e do processo evolui ao longo das fases? |
| QP4 | Quanto custou, em tokens e em tempo? |
| QP5 | O que o operador aprendeu e como isso mudou o que ele precisa fazer? |

## 3. Taxonomia de intervenção humana
Cada intervenção do operador recebe UM tipo (o predominante).
Exemplos marcados "ilustrativo" devem ser trocados por casos reais ao coletar.

| Tipo | Definição | Exemplo |
|------|-----------|---------|
| Decisão | O operador escolhe entre alternativas que a IA apresentou ou que só ele pode escolher. | Escolher merge commit em vez de squash (ADR 0006). |
| Aprovação | O operador só autoriza algo já pronto, sem alterá-lo. | Aprovar o conteúdo de um arquivo antes de salvar (CLAUDE.md §6). |
| Correção | O operador aponta ou refaz algo que a IA fez errado ou fora do pedido. | (ilustrativo) Mandar reverter a mudança de um teste que estava certo. |
| Operação manual | Ação que a IA não pode ou não deve executar. | (ilustrativo) Fazer o merge na main, ou rodar um login interativo com `!`. |
| Desbloqueio | O operador remove um impedimento que parou o trabalho. | (ilustrativo) Liberar uma permissão negada ou fornecer um acesso. |
| Aprendizado | O operador gasta tempo para entender, não para avançar a entrega. | (ilustrativo) Pedir `/explicar` de um hook e depois estudar o resultado. |

Regra de desempate: se uma ação cabe em dois tipos, vale a que mudou o
resultado (correção ganha de aprovação; desbloqueio ganha de operação manual).

## 4. Métricas e fontes
| ID | QP | Métrica | Definição | Fonte |
|----|----|---------|-----------|-------|
| M1 | 1 | Intervenções por tipo | Contagem por tipo da taxonomia, por sessão | Registro de sessão (sessoes/) |
| M2 | 1 | Proporção de código da IA | Linhas ou commits atribuídos à IA ÷ total | Git (trailer de autoria, ver limitação) |
| M3 | 2 | Erros da IA | Contagem de ERR com categoria `erro-ia` | docs/erros/ |
| M4 | 2 | Peça que pegou o erro | Hook, CI, verify.sh, /revisar, revisor-codigo, auditor-spec, operador ou ninguém | docs/erros/ (campo `detectado-em`; campo novo a decidir) e, para os hooks, `.claude/pesquisa/eventos.jsonl` (um evento por bloqueio; ver docs/help/ferramentas/eventos-do-harness.md) |
| M5 | 3 | Testes e cobertura | Nº de testes, cobertura e mutação por fase | `scripts/verify.sh full`, CI |
| M6 | 3 | Achados da revisão | Nº de 🔴/🟡/🟢 por feature | Saída da /revisar |
| M7 | 3 | CI | Taxa de execuções verdes e nº de reexecuções | `gh run list` |
| M8 | 3 | Dívida | Entradas abertas em DEBT | docs/DEBT.md |
| M9 | 3 | Complexidade | Métodos acima do limite | relatório de complexidade (docs/help/ferramentas/complexidade.md) |
| M10 | 4 | Tokens | Entrada, saída, criação de cache e leitura de cache por sessão | Transcrições `~/.claude/projects/<projeto>/<sessão>.jsonl`, campo `usage` das respostas do modelo (conferido em 2026-11-22) |
| M11 | 4 | Tempo | Duração de cada sessão e tempo ativo do operador | Campo `timestamp` de cada linha das transcrições + registro de sessão + eventos `"tipo":"sessao"` de `.claude/pesquisa/eventos.jsonl` (início de cada sessão) |
| M12 | 5 | Aprendizado | Conceitos estudados e acertos em quiz | aprendizado/diario.md (a criar) |
| M13 | todas | Linha do tempo | Commits, PRs e tasks por data | Git, `gh pr list`, rodapé `Task: T<n>` |

### Limitações conhecidas
- O Git sozinho NÃO distingue autoria humana e de IA: commits feitos pelo Claude
  saem no nome do dono. M2 exige registrar a autoria (ver ADR 0007).
- M4 depende do registro do erro ter sido feito (/registrar-erro); erros
  não registrados não entram. Os eventos dos hooks só mostram o que um hook BLOQUEOU: erro que nenhum hook
  viu não aparece, e `.claude/pesquisa/eventos.jsonl` não vai para o Git (copie-o para fora do repositório).
- Tokens e tempo dependem de as transcrições locais serem preservadas; elas
  ficam só na máquina do operador e não vão para o repositório.

## 5. Coleta
- **Início da coleta sistemática:** 2026-11-22.
- **Dados anteriores ao início:** o período de 2026-10-25 (ADR 0001) a 2026-11-21 é retrospectivo: reconstruído só do que o Git e docs/ já registram e das transcrições que ainda existirem, e marcado como "retrospectivo". Intervenções (M1) desse período não são reconstruídas.
- **Por sessão:** um arquivo em docs/pesquisa/sessoes/ (data, tipo de cada intervenção, tempo, tokens).
- **Dados brutos e derivados:** docs/pesquisa/dados/. O csv de cada fase sai de `scripts/pesquisa/coletar-fase.sh`
  (docs/help/ferramentas/coleta-por-fase.md).
- **Privacidade:** não registrar segredos, e-mails, nomes de pessoas nem dados de respondentes.

## 6. Ameaças à validade
- Caso único e um só operador; o operador é também o pesquisador.
- Registro manual de intervenções pode ser inconsistente.
- O harness mudou durante o estudo; comparar fases exige anotar qual harness valia.

## 7. Perguntas em aberto
- Campo para "peça que pegou o erro" no template de erro.
