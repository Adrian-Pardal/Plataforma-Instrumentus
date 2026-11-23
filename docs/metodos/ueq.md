---
titulo: Ficha do método UEQ e UEQ-S (User Experience Questionnaire)
proposito: Dizer como o UEQ e o UEQ-S funcionam, como a plataforma calcula e o que ainda precisa ser conferido
status: rascunho
atualizado: 2026-11-22
mantido-por: manual
relacionados: [README.md, diferencial-semantico.md, sus.md]
---

# UEQ e UEQ-S (User Experience Questionnaire)

Nível 2 · Software e UX · Etapa 3 · Status: não implementado.
Texto da fonte "Métodos de pesquisa da plataforma"; a página oficial do UEQ foi lida em 2026-11-22 e as referências
foram conferidas no Crossref quando têm DOI. Esta ficha não reproduz os itens.

## Como funciona
O UEQ tem 26 pares de adjetivos opostos (diferencial semântico de 7 pontos, ver [diferencial-semantico.md](diferencial-semantico.md)),
pontuados de −3 a +3 e agrupados em 6 escalas:

| Escala | Itens | O que mede |
|---|---|---|
| Atratividade | 6 | Impressão geral: gosta ou não do produto |
| Perspicuidade | 4 | Facilidade de entender e aprender |
| Eficiência | 4 | Rapidez para fazer as tarefas |
| Confiabilidade | 4 | Sensação de controle e segurança |
| Estimulação | 4 | Se é interessante e motivador usar |
| Novidade | 4 | Se é inovador e criativo |

Segundo o documento, médias acima de +0,8 indicam avaliação positiva e abaixo de −0,8, negativa. O UEQ-S é a versão
curta, com 8 itens e duas escalas: qualidade pragmática e qualidade hedônica. O site oferece o questionário em mais
de 30 idiomas, uma planilha de análise (também para o UEQ-S) e o manual.

## Regras para o código
- Cadastrar, em cada item, a escala a que pertence e o lado do polo positivo, usando a tabela oficial do manual.
- Conversão: polo positivo à direita, valor = resposta − 4; polo positivo à esquerda, valor = 4 − resposta.
- Média por escala; no UEQ-S, média das duas escalas para a nota geral (segundo o documento).
- Guardar a resposta bruta e a versão (UEQ ou UEQ-S).

## Teste de referência
Escala Perspicuidade de um respondente (4 itens; "dir." = polo positivo à direita, "esq." = à esquerda):

| Item | Polo positivo | Resposta (1 a 7) | Valor (−3 a +3) |
|---|---|---|---|
| A | dir. | 6 | 6 − 4 = +2 |
| B | esq. | 2 | 4 − 2 = +2 |
| C | dir. | 7 | +3 |
| D | esq. | 3 | 4 − 3 = +1 |

Perspicuidade = (2 + 2 + 3 + 1) / 4 = +2,0 (acima de +0,8). UEQ-S: com qualidade pragmática = +1,5 e hedônica = 0,0,
a nota geral é (1,5 + 0,0) / 2 = +0,75.

## Fundamentação
Baseia-se na distinção de Hassenzahl (2003) entre qualidade pragmática (o produto ajuda a cumprir tarefas:
perspicuidade, eficiência, confiabilidade) e qualidade hedônica (o produto é agradável e estimulante: estimulação,
novidade). Laugwitz, Held e Schrepp (2008) construíram o UEQ a partir de um conjunto grande de adjetivos, selecionados
por especialistas e reduzidos por análise fatorial. Schrepp, Hinderks e Thomaschewski (2017) criaram a versão curta.

## Condição de uso
Gratuito, segundo o site oficial: "Everything is completely free of charge" (inclui manual, questionário e
ferramentas de análise). Licença formal, restrição comercial e instrução de como citar **não constam** na página
inicial; o Aviso Legal do site não foi lido.

## Versão em português
O site lista "Portuguese" entre os idiomas, com os autores Manuel Pérez Cota e Ramiro Gonçalves. A variante (Brasil
ou Portugal) e se houve validação **não são informadas** na página.

## Perguntas em aberto
- Qual é a variante do português e há estudo de validação? O site não diz.
- O que o Aviso Legal do site diz sobre licença, reprodução e citação? Não foi lido.
- O limite de ±0,8 vem do manual oficial? É do documento; conferir no manual.
- O benchmark de comparação não é oferecido para baixar no site; a plataforma o inclui ou só cita o artigo?
- A tabela oficial de itens, escalas e polos está no manual e não nesta ficha; a plataforma a cadastra a partir dele.

## Referências
- LAUGWITZ, B.; HELD, T.; SCHREPP, M. Construction and evaluation of a user experience questionnaire. In:
  HOLZINGER, A. (ed.). *HCI and usability for education and work*. Berlin: Springer, 2008. p. 63-76. (Lecture Notes in
  Computer Science, 5298). DOI: 10.1007/978-3-540-89350-9_6.
- SCHREPP, M.; HINDERKS, A.; THOMASCHEWSKI, J. Design and evaluation of a short version of the User Experience
  Questionnaire (UEQ-S). *International Journal of Interactive Multimedia and Artificial Intelligence*, v. 4, n. 6,
  p. 103-108, 2017. DOI: 10.9781/ijimai.2017.09.001.
- HASSENZAHL, M. The thing and I: understanding the relationship between user and product. In: BLYTHE, M. A. et al.
  (ed.). *Funology*: from usability to enjoyment. Dordrecht: Kluwer, 2003. p. 31-42. DOI: 10.1007/1-4020-2967-5_4.
- UEQ TEAM. *User Experience Questionnaire*. Disponível em: https://www.ueq-online.org/. Acesso em: 22 nov. 2026.
