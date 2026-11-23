---
titulo: Ficha do método NASA-TLX sem pesos (Raw TLX)
proposito: Dizer como o NASA-TLX sem pesos funciona, como a plataforma calcula e o que a fonte oficial não confirma
status: rascunho
atualizado: 2026-11-22
mantido-por: manual
relacionados: [README.md]
---

# NASA-TLX sem pesos (Raw TLX)

Nível 2 · Software e UX · Etapa 3 · Status: não implementado.
Texto da fonte "Métodos de pesquisa da plataforma"; a página da NASA foi lida em 2026-11-22 (atualizada em 2026-03-11;
a própria página diz que não é mantida ativamente) e as referências foram conferidas no Crossref.

## Como funciona
Logo depois de uma tarefa, o participante avalia 6 dimensões da carga de trabalho, cada uma numa escala de 0 a 100
(marcada em 21 pontos, de 5 em 5): demanda mental, demanda física, demanda temporal, desempenho, esforço e frustração.
Na versão sem pesos, o escore é a média simples das 6. A escala de desempenho vai de "perfeito" (0) a "fracasso" (100),
então, em todas as dimensões, número maior significa mais carga.

## Regras para o código
- A marca *k* (de 0 a 20) vale 5 × *k*; guardar o valor de 0 a 100.
- Escore = média simples das 6 dimensões.
- O relatório mostra também o perfil das 6 dimensões, porque a média esconde de onde vem a carga.
- Guardar a resposta bruta.

## Teste de referência
Um participante:

| Dimensão | Mental | Física | Temporal | Desempenho | Esforço | Frustração |
|---|---|---|---|---|---|---|
| Valor (0 a 100) | 70 | 10 | 55 | 30 | 65 | 40 |

Raw TLX = (70 + 10 + 55 + 30 + 65 + 40) / 6 = 270 / 6 = 45,0. A carga vem sobretudo da demanda mental e do esforço.

## Fundamentação
Hart e Staveland (1988) desenvolveram o índice na NASA Ames a partir da ideia de que carga de trabalho é uma
experiência subjetiva com várias dimensões, e não um número único. A versão original pondera as 6 dimensões com 15
comparações em pares (Nível 3). Hart (2006) revisou 20 anos de uso e relatou, segundo o documento, que a versão sem
pesos é muito usada; nos estudos que a compararam com a original, os resultados foram ora equivalentes, ora um pouco
diferentes.

## Condição de uso
Verificado na página da NASA: a ferramenta é "open source" e "it is not necessary to obtain permission from NASA to
use TLX", inclusive para modificá-la e traduzi-la. A página não traz licença formal. Citar Hart e Staveland (1988).

## Versão em português
Não encontrada na busca de 2026-11-22 (Crossref). A NASA permite a tradução. Não equivale a "não existe".

## Perguntas em aberto
- A página da NASA descreve só a versão ponderada; a versão sem pesos e a afirmação sobre o seu uso vêm do documento
  (via Hart, 2006) e não foram conferidas.
- A escala de 0 a 100 em 21 pontos não aparece na página; está no manual em papel (PDF), que não foi lido.
- A rotulagem exata das dimensões em português: usar tradução própria ou procurar uma versão adaptada?

## Referências
- HART, S. G.; STAVELAND, L. E. Development of NASA-TLX (Task Load Index): results of empirical and theoretical
  research. In: HANCOCK, P. A.; MESHKATI, N. (ed.). *Human mental workload*. Amsterdam: North-Holland, 1988.
  p. 139-183. DOI: 10.1016/S0166-4115(08)62386-9.
- HART, S. G. NASA-Task Load Index (NASA-TLX); 20 years later. In: HUMAN FACTORS AND ERGONOMICS SOCIETY ANNUAL
  MEETING, 50., 2006. *Proceedings* [...]. Santa Monica: HFES, 2006. p. 904-908. DOI: 10.1177/154193120605000909.
- NASA. *NASA Task Load Index (TLX)*. Disponível em:
  https://www.nasa.gov/human-systems-integration-division/nasa-task-load-index-tlx/. Acesso em: 22 nov. 2026.
