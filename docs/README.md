---
titulo: Mapa da documentação
proposito: Dizer, para cada dúvida, em que pasta de docs/ está a resposta
status: vigente
atualizado: 2026-11-22
mantido-por: manual
relacionados: [templates/cabecalho.md, ../CLAUDE.md]
---

# Mapa da documentação

Cada pasta tem um `README.md` com o índice dela. Procure a sua dúvida na tabela e siga para a pasta.

| Tenho a dúvida… | Vá em |
|---|---|
| O que é o produto e para quem? | [produto/](produto/README.md) |
| O que o sistema faz? Quais regras segue? | [requisitos/](requisitos/README.md) |
| O que vou construir nesta feature? Em que ordem? | [specs/](specs/README.md) e [plans/](plans/README.md) |
| Que conceitos, tabelas e estados existem? | [modelagem/](modelagem/README.md) |
| Como as partes se falam? Onde cada uma roda? | [arquitetura/](arquitetura/README.md) |
| Por que decidimos X? | [adr/](adr/README.md) |
| Qual é o contrato da API e quais os erros? | [api/](api/README.md) |
| Como escrever código aqui? | [codigo/](codigo/README.md) |
| Como testamos? Que casos existem? | [testes/](testes/README.md) |
| Quais ameaças e dados pessoais existem? | [seguranca/](seguranca/README.md) |
| Como rodar, configurar e publicar? | [ambientes/](ambientes/README.md) |
| O que fazer quando algo quebra? | [operacao/](operacao/README.md) |
| O que é a tecnologia X e por que a usamos? | [tecnologias/](tecnologias/README.md) |
| O que eu estudei? | [aprendizado/](aprendizado/README.md) |
| Como cada método de pesquisa calcula? | [metodos/](metodos/README.md) |
| Esse erro já aconteceu? | [erros/](erros/README.md) |
| Onde parei na última sessão? | [handoff/](handoff/README.md) |
| Que modelos de documento existem? | [templates/](templates/README.md) |
| Como o desenvolvimento com IA foi medido? | [estudo-de-caso/](estudo-de-caso/README.md) |
| Como rodo uma rotina ou ferramenta (coleta, telemetria, hooks)? | [help/](help/README.md) |
| Que skill uso para quê? | [skills.md](skills.md) |
| Que dívida técnica existe? | [DEBT.md](DEBT.md) |

## Quatro tipos de texto, sem misturar
- **Tutorial:** ensina fazendo, passo a passo, para quem está começando.
- **Guia:** resolve um problema conhecido ("como fazer X").
- **Referência:** descreve fatos, para consultar (tabelas, comandos, campos).
- **Explicação:** conta o porquê e o contexto.

## Avisos
- Todo documento novo começa com o cabeçalho de [templates/cabecalho.md](templates/cabecalho.md).
- Documentos anteriores à Fase 3 podem não ter cabeçalho; não são migrados em massa.
- Documentação vai no mesmo PR do código que ela descreve.
