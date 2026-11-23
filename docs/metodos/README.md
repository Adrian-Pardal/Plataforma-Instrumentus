---
titulo: Métodos de pesquisa
proposito: Indexar uma ficha por método de pesquisa suportado pela plataforma
status: vigente
atualizado: 2026-11-22
mantido-por: /novo-metodo
relacionados: [../README.md, ../adr/0004-plataforma-multi-metodo-instrumentus.md]
---

# Métodos de pesquisa

**Esta pasta responde:** como cada método de pesquisa da plataforma funciona e calcula?

Cada ficha traz: como funciona, regras para o código, teste de referência, fundamentação, condição de uso,
versão em português, perguntas em aberto e referências (ABNT, com DOI quando houver).

A fonte das fichas é o documento "Métodos de pesquisa da plataforma" (20 nov. 2026) e a tabela de etapas do guia.
O que não veio da fonte aparece como "a definir" ou "não verificado"; nada foi completado de memória.

## Níveis
1 — Básico: um tipo de pergunta e cálculo simples. 2 — Intermediário: itens fixos, subescalas ou fórmula própria.
3 — Avançado: várias etapas ou rodadas, algoritmos ou estatística mais pesada.

## Tabela dos métodos

Status: todos "não implementado" até existir spec e código. Etapa: ordem de entrega sugerida no guia (4.2 define a final).

| Ficha | Nível | Tema | Etapa | Status | Versão do instrumento | Condição de uso |
|---|---|---|---|---|---|---|
| [likert.md](likert.md) | 1 | Uso geral | 1 | não implementado | não se aplica | Uso livre, citando a fonte |
| [multipla-escolha-e-caixas.md](multipla-escolha-e-caixas.md) | 1 | Uso geral | 1 | não implementado | não se aplica | Uso livre, citando a fonte |
| [escala-numerica.md](escala-numerica.md) | 1 | Uso geral | 1 | não implementado | não se aplica | Uso livre, citando a fonte |
| [perguntas-abertas.md](perguntas-abertas.md) | 1 | Uso geral | 1 | não implementado | não se aplica | Uso livre, citando a fonte |
| [matriz-de-itens.md](matriz-de-itens.md) | 1 | Uso geral | 2 | não implementado | não se aplica | Uso livre, citando a fonte |
| [diferencial-semantico.md](diferencial-semantico.md) | 1 | Uso geral | 2 | não implementado | não se aplica | Uso livre, citando a fonte |
| [vas.md](vas.md) | 1 | Uso geral | 2 | não implementado | não se aplica | Uso livre, citando a fonte |
| [aim-iam-fim.md](aim-iam-fim.md) | 1 | Saúde e ciência da implementação | 1 | não implementado | Weiner et al., 2017 | Medidas abertas, segundo os autores; citar a fonte (ver ficha) |
| [vas-dor.md](vas-dor.md) | 1 | Saúde e ciência da implementação | 2 | não implementado | a definir | Uso livre, citando a fonte |
| [csat.md](csat.md) | 1 | Empresarial e mercado | 2 | não implementado | a definir | Uso livre, citando a fonte |
| [ces.md](ces.md) | 1 | Empresarial e mercado | 2 | não implementado | 1.0 (2010) e 2.0 (2013); gravar qual | Uso livre, citando a fonte |
| [probabilidade-de-recomendacao.md](probabilidade-de-recomendacao.md) | 1 | Empresarial e mercado | 2 | não implementado | a definir | Nome é marca registrada de terceiros (a plataforma não o usa); cálculo não confirmado como livre (ver ficha) |
| [seq.md](seq.md) | 1 | Software e UX | 2 | não implementado | a definir | Uso livre, citando a fonte |
| [umux-lite.md](umux-lite.md) | 1 | Software e UX | 2 | não implementado | a definir (tradução dos itens é livre) | Uso livre, citando a fonte |
| [ranking.md](ranking.md) | 2 | Uso geral | 4 | não implementado | não se aplica | Uso livre, citando a fonte |
| [comparacao-pareada.md](comparacao-pareada.md) | 2 | Uso geral | 4 | não implementado | não se aplica | Uso livre, citando a fonte |
| [pre-e-pos-teste.md](pre-e-pos-teste.md) | 2 | Uso geral | 4 | não implementado | não se aplica | Uso livre, citando a fonte |
| [ivc.md](ivc.md) | 2 | Uso geral | 4 | não implementado | não se aplica | Uso livre, citando a fonte |
| [alfa-de-cronbach.md](alfa-de-cronbach.md) | 2 | Uso geral | 2 | não implementado | não se aplica | Uso livre, citando a fonte |
| [tfa.md](tfa.md) | 2 | Saúde e ciência da implementação | 1 | não implementado | Questionário genérico, 2022 (8 itens; prospectivo e retrospectivo) | Artigo em CC BY 4.0; questionário a conferir (ver ficha) |
| [phq-9.md](phq-9.md) | 2 | Saúde e ciência da implementação | 3 | não implementado | a definir | Gratuito segundo o site; tradução, titular e citação não confirmados (ver ficha) |
| [gad-7.md](gad-7.md) | 2 | Saúde e ciência da implementação | 3 | não implementado | a definir | Gratuito segundo o site; tradução, titular e citação não confirmados (ver ficha) |
| [avaliacao-360.md](avaliacao-360.md) | 2 | Empresarial e mercado | 4 | não implementado | a definir | Uso livre, citando a fonte |
| [sus.md](sus.md) | 2 | Software e UX | 1 | não implementado | a definir | Uso livre, citando a fonte |
| [ueq.md](ueq.md) | 2 | Software e UX | 3 | não implementado | UEQ (26 itens) e UEQ-S (8 itens) | Gratuito segundo o site; licença e citação não constam (ver ficha) |
| [tam-utaut.md](tam-utaut.md) | 2 | Software e UX | 3 | não implementado | a definir | Uso livre, citando a fonte |
| [nasa-tlx.md](nasa-tlx.md) | 2 | Software e UX | 3 | não implementado | Sem pesos (Raw TLX) | Sem pedir permissão à NASA, inclusive para traduzir (verificado na página) |
| [maxdiff.md](maxdiff.md) | 3 | Uso geral | 5 | não implementado | não se aplica | Uso livre, citando a fonte |
| [metodologia-q.md](metodologia-q.md) | 3 | Uso geral | 5 | não implementado | não se aplica | Uso livre, citando a fonte |
| [delphi.md](delphi.md) | 3 | Uso geral | 5 | não implementado | não se aplica | Uso livre, citando a fonte |

"Uso livre, citando a fonte" vem do documento de métodos e não foi conferido na fonte oficial. A verificação é
parcial: as linhas acima que dizem outra coisa foram lidas na fonte, e cada ficha detalha o que foi e o que não foi
confirmado na seção "Condição de uso". Antes de reproduzir os itens de qualquer questionário, confirme a licença dele.

Não confundir com o [estudo de caso](../estudo-de-caso/README.md), que mede o desenvolvimento do próprio projeto.

**Mantida por:** `/novo-metodo` (a criar).
