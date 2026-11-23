---
titulo: Ficha do método CSAT (satisfação do cliente)
proposito: Dizer como o CSAT funciona e como a plataforma calcula a porcentagem de satisfeitos e a média
status: rascunho
atualizado: 2026-11-22
mantido-por: manual
relacionados: [README.md]
---

# CSAT (satisfação do cliente)

Nível 1 · Empresarial e mercado · Etapa 2 · Status: não implementado.
Texto da fonte "Métodos de pesquisa da plataforma"; as referências foram conferidas no Crossref.

## Como funciona
Logo após uma interação (compra, atendimento, uso de um recurso), pergunta-se o quanto a pessoa ficou satisfeita
com ela, numa escala de 1 (muito insatisfeito) a 5 (muito satisfeito). O resultado mais comum é a porcentagem de
clientes satisfeitos, contando as notas 4 e 5:

    CSAT = (respostas 4 e 5) / (total de respostas) × 100

Esta ficha não reproduz a redação da pergunta.

## Regras para o código
- Mostrar os dois resultados, com rótulos distintos: a porcentagem de satisfeitos (CSAT) e a média na escala de 1 a 5.
- O denominador é o total de respostas àquela pergunta.

## Teste de referência
250 respostas na escala de 1 a 5:

| Nota | 5 | 4 | 3 | 2 | 1 | Total |
|---|---|---|---|---|---|---|
| Respostas | 110 | 70 | 30 | 25 | 15 | 250 |

- CSAT = (110 + 70) / 250 × 100 = 72%
- Média = (5×110 + 4×70 + 3×30 + 2×25 + 1×15) / 250 = 985 / 250 = 3,94

## Fundamentação
Baseia-se no modelo de desconfirmação de expectativas de Oliver (1980): a satisfação resulta da comparação entre o
que o cliente esperava e o que recebeu. Fornell (1992) levou a medida para o nível nacional com o barômetro sueco, que
deu origem ao Índice Americano de Satisfação do Cliente (ACSI). O CSAT mede o curto prazo; para lealdade, usa-se a
probabilidade de recomendação ([probabilidade-de-recomendacao.md](probabilidade-de-recomendacao.md)).

## Condição de uso
Uso livre, citando a fonte (segundo o documento de métodos; não verificado na fonte).

## Versão em português
Não encontrada na busca de 2026-11-22 (Crossref). Não equivale a "não existe".

## Perguntas em aberto
- Qual é a redação oficial da pergunta e se há restrição para reproduzi-la? Esta ficha não a reproduz.
- A contagem das notas 4 e 5 é a regra mais comum, não uma regra dos autores: a plataforma a fixa ou deixa configurar?

## Referências
- OLIVER, R. L. A cognitive model of the antecedents and consequences of satisfaction decisions. *Journal of
  Marketing Research*, v. 17, n. 4, p. 460-469, 1980. DOI: 10.1177/002224378001700405.
- FORNELL, C. A national customer satisfaction barometer: the Swedish experience. *Journal of Marketing*, v. 56,
  n. 1, p. 6-21, 1992. DOI: 10.1177/002224299205600103.
