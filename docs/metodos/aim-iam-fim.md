---
titulo: Ficha do método AIM, IAM e FIM
proposito: Dizer como as três medidas de implementação funcionam, como a plataforma calcula e de onde vêm
status: rascunho
atualizado: 2026-11-22
mantido-por: manual
relacionados: [README.md, tfa.md]
---

# AIM, IAM e FIM

Nível 1 · Saúde e ciência da implementação · Etapa 1 · Status: não implementado.
Texto da fonte "Métodos de pesquisa da plataforma"; os termos de uso foram conferidos no texto aberto do artigo
(Europe PMC) e as referências, no Crossref.

## Como funciona
São três medidas independentes, com 4 itens cada, numa escala de 5 pontos (1 = "discordo totalmente" a
5 = "concordo totalmente"):
- **AIM** (*Acceptability of Intervention Measure*): aceitabilidade.
- **IAM** (*Intervention Appropriateness Measure*): adequação ao contexto.
- **FIM** (*Feasibility of Intervention Measure*): viabilidade.

O escore de cada medida é a média dos seus 4 itens (de 1 a 5). O pesquisador troca o termo genérico pelo nome do
que está sendo avaliado. As medidas podem ser usadas juntas ou separadas.

## Regras para o código
- Escore por medida = média dos 4 itens; cada medida é calculada e mostrada separadamente.
- No relatório do grupo: média, desvio-padrão e alfa de Cronbach de cada medida (ver [alfa-de-cronbach.md](alfa-de-cronbach.md)).
- Os autores não definem ponto de corte (segundo o documento): a plataforma não rotula o resultado como "aceitável"
  ou "inaceitável"; só mostra os escores.
- Guardar o nome da intervenção avaliada e a versão do instrumento.

## Teste de referência
Um respondente avaliou um programa de tutoria:

| Medida | Itens 1 a 4 | Escore (média) |
|---|---|---|
| AIM (aceitabilidade) | 4, 5, 4, 4 | 17 / 4 = 4,25 |
| IAM (adequação) | 3, 4, 4, 3 | 14 / 4 = 3,50 |
| FIM (viabilidade) | 5, 5, 4, 5 | 19 / 4 = 4,75 |

## Fundamentação
Vêm da ciência da implementação, área que estuda por que intervenções eficazes funcionam ou falham na prática.
Proctor et al. (2011) definiram oito desfechos de implementação, entre eles aceitabilidade, adequação e viabilidade.
Weiner et al. (2017) criaram e validaram as três medidas em três estudos; as escalas finais de 4 itens tiveram alfas
de Cronbach entre 0,85 e 0,91 (conferido no texto do artigo).

## Condição de uso
Uso livre, citando a fonte. Verificado no texto de Weiner et al. (2017): os autores tornaram as medidas "open access"
de propósito, para que fiquem "freely available to all". O artigo está sob CC BY 4.0 (a licença é do artigo; o texto
do artigo é a base para a afirmação sobre as medidas). Citar Weiner et al. (2017).

## Versão em português
Não encontrada na busca de 2026-11-22 (Crossref): só apareceram traduções para outros idiomas. Não equivale a
"não existe"; conferir no PubMed e SciELO antes de publicar.

## Perguntas em aberto
- A redação oficial dos itens e o que a tradução para o português exige: o artigo disponibiliza as medidas, mas a
  tradução própria precisaria ser validada. Esta ficha não reproduz os itens.
- Os autores definem ponto de corte? O documento diz que não; confirmar no artigo antes de implementar.
- Qual é a regra para item em branco numa medida de 4 itens? O documento não diz.
- Existe versão validada em português? Busca inicial sem resultado.

## Referências
- WEINER, B. J. et al. Psychometric assessment of three newly developed implementation outcome measures.
  *Implementation Science*, v. 12, n. 108, 2017. DOI: 10.1186/s13012-017-0635-3.
- PROCTOR, E. et al. Outcomes for implementation research: conceptual distinctions, measurement challenges, and
  research agenda. *Administration and Policy in Mental Health and Mental Health Services Research*, v. 38, n. 2,
  p. 65-76, 2011. DOI: 10.1007/s10488-010-0319-7.
