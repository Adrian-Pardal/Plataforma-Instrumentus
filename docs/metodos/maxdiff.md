---
titulo: Ficha do método MaxDiff (best-worst scaling)
proposito: Dizer como o MaxDiff funciona, como a plataforma monta os conjuntos e calcula o escore
status: rascunho
atualizado: 2026-11-22
mantido-por: manual
relacionados: [README.md, ranking.md, comparacao-pareada.md]
---

# MaxDiff (best-worst scaling)

Nível 3 · Uso geral · Etapa 5 · Status: não implementado.
Texto da fonte "Métodos de pesquisa da plataforma"; os números do exemplo foram recalculados e as referências foram
conferidas no Crossref quando têm DOI.

## Como funciona
O pesquisador define uma lista de itens (por exemplo, 10 a 30 características de um produto ou prioridades de uma
política). O respondente vê vários conjuntos pequenos, em geral de 4 ou 5 itens, e em cada um escolhe o **mais** e o
**menos** importante. O desenho dos conjuntos é balanceado: cada item aparece o mesmo número de vezes (geralmente 3 ou
mais por pessoa) e junto de itens diferentes. A análise mais simples é a contagem:

    escore do item = (vezes escolhido como melhor − vezes escolhido como pior) / vezes em que apareceu

O escore vai de −1 a +1. Análises mais completas usam modelos logit multinomiais ou bayesianos hierárquicos, que
estimam a importância relativa de cada item para cada pessoa.

## Regras para o código
- Gerar conjuntos balanceados: cada item aparece o mesmo número de vezes e os pares de itens se repetem o mais
  igualmente possível (gerador previsto no guia para a Etapa 5).
- Impedir que o mesmo item seja marcado como melhor e pior no mesmo conjunto.
- Sortear a ordem dos conjuntos e dos itens dentro deles.
- Guardar cada escolha (conjunto, melhor, pior), e não só a contagem, para permitir a análise por modelo depois.
- Conferência: a soma de "melhor" e a de "pior" são iguais ao número de conjuntos respondidos.

## Teste de referência
Desenho: com 4 itens em conjuntos de 3, há exatamente 4 conjuntos possíveis (ABC, ABD, ACD, BCD), e cada item aparece
3 vezes. Resultado agregado de 40 conjuntos respondidos (cada item apareceu 30 vezes):

| Item | Aparições | Melhor | Pior | Escore = (melhor − pior) / aparições |
|---|---|---|---|---|
| A | 30 | 18 | 2 | (18 − 2) / 30 = +0,53 |
| C | 30 | 10 | 10 | 0,00 |
| B | 30 | 8 | 10 | −0,07 |
| D | 30 | 4 | 18 | −0,47 |

Conferência: melhor soma 40 e pior soma 40, iguais ao número de conjuntos.

## Fundamentação
Baseia-se na teoria da utilidade aleatória, que vem de Thurstone (1927) e foi formalizada para escolhas por McFadden
(1974): cada pessoa escolhe a opção de maior valor para ela, com alguma variação aleatória. Segundo o documento,
Louviere e Woodworth propuseram o método em 1990, e a primeira aplicação publicada foi a de Finn e Louviere (1992).
Louviere, Flynn e Marley (2015) consolidaram a teoria. A vantagem sobre o Likert é que não dá para marcar tudo como
"muito importante": o respondente é obrigado a escolher.

## Condição de uso
Método geral de pesquisa. Uso livre, citando a fonte (segundo o documento de métodos; não verificado na fonte).

## Versão em português
Não se aplica: é um método de coleta e análise.

## Perguntas em aberto
- A obra de Louviere e Woodworth (1990) é citada no texto do documento, mas não consta nas referências. Qual é a
  referência completa?
- Qual é o tamanho padrão dos conjuntos (4 ou 5) e o número mínimo de aparições por item? O documento diz "em geral" e
  "geralmente".
- Como o gerador de conjuntos garante o balanceamento quando o número de itens não se divide bem? O documento só
  descreve o caso simples.
- A plataforma faz a análise por modelo (logit, bayesiano) ou só a contagem e a exportação das escolhas?
- Dependência de biblioteca para o gerador ou o modelo: precisa estar registrada no plano.

## Referências
- FINN, A.; LOUVIERE, J. J. Determining the appropriate response to evidence of public concern: the case of food
  safety. *Journal of Public Policy & Marketing*, v. 11, n. 2, p. 12-25, 1992. DOI: 10.1177/074391569201100202.
- LOUVIERE, J. J.; FLYNN, T. N.; MARLEY, A. A. J. *Best-worst scaling*: theory, methods and applications. Cambridge:
  Cambridge University Press, 2015. DOI: 10.1017/CBO9781107337855.
- McFADDEN, D. Conditional logit analysis of qualitative choice behavior. In: ZAREMBKA, P. (ed.). *Frontiers in
  econometrics*. New York: Academic Press, 1974. p. 105-142. (Capítulo; DOI não localizado.)
- THURSTONE, L. L. A law of comparative judgment. *Psychological Review*, v. 34, n. 4, p. 273-286, 1927.
  DOI: 10.1037/h0070288.
