---
titulo: Ficha do método SUS (System Usability Scale)
proposito: Dizer como o SUS funciona, como a plataforma calcula e de onde vem a regra
status: rascunho
atualizado: 2026-11-22
mantido-por: manual
relacionados: [README.md]
---

# SUS (System Usability Scale)

Nível 2 · Software e UX · Etapa 1 · Status: não implementado.
Texto da fonte "Métodos de pesquisa da plataforma"; as referências foram conferidas no Crossref.

## Como funciona
São 10 itens numa escala de 1 (discordo totalmente) a 5 (concordo totalmente), alternando afirmações positivas
(itens ímpares) e negativas (itens pares). O escore vai de 0 a 100:

    SUS = 2,5 × [ Σ(ímpares: resposta − 1) + Σ(pares: 5 − resposta) ]

O escore não é uma porcentagem. Segundo o documento, a média de referência é 68 e, para Bangor, Kortum e Miller
(2009), em torno de 71 corresponde a "bom" e em torno de 85 a "excelente".

## Regras para o código
- Guardar a resposta bruta; a conversão (ímpar: r − 1; par: 5 − r) acontece só na análise.
- O SUS só é calculado com os 10 itens respondidos; com item faltando o escore fica vazio.
- A ordem dos itens não pode ser embaralhada: a fórmula depende da posição (ímpar ou par).
- Não exibir o escore como porcentagem.

## Teste de referência
Respostas aos 10 itens (1 a 5): 4, 2, 5, 1, 4, 2, 5, 2, 4, 1.

| | Itens | Respostas | Conversão | Pontos |
|---|---|---|---|---|
| Ímpares | 1, 3, 5, 7, 9 | 4, 5, 4, 5, 4 | resposta − 1 | 3 + 4 + 3 + 4 + 3 = 17 |
| Pares | 2, 4, 6, 8, 10 | 2, 1, 2, 2, 1 | 5 − resposta | 3 + 4 + 3 + 3 + 4 = 17 |

SUS = (17 + 17) × 2,5 = 85,0.

## Fundamentação
Brooke (1996) criou o SUS em 1986 na Digital Equipment Corporation como uma medida "rápida e suja" (*quick and
dirty*) de usabilidade percebida. Bangor, Kortum e Miller (2008) analisaram milhares de aplicações do SUS em dezenas
de estudos e confirmaram a boa confiabilidade. Lewis (2018) revisou 30 anos de pesquisa e concluiu que o SUS
continua sendo o questionário de usabilidade mais usado.

## Condição de uso
Uso livre, citando a fonte, segundo o documento de métodos. **Não verificado** em fonte oficial: nem o artigo da
versão brasileira nem as demais fontes lidas afirmam isso (a licença CC BY 4.0 da página da revista vale para o
artigo, não para o SUS).

## Versão em português
Há uma adaptação transcultural para o português do Brasil: Lourenço, Valentim e Lopes (2022), publicada na revista
*Aquichan* (alfa de Cronbach de 0,76, amostra de 100 estudantes que avaliaram o WhatsApp). É uma adaptação com
amostra pequena, e não uma validação ampla. Outras versões em português podem existir; não foram buscadas.

## Perguntas em aberto
- O SUS é de uso livre? Confirmar com uma fonte oficial antes de reproduzir os itens.
- De onde vem a média de referência 68? Não está nas referências do documento.
- A redação dos itens em português: usar a versão de Lourenço et al. (2022) ou outra? Esta ficha não reproduz itens.
- A versão de Lourenço et al. basta para publicação, dado o tamanho da amostra? Decisão do pesquisador; a
  plataforma deve citar a versão usada.
- O título do artigo brasileiro: a página da revista o registra em espanhol; conferir o título no PDF em português.

## Referências
- BROOKE, J. SUS: a "quick and dirty" usability scale. In: JORDAN, P. W. et al. (ed.). *Usability evaluation in
  industry*. London: Taylor & Francis, 1996. p. 189-194. (Capítulo, sem DOI encontrado.)
- BANGOR, A.; KORTUM, P. T.; MILLER, J. T. An empirical evaluation of the System Usability Scale. *International
  Journal of Human-Computer Interaction*, v. 24, n. 6, p. 574-594, 2008. DOI: 10.1080/10447310802205776.
- BANGOR, A.; KORTUM, P.; MILLER, J. Determining what individual SUS scores mean: adding an adjective rating scale.
  *Journal of Usability Studies*, v. 4, n. 3, p. 114-123, 2009. (A revista não usa DOI.)
- LEWIS, J. R. The System Usability Scale: past, present, and future. *International Journal of Human-Computer
  Interaction*, v. 34, n. 7, p. 577-590, 2018. DOI: 10.1080/10447318.2018.1455307.
- LOURENÇO, D. F.; VALENTIM, E. C.; LOPES, M. H. B. M. Traducción y adaptación transcultural de la System Usability
  Scale al portugués de Brasil. *Aquichan*, v. 22, n. 2, e2228, 2022. DOI: 10.5294/aqui.2022.22.2.8.
