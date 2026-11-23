---
titulo: Ficha do método Alfa de Cronbach
proposito: Dizer como o alfa de Cronbach funciona, como a plataforma calcula e quando não o usar
status: rascunho
atualizado: 2026-11-22
mantido-por: manual
relacionados: [README.md, aim-iam-fim.md, tfa.md]
---

# Alfa de Cronbach

Nível 2 · Uso geral · Etapa 2 · Status: não implementado.
Texto da fonte "Métodos de pesquisa da plataforma"; as referências foram conferidas no Crossref quando têm DOI.

## Como funciona
Mede a consistência interna de um conjunto de itens que deveriam medir a mesma coisa. Com *k* itens, variância de
cada item σᵢ² e variância do escore total σₜ²:

    α = k / (k − 1) × (1 − Σσᵢ² / σₜ²)

Vai de 0 a 1. Em geral, 0,70 é considerado aceitável e 0,80 bom; acima de 0,90, pode haver itens redundantes. A
plataforma calcula o alfa de cada construto ou subescala, e não do questionário inteiro quando ele mede várias coisas
(como o TFA, ver [tfa.md](tfa.md)).

## Regras para o código
- Usar a variância amostral (denominador n − 1) nos itens e no total.
- Inverter os itens contrários antes de calcular.
- Excluir quem deixou algum item em branco.
- Exigir pelo menos 2 itens e, na prática, dezenas de respondentes: com 5 o valor é só ilustrativo.
- Calcular por construto ou subescala.

## Teste de referência
5 respondentes, 3 itens de um mesmo construto (1 a 5):

| Respondente | Item 1 | Item 2 | Item 3 | Total |
|---|---|---|---|---|
| R1 | 4 | 5 | 4 | 13 |
| R2 | 3 | 4 | 3 | 10 |
| R3 | 5 | 5 | 4 | 14 |
| R4 | 2 | 3 | 2 | 7 |
| R5 | 4 | 4 | 5 | 13 |
| **Variância** | 1,3 | 0,7 | 1,3 | 8,3 |

α = 3 / 2 × (1 − (1,3 + 0,7 + 1,3) / 8,3) = 1,5 × (1 − 0,398) = 0,90.

## Fundamentação
Cronbach (1951) generalizou fórmulas anteriores de confiabilidade: o alfa estima quanto da variação do escore total
vem do que os itens têm em comum, e não de erro. Tavakol e Dennick (2011) explicam a interpretação e os pontos de
corte. O alfa supõe que todos os itens pesam igual; quando isso não vale, ele subestima a confiabilidade, e Sijtsma
(2009) recomenda alternativas como o ômega de McDonald.

## Condição de uso
Estatística geral, sem instrumento proprietário. Uso livre, citando a fonte (segundo o documento de métodos; não
verificado na fonte).

## Versão em português
Não se aplica: é um coeficiente estatístico.

## Perguntas em aberto
- Quantos respondentes são o mínimo para a plataforma exibir o alfa? O documento diz "dezenas", sem número.
- A plataforma oferece o ômega de McDonald, recomendado por Sijtsma (2009)? O documento só o cita.
- Excluir quem deixou item em branco (como no documento) ou usar outra regra para dados faltantes?

## Referências
- CRONBACH, L. J. Coefficient alpha and the internal structure of tests. *Psychometrika*, v. 16, n. 3, p. 297-334,
  1951. DOI: 10.1007/BF02310555.
- TAVAKOL, M.; DENNICK, R. Making sense of Cronbach's alpha. *International Journal of Medical Education*, v. 2,
  p. 53-55, 2011. DOI: 10.5116/ijme.4dfb.8dfd.
- SIJTSMA, K. On the use, the misuse, and the very limited usefulness of Cronbach's alpha. *Psychometrika*, v. 74,
  n. 1, p. 107-120, 2009. DOI: 10.1007/s11336-008-9101-0.
- NUNNALLY, J. C. *Psychometric theory*. 2. ed. New York: McGraw-Hill, 1978. (Livro; DOI não verificado.)
