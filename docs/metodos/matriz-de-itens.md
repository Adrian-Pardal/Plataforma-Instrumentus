---
titulo: Ficha do método Matriz de itens
proposito: Dizer como a matriz de itens funciona e como a plataforma sinaliza respostas de baixa qualidade
status: rascunho
atualizado: 2026-11-22
mantido-por: manual
relacionados: [README.md, likert.md]
---

# Matriz de itens

Nível 1 · Uso geral · Etapa 2 · Status: não implementado.
Texto da fonte "Métodos de pesquisa da plataforma"; as referências foram conferidas no Crossref quando têm DOI.

## Como funciona
Vários itens que usam a mesma escala aparecem numa grade: itens nas linhas, opções de resposta nas colunas. É a
forma usual de apresentar instrumentos como o TFA ou o SUS. No celular, a grade costuma ser quebrada em um item por tela.

## Regras para o código
- O cálculo de cada linha é o da escala Likert (ver [likert.md](likert.md)); a matriz acrescenta a checagem de qualidade.
- Sinalizar, nunca apagar: respostas com desvio-padrão 0 (*straightlining*) ou tempo muito curto são marcadas para o
  pesquisador decidir.
- Os limites (por exemplo, menos de 2 s por item) devem ser configuráveis.
- Guardar o tempo gasto na grade.

## Teste de referência
Grade de 5 itens (1 a 5):

| Respondente | Respostas | Desvio-padrão das respostas | Tempo na grade | Sinal |
|---|---|---|---|---|
| R1 | 4, 2, 5, 3, 4 | 1,14 | 38 s | ok |
| R2 | 3, 3, 3, 3, 3 | 0 | 6 s | linha reta e rápido |

R2 marcou a mesma coluna em tudo e levou cerca de 1 s por item.

## Fundamentação
A grade economiza espaço e tempo, mas aumenta abandonos, respostas em branco e *satisficing* (responder no
automático, por exemplo marcando a mesma coluna em tudo). Couper et al. (2013) testaram desenhos de grade para
reduzir esses problemas. A recomendação prática é usar grades curtas e destacar a linha que está sendo respondida.

## Condição de uso
Formato geral de pergunta, sem instrumento proprietário. Uso livre, citando a fonte (segundo o documento de métodos;
não verificado na fonte).

## Versão em português
Não se aplica: é um formato de pergunta.

## Perguntas em aberto
- Quais são os limites padrão de tempo por item e de desvio-padrão? O documento só dá "menos de 2 s por item" como exemplo.
- Qual é o tamanho máximo recomendado de uma grade? O documento diz apenas "curtas".
- O sinal de qualidade aparece no relatório ou só na exportação?

## Referências
- COUPER, M. P. et al. The design of grids in web surveys. *Social Science Computer Review*, v. 31, n. 3,
  p. 322-345, 2013. DOI: 10.1177/0894439312469865.
- KROSNICK, J. A. Response strategies for coping with the cognitive demands of attitude measures in surveys.
  *Applied Cognitive Psychology*, v. 5, n. 3, p. 213-236, 1991. DOI: 10.1002/acp.2350050305.
