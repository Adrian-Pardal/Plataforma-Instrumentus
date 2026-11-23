---
titulo: Ficha do método Escala numérica
proposito: Dizer como a escala numérica (1–5, 0–10) funciona e como a plataforma calcula
status: rascunho
atualizado: 2026-11-22
mantido-por: manual
relacionados: [README.md]
---

# Escala numérica (1–5, 0–10)

Nível 1 · Uso geral · Etapa 1 · Status: não implementado.
Texto da fonte "Métodos de pesquisa da plataforma"; as referências foram conferidas no Crossref quando têm DOI.

## Como funciona
O respondente dá uma nota dentro de um intervalo fixo, com rótulos só nas pontas (por exemplo, 0 = "péssimo" e
10 = "excelente"). A análise usa média, mediana, desvio-padrão e a distribuição das notas.

## Regras para o código
- O desvio-padrão é o amostral: denominador n − 1 (como DESVPAD.A no Excel, `sd` no R, `statistics.stdev` no Python).
- A mediana, com número par de respostas, é a média dos dois valores do meio.

## Teste de referência
Notas de 0 a 10 de 10 respondentes: 8, 9, 7, 10, 6, 8, 9, 5, 8, 10.
- Média = 80 / 10 = 8,0
- Mediana: ordenado (5, 6, 7, 8, 8, 8, 9, 9, 10, 10), os dois do meio são 8 e 8, então 8,0
- Desvio-padrão amostral: soma dos quadrados dos desvios = 24; variância = 24 / 9 = 2,67; desvio-padrão = 1,63
- Distribuição: 8 aparece 3 vezes (30%); 9 e 10, 2 vezes cada (20%); as demais, 1 vez (10%)

## Fundamentação
O número de pontos afeta a qualidade da medida. Preston e Colman (2000) compararam escalas de 2 a 11 pontos: as de
2 a 4 pontos tiveram confiabilidade e validade mais baixas, e os respondentes preferiram a de 10 pontos, seguida das
de 7 e 9. Krosnick e Presser (2010) recomendam 5 a 7 pontos para escalas bipolares, com todos os pontos rotulados
quando possível.

## Condição de uso
Formato geral de pergunta, sem instrumento proprietário. Uso livre, citando a fonte (segundo o documento de métodos;
não verificado na fonte).

## Versão em português
Não se aplica: é um formato de pergunta.

## Perguntas em aberto
- Que intervalos a plataforma oferece (1–5, 1–7, 0–10)? O documento cita os exemplos 1–5 e 0–10 sem fechar a lista.
- Rotular só as pontas ou todos os pontos? A recomendação de Krosnick e Presser é rotular todos "quando possível";
  o exemplo do documento rotula só as pontas.

## Referências
- PRESTON, C. C.; COLMAN, A. M. Optimal number of response categories in rating scales: reliability, validity,
  discriminating power, and respondent preferences. *Acta Psychologica*, v. 104, n. 1, p. 1-15, 2000.
  DOI: 10.1016/S0001-6918(99)00050-5.
- KROSNICK, J. A.; PRESSER, S. Question and questionnaire design. In: MARSDEN, P. V.; WRIGHT, J. D. (ed.).
  *Handbook of survey research*. 2. ed. Bingley: Emerald, 2010. p. 263-313. (Capítulo, sem DOI encontrado.)
