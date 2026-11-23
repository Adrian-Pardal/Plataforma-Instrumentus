---
titulo: Ficha do método Pré e pós-teste
proposito: Dizer como o pré e pós-teste funciona, como a plataforma pareia as respostas e calcula o teste e o efeito
status: rascunho
atualizado: 2026-11-22
mantido-por: manual
relacionados: [README.md, alfa-de-cronbach.md]
---

# Pré e pós-teste

Nível 2 · Uso geral · Etapa 4 · Status: não implementado.
Texto da fonte "Métodos de pesquisa da plataforma"; os números do exemplo foram recalculados (t, p do teste t, p exato
do Wilcoxon e d).

## Como funciona
O mesmo questionário é aplicado às mesmas pessoas antes e depois de uma intervenção (uma aula, um treinamento, um
aplicativo). As duas respostas de cada pessoa são ligadas por um código anônimo, e a diferença é testada com o teste *t*
pareado (dados aproximadamente normais) ou o teste de Wilcoxon (dados ordinais). O tamanho do efeito (*d* de Cohen)
mostra se a diferença é relevante, e não só estatisticamente significativa.

## Regras para o código
- Ligar as duas respostas pelo código anônimo; só entram no cálculo pessoas com as duas respostas.
- Calcular o valor de *p* com uma biblioteca estatística, e não com tabelas fixas.
- Oferecer o desenho com um só grupo e, opcionalmente, com grupo de controle que também responde as duas vezes.
- Guardar a resposta bruta de cada momento.

## Teste de referência
6 participantes fizeram um teste de 0 a 20 pontos antes e depois de um curso:

| Participante | P1 | P2 | P3 | P4 | P5 | P6 |
|---|---|---|---|---|---|---|
| Antes | 10 | 12 | 9 | 14 | 11 | 13 |
| Depois | 14 | 15 | 10 | 16 | 15 | 14 |
| Diferença | 4 | 3 | 1 | 2 | 4 | 1 |

- Média das diferenças = 15 / 6 = 2,50; desvio-padrão das diferenças = 1,38
- Teste *t* pareado: *t* = 2,50 / (1,38 / √6) = 4,44, com 5 graus de liberdade, *p* = 0,0067 (≈ 0,007)
- Teste de Wilcoxon: todas as diferenças são positivas, *p* = 0,031 (exato, bicaudal, com postos médios nos empates)
- Tamanho do efeito: *d* = 2,50 / 1,38 = 1,81 (grande; pela referência de Cohen, 0,2 é pequeno, 0,5 médio e 0,8 grande)

## Fundamentação
Campbell e Stanley (1963) classificaram esse desenho, quando tem um só grupo, como pré-experimental: a mudança pode
vir de outras causas, como história (algo que aconteceu no meio-tempo), maturação, efeito de já ter respondido o
teste e regressão à média. Com um grupo de controle que também responde as duas vezes, o desenho fica bem mais forte
(Shadish; Cook; Campbell, 2002).

## Condição de uso
Desenho geral de pesquisa. Uso livre, citando a fonte (segundo o documento de métodos; não verificado na fonte).

## Versão em português
Não se aplica: é um desenho de coleta e análise.

## Perguntas em aberto
- Qual fórmula de *d* a plataforma usa? O documento usa a média das diferenças dividida pelo desvio-padrão das
  diferenças; existem outras fórmulas para dados pareados.
- Com empates nas diferenças, bibliotecas diferentes usam Wilcoxon exato ou aproximação normal e podem dar *p*
  diferente de 0,031. Qual regra e qual biblioteca? Biblioteca nova é dependência e precisa estar no plano.
- A plataforma escolhe entre *t* e Wilcoxon ou deixa o pesquisador decidir? O documento descreve os dois.
- Como lidar com quem perde o código anônimo? O documento só pede ligar pelo código.

## Referências
- CAMPBELL, D. T.; STANLEY, J. C. *Experimental and quasi-experimental designs for research*. Chicago: Rand
  McNally, 1963. (Livro; DOI não verificado.)
- SHADISH, W. R.; COOK, T. D.; CAMPBELL, D. T. *Experimental and quasi-experimental designs for generalized causal
  inference*. Boston: Houghton Mifflin, 2002. (Livro; DOI não verificado.)
- COHEN, J. *Statistical power analysis for the behavioral sciences*. 2. ed. Hillsdale: Lawrence Erlbaum, 1988.
  (Livro; DOI não verificado.)
