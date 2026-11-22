---
titulo: Manual do operador
proposito: Indexar as rotinas manuais e as ferramentas que só um humano mantém
status: vigente
atualizado: 2026-11-22
mantido-por: manual
relacionados: [../templates/help.md, ../README.md]
---

# Manual do operador

**Esta pasta responde:** como mantenho, atualizo ou confiro uma ferramenta ou rotina manual?
**Mantida por:** manual (cada página nasce junto da ferramenta que descreve)

Rotinas que só um humano faz para o projeto continuar funcionando:
atualizar, manter, conferir, renovar. Estilo do `man`: cada página
tem NOME, PARA QUE SERVE, QUANDO FAZER, PASSO A PASSO e como voltar atrás.
Modelo para novas páginas: `docs/templates/help.md`.

## Preciso fazer X → leia a página Y

| Preciso...                                        | Página                        |
|---------------------------------------------------|-------------------------------|
| Fazer a manutenção do mês (WSL, apt, disco, etc.) | manutencao/mensal.md          |
| Ver se há versão nova do Context7 e atualizar     | ferramentas/context7.md       |
| Ver a versão ou atualizar Java, Node, lefthook, gitleaks, gh ou actionlint | ferramentas/instaladas.md |
| Entender e usar skills (manual × automática, onde está o índice) | ferramentas/skills.md |
| Rodar os testes dos hooks e do verify.sh          | ferramentas/testes-dos-hooks.md |
| Ver quais funções de bash têm decisões demais (complexidade) | ferramentas/complexidade.md |
| Instalar os hooks do git ou entender um commit recusado | ferramentas/lefthook.md |
| Entender o CI, ler uma falha dele ou atualizar as actions | ferramentas/ci.md |
| Ver a regra do título do PR (Conventional Commits) ou corrigir o check titulo-do-pr | ferramentas/titulo-do-pr.md |
| Entender os riscos do agente, conferir as regras de confirmação ou aprovar um servidor MCP | ../seguranca/agente.md |
| Abrir issue de erro, criar as etiquetas ou entender a issue que o CI abre sozinho | ferramentas/registro-de-erros.md |
| Pedir o merge de um PR na develop ou entender um bloqueio do protect-merge | ferramentas/merge-de-pr.md |
| Conferir, refazer ou afrouxar as regras de proteção da develop e da main | ferramentas/protecao-de-branches.md |
| Subir o Collector de telemetria da pesquisa (tokens e tempo) e conferir os arquivos | ferramentas/telemetria.md |
| Ler o registro dos bloqueios dos hooks e do início das sessões (pesquisa) | ferramentas/eventos-do-harness.md |
| Gerar o csv de números de uma fase da pesquisa (commits, CI, erros, intervenções, bloqueios) | ferramentas/coleta-por-fase.md |

## help × runbooks

- **help (esta pasta):** rotina. Você sabe o que vai fazer e quando.
  Nada está quebrado.
- **docs/operacao/runbooks:** problema. Algo quebrou e você precisa
  diagnosticar e consertar. Passa a existir a partir da Fase 3.

Se uma rotina falhar e você não souber o que fazer, a seção
"SE DER ERRADO" da própria página cobre o retorno ao estado anterior.

## Regra de manutenção

Toda ferramenta, credencial ou tarefa manual nova ganha página aqui no
mesmo commit; quando um procedimento mudar, a página muda junto.
