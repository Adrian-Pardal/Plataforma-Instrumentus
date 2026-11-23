---
titulo: Ficha do método Comparação pareada
proposito: Dizer como a comparação pareada funciona e como a plataforma calcula vitórias e o modelo de Bradley-Terry
status: rascunho
atualizado: 2026-11-22
mantido-por: manual
relacionados: [README.md, ranking.md, maxdiff.md]
---

# Comparação pareada

Nível 2 · Uso geral · Etapa 4 · Status: não implementado.
Texto da fonte "Métodos de pesquisa da plataforma"; os números do exemplo, inclusive o ajuste de Bradley-Terry, foram
recalculados e as referências foram conferidas no Crossref.

## Como funciona
Os itens são apresentados de dois em dois ("qual você prefere?"), até cobrir todos os pares. Com *n* itens, são
*n*(*n* − 1)/2 pares: 5 itens geram 10 pares, e 10 itens geram 45. A análise mais simples é a proporção de vitórias de
cada item; a mais completa é o modelo de Bradley-Terry, que estima a "força" de cada item numa escala comum.

## Regras para o código
- Sortear a ordem dos pares e o lado (esquerda ou direita) de cada item, para evitar viés de posição.
- Guardar cada escolha (par, vencedor), e não só a contagem.
- No modelo de Bradley-Terry, a chance de *i* vencer *j* é P(i > j) = πᵢ / (πᵢ + πⱼ), com os π normalizados para
  somar 1 e estimados pelo algoritmo iterativo MM.
- Acima de uns 8 itens, o número de pares cresce rápido; considerar o MaxDiff ([maxdiff.md](maxdiff.md)).

## Teste de referência
4 itens geram 4 × 3 / 2 = 6 pares, respondidos por 10 pessoas. Vitórias da linha contra a coluna:

| | A | B | C | D | Vitórias | Proporção (de 30) |
|---|---|---|---|---|---|---|
| A | – | 7 | 8 | 6 | 21 | 0,70 |
| B | 3 | – | 6 | 5 | 14 | 0,47 |
| C | 2 | 4 | – | 3 | 9 | 0,30 |
| D | 4 | 5 | 7 | – | 16 | 0,53 |

Cada item participa de 3 pares × 10 pessoas = 30 comparações. Bradley-Terry (MM, normalizado): A = 0,431,
D = 0,250, B = 0,202, C = 0,117. A vence C com chance de 0,431 / (0,431 + 0,117) = 78,6%.

## Fundamentação
Thurstone (1927) formulou a lei do julgamento comparativo: cada item provoca uma impressão que varia um pouco a cada
vez, e a frequência com que A vence B revela a distância entre eles. Bradley e Terry (1952) propuseram o modelo
probabilístico usado até hoje. Escolher entre dois é mais fácil que ordenar uma lista inteira, mas o número de pares
cresce rápido.

## Condição de uso
Técnica geral de pesquisa. Uso livre, citando a fonte (segundo o documento de métodos; não verificado na fonte).

## Versão em português
Não se aplica: é um método de coleta e análise.

## Perguntas em aberto
- O que fazer se um item nunca vence ou nunca perde? O documento não cobre esse caso do modelo.
- Qual é o critério de convergência do algoritmo e a biblioteca usada? Biblioteca estatística nova é dependência e
  precisa estar registrada no plano.
- A pesquisa precisa cobrir todos os pares, ou aceita subconjuntos? O documento descreve todos os pares.

## Referências
- THURSTONE, L. L. A law of comparative judgment. *Psychological Review*, v. 34, n. 4, p. 273-286, 1927.
  DOI: 10.1037/h0070288.
- BRADLEY, R. A.; TERRY, M. E. Rank analysis of incomplete block designs: I. The method of paired comparisons.
  *Biometrika*, v. 39, n. 3/4, p. 324-345, 1952. DOI: 10.1093/biomet/39.3-4.324.
