---
titulo: Ficha do método Técnica Delphi
proposito: Dizer como o Delphi funciona, como a plataforma controla as rodadas e calcula o consenso
status: rascunho
atualizado: 2026-11-22
mantido-por: manual
relacionados: [README.md, ../requisitos/anonimato-e-ligacao-de-respostas.md]
---

# Técnica Delphi

Nível 3 · Uso geral · Etapa 5 · Status: não implementado.
Texto da fonte "Métodos de pesquisa da plataforma"; os números do exemplo foram recalculados (concordância, mediana e
quartis) e as referências foram conferidas no Crossref quando têm DOI.

## Como funciona
Um painel de especialistas responde, de forma anônima, a várias rodadas do mesmo questionário:
1. **Rodada 1:** perguntas abertas para levantar itens, ou avaliação de uma lista inicial (por exemplo, concordância
   de 1 a 5 com cada item).
2. **Devolutiva:** cada especialista recebe o resultado do grupo (mediana, intervalo interquartil, porcentagem de
   concordância e comentários anônimos) e a própria resposta anterior.
3. **Rodadas seguintes:** cada um reavalia os itens sem consenso, podendo mudar de opinião ou justificar por que mantém.
4. **Encerramento:** quando os itens atingem o critério de consenso definido antes do início, ou quando as respostas
   param de mudar. Costumam ser 2 a 4 rodadas.

O critério mais comum é a porcentagem de concordância, e a mediana dos limites usados na literatura é 75% (Diamond et
al., 2014, segundo o documento).

## Regras para o código
- O critério de consenso e o número máximo de rodadas são configurados antes do início e ficam travados depois.
- Guardar a resposta de cada especialista entre as rodadas, sem revelar quem respondeu o quê.
- Quem não respondeu uma rodada é registrado; o denominador é quem respondeu naquela rodada.
- Os quartis são calculados sempre pelo mesmo método (aqui, o inclusivo, padrão do QUARTIL do Excel).
- Na devolutiva, mostrar mediana, intervalo interquartil, porcentagem de concordância e a própria nota anterior.

## Teste de referência
Painel de 12 especialistas avaliando um item (1 a 5), com critério de consenso de 75% de notas 4 ou 5, definido antes
da rodada 1:

| Rodada | Notas 5 / 4 / 3 / 2 / 1 | Concordância (4 ou 5) | Mediana | Intervalo interquartil | Resultado |
|---|---|---|---|---|---|
| 1 | 4 / 4 / 2 / 1 / 1 | 8 / 12 = 66,7% | 4 | 3 a 5 | sem consenso, volta |
| 2 | 5 / 5 / 2 / 0 / 0 | 10 / 12 = 83,3% | 4 | 4 a 5 | consenso |

## Fundamentação
Dalkey e Helmer (1963) criaram o método na RAND Corporation para fazer previsões com especialistas sem os problemas
das reuniões presenciais, como a influência de quem fala mais alto ou tem mais prestígio. As quatro características
que o definem são anonimato, iteração, devolutiva controlada e resposta estatística do grupo (Linstone; Turoff,
1975). Hasson, Keeney e McKenna (2000) adaptaram as diretrizes para a pesquisa em saúde. Diamond et al. (2014)
mostraram que muitos estudos não definem o critério de consenso antes de começar, e o guia CREDES (Jünger et al.,
2017) dá recomendações para conduzir e relatar o estudo.

## Condição de uso
Método geral de pesquisa. Uso livre, citando a fonte (segundo o documento de métodos; não verificado na fonte).

## Versão em português
Não se aplica: é um método de coleta e análise.

## Perguntas em aberto
- **Anonimato e ligação de respostas:** o método exige ligar as respostas de cada especialista entre as rodadas.
  Como isso convive com "respostas anônimas"? Ver [anonimato-e-ligacao-de-respostas.md](../requisitos/anonimato-e-ligacao-de-respostas.md).
- Como os especialistas são convidados e como recebem acesso a cada nova rodada sem serem identificados?
- A mediana de 75% vem de Diamond et al. (2014) pelo documento; não foi conferida no artigo.
- O encerramento por "respostas que param de mudar" tem critério numérico? O documento não define.
- A rodada 1 aberta exige codificação das respostas (ver [perguntas-abertas.md](perguntas-abertas.md)); a plataforma
  oferece algum apoio?

## Referências
- DALKEY, N.; HELMER, O. An experimental application of the Delphi method to the use of experts. *Management
  Science*, v. 9, n. 3, p. 458-467, 1963. DOI: 10.1287/mnsc.9.3.458.
- LINSTONE, H. A.; TUROFF, M. (ed.). *The Delphi method*: techniques and applications. Reading: Addison-Wesley,
  1975. (Livro; DOI não verificado.)
- HASSON, F.; KEENEY, S.; McKENNA, H. Research guidelines for the Delphi survey technique. *Journal of Advanced
  Nursing*, v. 32, n. 4, p. 1008-1015, 2000. DOI: 10.1046/j.1365-2648.2000.t01-1-01567.x.
- DIAMOND, I. R. et al. Defining consensus: a systematic review recommends methodologic criteria for reporting of
  Delphi studies. *Journal of Clinical Epidemiology*, v. 67, n. 4, p. 401-409, 2014.
  DOI: 10.1016/j.jclinepi.2013.12.002.
- JÜNGER, S. et al. Guidance on Conducting and REporting DElphi Studies (CREDES) in palliative care:
  recommendations based on a methodological systematic review. *Palliative Medicine*, v. 31, n. 8, p. 684-706, 2017.
  DOI: 10.1177/0269216317690685.
