---
titulo: Ficha do método Probabilidade de recomendação
proposito: Dizer como a medida de recomendação (0 a 10) funciona, como a plataforma calcula e o que a marca registrada restringe
status: rascunho
atualizado: 2026-11-22
mantido-por: manual
relacionados: [README.md, csat.md]
---

# Probabilidade de recomendação (0–10)

Nível 1 · Empresarial e mercado · Etapa 2 · Status: não implementado.
Texto da fonte "Métodos de pesquisa da plataforma"; a página de marcas da Bain foi lida em 2026-11-22.

## Como funciona
Pergunta-se a probabilidade de a pessoa recomendar uma empresa ou produto a um amigo ou colega, de 0 a 10. Os
respondentes são divididos em três grupos: promotores (9 e 10), neutros (7 e 8) e detratores (0 a 6). O índice vai de
−100 a +100:

    Índice = % promotores − % detratores

Esta ficha não reproduz a redação da pergunta.

## Regras para o código
- O nome na interface e na documentação do produto é "Probabilidade de recomendação"; o nome comercial dessa métrica
  e a sigla, que são marcas registradas de terceiros, não aparecem na interface (ver Condição de uso).
- Os neutros entram no denominador, mas não na fórmula.
- Exibir o resultado como número inteiro de −100 a +100 ("+20"), nunca como porcentagem ("20%").
- Alertar para amostras pequenas: com 20 respostas, cada pessoa que passa de neutra para promotora muda o índice em
  5 pontos.

## Teste de referência
200 respostas de 0 a 10:

| Grupo | Notas | Respostas | % |
|---|---|---|---|
| Promotores | 9–10 | 90 | 45% |
| Neutros | 7–8 | 60 | 30% |
| Detratores | 0–6 | 50 | 25% |

Índice = 45 − 25 = +20.

## Fundamentação
Reichheld (2003) propôs que essa única pergunta prevê o crescimento de uma empresa melhor que pesquisas longas de
satisfação, porque recomendar algo põe a reputação de quem recomenda em jogo. A afirmação é contestada: Keiningham
et al. (2007) acompanharam empresas ao longo dos anos e não encontraram vantagem do índice sobre outras medidas de
satisfação para prever crescimento. Mesmo assim, é uma das métricas mais usadas no mercado.

## Condição de uso
Verificado na página da Bain (2026-11-22): o nome comercial dessa métrica e a sigla são marcas registradas, e o nome
por extenso também é marca de serviço, de Bain & Company, Inc., NICE Systems, Inc. e Fred Reichheld. A página diz que
o uso comercial do nome e da sigla exige consentimento prévio por escrito (licença) e que o uso do nome pede
atribuição. Ela afirma que teorias, métodos e ferramentas podem ser usados livremente, com atribuição, mas não separa
com todas as letras "o cálculo é livre" de "só o nome é protegido". Por isso a plataforma usa o nome "Probabilidade
de recomendação".

## Versão em português
Não encontrada na busca de 2026-11-22 (Crossref). Não equivale a "não existe".

## Perguntas em aberto
- O cálculo (pergunta, faixas e índice) pode ser usado sem licença? A página não o afirma explicitamente; considerar
  consultar a Bain.
- Citar o nome de marca na documentação e nos relatórios dos pesquisadores exige a atribuição indicada pela Bain?
- Qual é a redação oficial da pergunta e se há restrição para reproduzi-la? Esta ficha não a reproduz.

## Referências
- REICHHELD, F. F. The one number you need to grow. *Harvard Business Review*, v. 81, n. 12, p. 46-54, 2003.
  (DOI não localizado no Crossref.)
- KEININGHAM, T. L. et al. A longitudinal examination of net promoter and firm revenue growth. *Journal of
  Marketing*, v. 71, n. 3, p. 39-51, 2007. DOI: 10.1509/jmkg.71.3.039.
- BAIN & COMPANY. *Trademarks and licensing*. Disponível em: https://nps.bain.com/resources/trademarks-and-licensing.
  Acesso em: 22 nov. 2026.
