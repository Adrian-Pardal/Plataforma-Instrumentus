---
titulo: Ficha do método TFA (Aceitabilidade)
proposito: Dizer como o TFA funciona, como a plataforma calcula e de onde vem a regra
status: rascunho
atualizado: 2026-11-22
mantido-por: manual
relacionados: [README.md, ../adr/0004-plataforma-multi-metodo-instrumentus.md]
---

# TFA (Theoretical Framework of Acceptability)

Nível 2 · Saúde e ciência da implementação · Etapa 1 · Status: não implementado.
Texto da fonte "Métodos de pesquisa da plataforma"; só os metadados das referências foram conferidos no Crossref.

## Como funciona
O questionário genérico tem 8 itens numa escala de 5 pontos: um para cada um dos 7 construtos e um item geral de
aceitabilidade.

| Construto | O que mede |
|---|---|
| Atitude afetiva | Como a pessoa se sente em relação à intervenção |
| Carga | Quanto esforço a participação exige |
| Ética | O quanto a intervenção combina com os valores da pessoa |
| Coerência da intervenção | O quanto a pessoa entende como a intervenção funciona |
| Custo de oportunidade | Do que a pessoa precisa abrir mão para participar |
| Efetividade percebida | O quanto acredita que a intervenção atinge o objetivo |
| Autoeficácia | O quanto se sente capaz de fazer o que a intervenção pede |

Há duas versões: prospectiva (antes de participar) e retrospectiva (depois).

## Regras para o código
- O resultado é por construto (os 7 mais o item geral); nunca somado num escore único.
- Guardar a resposta bruta; a inversão acontece só na análise.
- Carga e custo de oportunidade: nota alta significa menos aceitável, então invertem (6 − resposta) para que nota
  alta signifique mais aceitável em todos os construtos.
- Guardar a versão do instrumento (prospectiva ou retrospectiva) em cada resposta.

## Teste de referência
Dados fictícios: 5 participantes, versão retrospectiva (1 a 5).

| Construto | Respostas brutas | Após inversão | Média | % favorável (4 ou 5) |
|---|---|---|---|---|
| Atitude afetiva | 4, 5, 4, 3, 5 | – | 4,2 | 80% |
| Carga | 2, 1, 4, 2, 3 | 4, 5, 2, 4, 3 | 3,6 | 60% |
| Custo de oportunidade | 1, 2, 2, 1, 3 | 5, 4, 4, 5, 3 | 4,2 | 80% |
| Efetividade percebida | 3, 4, 4, 4, 5 | – | 4,0 | 80% |

## Fundamentação
Sekhon, Cartwright e Francis (2017) fizeram uma revisão de revisões, concluíram que não havia definição comum de
aceitabilidade e propuseram o TFA: um construto com várias faces, que reflete o quanto as pessoas consideram a
intervenção adequada, com base em reações cognitivas e emocionais antecipadas ou vividas. Em 2022, os mesmos autores
publicaram o questionário genérico, desenvolvido em etapas de pré-validação, em acesso aberto.

## Condição de uso
Licença CC BY 4.0 (conferida na licença do artigo de 2022, via Crossref): pode usar e adaptar citando a fonte.
Citar Sekhon, Cartwright e Francis (2022).

## Versão em português
Não encontrada na busca feita em 2026-11-22 (Crossref, buscas em inglês e português). Não equivale a "não existe";
conferir no PubMed e SciELO antes de publicar resultados.

## Perguntas em aberto
- Quais itens do questionário são invertidos? O documento diz carga e custo de oportunidade, mas manda conferir as
  âncoras na versão usada. Confirmar no material suplementar do artigo de 2022 antes de implementar.
- Os autores definem ponto de corte? A fonte não diz. Sem ele, a plataforma não rotula ("aceitável"/"inaceitável").
- O "% favorável (4 ou 5)" é critério dos autores ou escolha do documento de métodos? A fonte não esclarece.
- Existe versão validada em português? Busca inicial sem resultado.

## Referências
- SEKHON, M.; CARTWRIGHT, M.; FRANCIS, J. J. Acceptability of healthcare interventions: an overview of reviews and
  development of a theoretical framework. *BMC Health Services Research*, v. 17, n. 88, 2017.
  DOI: 10.1186/s12913-017-2031-8.
- SEKHON, M.; CARTWRIGHT, M.; FRANCIS, J. J. Development of a theory-informed questionnaire to assess the
  acceptability of healthcare interventions. *BMC Health Services Research*, v. 22, n. 279, 2022.
  DOI: 10.1186/s12913-022-07577-3.
