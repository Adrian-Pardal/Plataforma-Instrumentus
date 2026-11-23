---
titulo: Ficha do método Escala Likert
proposito: Dizer como a escala Likert funciona, como a plataforma calcula e de onde vem a regra
status: rascunho
atualizado: 2026-11-22
mantido-por: manual
relacionados: [README.md]
---

# Escala Likert

Nível 1 · Uso geral · Etapa 1 · Status: não implementado.
Texto da fonte "Métodos de pesquisa da plataforma"; as referências foram conferidas no Crossref quando têm DOI.

## Como funciona
O respondente lê uma afirmação e indica o grau de concordância numa escala ordenada, em geral de 5 ou 7 pontos
("discordo totalmente" a "concordo totalmente"). Cada item recebe um número; vários itens sobre o mesmo tema são
somados ou tirados pela média, formando um escore. Itens escritos no sentido contrário têm a pontuação invertida
antes da soma.

## Regras para o código
- Guardar a resposta bruta; calcular a invertida só na análise.
- Inversão: valor invertido = (mínimo + máximo) − resposta (em 1 a 5, 6 − resposta).
- Definir um mínimo de itens respondidos para calcular o escore (por exemplo, 3 de 4); abaixo disso o escore fica vazio.

## Teste de referência
Escala de 4 itens (1 a 5); o item 3 está escrito no sentido contrário.

| Respondente | Itens 1 a 4 (brutos) | Item 3 invertido | Soma | Média |
|---|---|---|---|---|
| R1 | 4, 5, 2, 4 | 6 − 2 = 4 | 17 | 4,25 |
| R2 | 3, 4, 3, 4 | 6 − 3 = 3 | 14 | 3,50 |
| R3 | 2, 3, 4, 4 | 6 − 4 = 2 | 11 | 2,75 |

Média do grupo = (4,25 + 3,50 + 2,75) / 3 = 3,50.

## Fundamentação
Likert (1932) propôs medir atitudes somando respostas a várias afirmações, em vez de usar uma só pergunta: o erro
de cada item se dilui na soma. A rigor, "escala Likert" é o conjunto de itens somados; um item isolado é um "item
tipo Likert". Há um debate antigo sobre tratar os dados como ordinais (mediana, testes não paramétricos) ou
intervalares (média, testes paramétricos). Norman (2010) e Carifio e Perla (2007) defendem que, para escalas com
vários itens, os testes paramétricos são robustos.

## Condição de uso
Técnica geral de pesquisa, sem instrumento proprietário. Uso livre, citando a fonte (segundo o documento de métodos;
não verificado na fonte).

## Versão em português
Não se aplica: é um formato de pergunta, não um questionário com itens fixos. Instrumentos que usam Likert (TFA, SUS,
AIM/IAM/FIM) têm a sua própria ficha.

## Perguntas em aberto
- Qual é o mínimo padrão de itens respondidos para calcular o escore? O documento dá "3 de 4" só como exemplo.
- A plataforma mostra média, mediana ou as duas? O documento descreve o debate, mas não decide.

## Referências
- LIKERT, R. A technique for the measurement of attitudes. *Archives of Psychology*, v. 22, n. 140, p. 1-55, 1932.
  (Sem DOI encontrado.)
- CARIFIO, J.; PERLA, R. J. Ten common misunderstandings, misconceptions, persistent myths and urban legends about
  Likert scales and Likert response formats and their antidotes. *Journal of Social Sciences*, v. 3, n. 3,
  p. 106-116, 2007. DOI: 10.3844/jssp.2007.106.116.
- NORMAN, G. Likert scales, levels of measurement and the "laws" of statistics. *Advances in Health Sciences
  Education*, v. 15, n. 5, p. 625-632, 2010. DOI: 10.1007/s10459-010-9222-y.
