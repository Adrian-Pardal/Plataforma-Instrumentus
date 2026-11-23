---
titulo: Ficha do método IVC (Índice de Validade de Conteúdo)
proposito: Dizer como o IVC funciona, quais pontos de corte usa e como a plataforma calcula
status: rascunho
atualizado: 2026-11-22
mantido-por: manual
relacionados: [README.md]
---

# IVC (Índice de Validade de Conteúdo)

Nível 2 · Uso geral · Etapa 4 · Status: não implementado.
Texto da fonte "Métodos de pesquisa da plataforma"; os números do exemplo foram recalculados e as referências foram
conferidas no Crossref.

## Como funciona
Um grupo de juízes (especialistas no tema) avalia cada item de um questionário novo ou traduzido quanto à
relevância, numa escala de 4 pontos (1 = não relevante a 4 = muito relevante). Calculam-se dois índices:

    I-IVC = (juízes que deram nota 3 ou 4) / (total de juízes)
    S-IVC/Média = média dos I-IVC de todos os itens

Pontos de corte usuais, segundo o documento: I-IVC ≥ 0,78 com 6 ou mais juízes, ou 1,00 com 3 a 5 juízes (Lynn,
1986), e S-IVC/Média ≥ 0,90 (Polit; Beck, 2006). Itens abaixo do corte são revistos ou retirados, e os juízes costumam
deixar sugestões em campo aberto.

## Regras para o código
- Papel de "juiz" na pesquisa (previsto no guia para a Etapa 4).
- O corte do I-IVC é escolhido pelo número de juízes: 1,00 com 3 a 5; 0,78 com 6 ou mais.
- Calcular com mais casas decimais e arredondar só na exibição.
- Guardar a nota de cada juiz por item e as sugestões em texto livre.

## Teste de referência
6 juízes avaliaram 3 itens (1 a 4):

| Item | Notas dos 6 juízes | Notas 3 ou 4 | I-IVC | Decisão (corte 0,78) |
|---|---|---|---|---|
| 1 | 4, 4, 3, 4, 3, 4 | 6 | 6 / 6 = 1,00 | mantém |
| 2 | 4, 3, 2, 4, 3, 4 | 5 | 5 / 6 = 0,83 | mantém |
| 3 | 2, 3, 2, 4, 1, 3 | 3 | 3 / 6 = 0,50 | revê |

- S-IVC/Média com os 3 itens = (1,00 + 0,83 + 0,50) / 3 = 0,78, abaixo de 0,90
- Depois de retirar o item 3 = (1,00 + 0,83) / 2 = 0,92, acima de 0,90

## Fundamentação
Validade de conteúdo é o quanto os itens representam bem o que se quer medir. Lynn (1986) propôs quantificá-la pela
proporção de concordância entre especialistas, e Polit e Beck (2006) padronizaram a forma de calcular e relatar o
índice. No Brasil, a referência mais citada é Alexandre e Coluci (2011), que descrevem o processo nas etapas de
construção e de adaptação de instrumentos.

## Condição de uso
Método geral de validação. Uso livre, citando a fonte (segundo o documento de métodos; não verificado na fonte).

## Versão em português
Não se aplica a instrumento. A referência brasileira do método é Alexandre e Coluci (2011), em português.

## Perguntas em aberto
- O que fazer com menos de 3 juízes? O documento só define o corte para 3 ou mais.
- Os cortes (0,78, 1,00, 0,90) vêm do documento; não foram conferidos nos artigos de Lynn e de Polit e Beck.
- O IVC é só de relevância ou a plataforma oferece outros critérios (clareza, pertinência)? O documento só trata de
  relevância.
- O que fazer com a recomendação de retirar o item: a plataforma só mostra "revê" ou também recalcula o S-IVC/Média?

## Referências
- LYNN, M. R. Determination and quantification of content validity. *Nursing Research*, v. 35, n. 6, p. 382-385,
  1986. DOI: 10.1097/00006199-198611000-00017.
- POLIT, D. F.; BECK, C. T. The content validity index: are you sure you know what's being reported? Critique and
  recommendations. *Research in Nursing & Health*, v. 29, n. 5, p. 489-497, 2006. DOI: 10.1002/nur.20147.
- ALEXANDRE, N. M. C.; COLUCI, M. Z. O. Validade de conteúdo nos processos de construção e adaptação de instrumentos
  de medidas. *Ciência & Saúde Coletiva*, v. 16, n. 7, p. 3061-3068, 2011. DOI: 10.1590/S1413-81232011000800006.
