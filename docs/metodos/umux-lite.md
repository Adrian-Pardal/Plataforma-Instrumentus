---
titulo: Ficha do método UMUX-Lite
proposito: Dizer como o UMUX-Lite funciona, como a plataforma calcula e o que ainda precisa ser conferido
status: rascunho
atualizado: 2026-11-22
mantido-por: manual
relacionados: [README.md, sus.md]
---

# UMUX-Lite

Nível 1 · Software e UX · Etapa 2 · Status: não implementado.
Texto da fonte "Métodos de pesquisa da plataforma"; as referências foram conferidas no Crossref.

## Como funciona
Dois itens, numa escala de 1 (discordo totalmente) a 7 (concordo totalmente): um sobre as funcionalidades atenderem
às necessidades (utilidade) e outro sobre a facilidade de uso. O escore vai de 0 a 100. Para comparar com o SUS,
aplica-se a regressão proposta pelos autores:

    UMUX-Lite = ((i1 − 1) + (i2 − 1)) / 12 × 100
    UMUX-Lite ajustado = 0,65 × UMUX-Lite + 22,9

Esta ficha não reproduz a redação dos itens.

## Regras para o código
- O 12 no denominador é a soma máxima possível (6 + 6).
- Mostrar os dois valores com rótulos diferentes; usar o ajustado só para comparar com o SUS ([sus.md](sus.md)).
- Guardar a resposta bruta.

## Teste de referência
Um respondente marcou 6 no item 1 e 5 no item 2:
- UMUX-Lite = ((6 − 1) + (5 − 1)) / 12 × 100 = 9 / 12 × 100 = 75,0
- Ajustado para a escala do SUS = 0,65 × 75,0 + 22,9 = 48,75 + 22,9 = 71,65

## Fundamentação
Deriva do UMUX, de Finstad (2010), um questionário de 4 itens baseado na definição de usabilidade da norma ISO 9241-11
(eficácia, eficiência e satisfação). Lewis, Utesch e Maher (2013) ficaram só com os dois itens positivos, que
correspondem aos dois construtos do TAM: utilidade e facilidade de uso. Segundo o documento, o resultado teve
correlação de 0,81 com o SUS, o que o torna um substituto quando não há tempo para os 10 itens.

## Condição de uso
Uso livre, citando a fonte (segundo o documento de métodos; não verificado na fonte).

## Versão em português
Não encontrada na busca de 2026-11-22 (Crossref). O documento avisa que a tradução dos itens que ele traz é livre e
que, para publicação, convém procurar uma versão validada em português.

## Perguntas em aberto
- Os coeficientes 0,65 e 22,9 vêm do documento e não foram conferidos no artigo de Lewis et al. (2013).
- A correlação de 0,81 com o SUS também não foi conferida no artigo.
- Existe versão validada em português? Busca inicial sem resultado.
- Qual é a redação oficial dos itens e se há restrição para reproduzi-los? Esta ficha não a reproduz.

## Referências
- FINSTAD, K. The usability metric for user experience. *Interacting with Computers*, v. 22, n. 5, p. 323-327, 2010.
  DOI: 10.1016/j.intcom.2010.04.004.
- LEWIS, J. R.; UTESCH, B. S.; MAHER, D. E. UMUX-LITE: when there's no time for the SUS. In: CHI CONFERENCE ON HUMAN
  FACTORS IN COMPUTING SYSTEMS, 2013, Paris. *Proceedings* [...]. New York: ACM, 2013. p. 2099-2102.
  DOI: 10.1145/2470654.2481287.
