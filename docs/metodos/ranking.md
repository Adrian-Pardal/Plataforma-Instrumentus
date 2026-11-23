---
titulo: Ficha do método Ranking (ordenação)
proposito: Dizer como o ranking funciona e como a plataforma calcula os pontos de Borda, a posição média e o primeiro lugar
status: rascunho
atualizado: 2026-11-22
mantido-por: manual
relacionados: [README.md, comparacao-pareada.md, maxdiff.md]
---

# Ranking / ordenação

Nível 2 · Uso geral · Etapa 4 · Status: não implementado.
Texto da fonte "Métodos de pesquisa da plataforma"; os números do exemplo foram recalculados e a referência foi
conferida no Crossref.

## Como funciona
O respondente coloca uma lista de itens em ordem de preferência ou importância, em geral arrastando. As análises mais
comuns são a posição média de cada item, a porcentagem de vezes em que ficou em 1º lugar e a contagem de Borda: com
*n* itens, o 1º recebe *n* pontos, o 2º recebe *n* − 1, e assim por diante.

## Regras para o código
- Guardar a ordem completa de cada respondente, e não só as médias.
- Arrastar com alternativa pelo teclado e sorteio da ordem inicial dos itens (previstos no guia para a Etapa 4).
- Posição média: quanto menor, melhor. Pontos de Borda: quanto maior, melhor.
- Conferência: o total de pontos é sempre respondentes × (1 + 2 + … + *n*).
- Listas longas cansam: o ideal é até 7 a 10 itens.

## Teste de referência
3 respondentes ordenaram 4 itens (A, B, C, D); na contagem de Borda, o 1º vale 4 pontos e o 4º vale 1.

| Respondente | 1º | 2º | 3º | 4º |
|---|---|---|---|---|
| R1 | A | B | C | D |
| R2 | B | A | D | C |
| R3 | A | C | B | D |

| Item | Pontos de Borda | Posição média | % em 1º lugar |
|---|---|---|---|
| A | 4 + 3 + 4 = 11 | (1 + 2 + 1) / 3 = 1,33 | 66,7% |
| B | 3 + 4 + 2 = 9 | 2,00 | 33,3% |
| C | 2 + 1 + 3 = 6 | 3,00 | 0% |
| D | 1 + 2 + 1 = 4 | 3,67 | 0% |

Conferência: 3 × (1 + 2 + 3 + 4) = 30 = 11 + 9 + 6 + 4.

## Fundamentação
Alwin e Krosnick (1985) compararam avaliações (dar nota a cada item) e rankings (ordenar os itens). Nas notas, o
respondente pode dar a mesma nota a tudo; no ranking, é obrigado a escolher, o que revela prioridades com mais
clareza. A desvantagem é que os dados são *ipsativos*: a soma das posições é sempre a mesma, o que limita
correlações e análise fatorial.

## Condição de uso
Técnica geral de pesquisa. Uso livre, citando a fonte (segundo o documento de métodos; não verificado na fonte).

## Versão em português
Não se aplica: é um formato de pergunta.

## Perguntas em aberto
- Ranking parcial (ordenar só os 3 primeiros) é permitido? O documento só descreve a ordenação completa.
- Empates são permitidos? O documento não diz.
- Como a plataforma avisa o pesquisador que a lista passou do tamanho recomendado?

## Referências
- ALWIN, D. F.; KROSNICK, J. A. The measurement of values in surveys: a comparison of ratings and rankings. *Public
  Opinion Quarterly*, v. 49, n. 4, p. 535-552, 1985. DOI: 10.1086/268949.
