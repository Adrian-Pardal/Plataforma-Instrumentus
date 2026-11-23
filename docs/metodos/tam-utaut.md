---
titulo: Ficha do método TAM e UTAUT (aceitação de tecnologia)
proposito: Dizer como os modelos TAM e UTAUT funcionam e como a plataforma calcula a média por construto
status: rascunho
atualizado: 2026-11-22
mantido-por: manual
relacionados: [README.md, alfa-de-cronbach.md, umux-lite.md]
---

# TAM e UTAUT (aceitação de tecnologia)

Nível 2 · Software e UX · Etapa 3 · Status: não implementado.
Texto da fonte "Métodos de pesquisa da plataforma"; as referências foram conferidas no Crossref quando têm DOI.
Esta ficha não reproduz os itens.

## Como funciona
São modelos teóricos com questionários associados, em itens tipo Likert de 7 pontos:
- **TAM:** dois construtos principais, utilidade percebida e facilidade de uso percebida, além da intenção de uso.
- **UTAUT:** quatro construtos, expectativa de desempenho, expectativa de esforço, influência social e condições
  facilitadoras, mais a intenção de uso. Idade, gênero, experiência e voluntariedade entram como moderadores.

Na plataforma, o resultado básico é a média de cada construto. Em pesquisa acadêmica, a análise costuma ser feita com
modelagem de equações estruturais (por exemplo, PLS-SEM), fora da plataforma, a partir dos dados exportados.

## Regras para o código
- Média por construto, com o alfa de Cronbach de cada um (ver [alfa-de-cronbach.md](alfa-de-cronbach.md)).
- A exportação traz uma coluna por item, e não só as médias, para permitir a análise fora da plataforma.
- Guardar a resposta bruta.

## Teste de referência
TAM com um respondente (1 a 7):

| Construto | Itens | Respostas | Média |
|---|---|---|---|
| Utilidade percebida | 4 | 6, 7, 6, 5 | 24 / 4 = 6,0 |
| Facilidade de uso percebida | 4 | 5, 5, 6, 4 | 20 / 4 = 5,0 |
| Intenção de uso | 2 | 6, 6 | 12 / 2 = 6,0 |

## Fundamentação
Davis (1989) adaptou a Teoria da Ação Racional (Fishbein; Ajzen, 1975) para tecnologia: as pessoas adotam um sistema
quando acreditam que ele é útil e fácil de usar. Venkatesh et al. (2003) compararam oito modelos de aceitação e os
unificaram no UTAUT, que, segundo o documento, explicou cerca de 70% da variação na intenção de uso. O UTAUT2
(Venkatesh; Thong; Xu, 2012) acrescentou motivação hedônica, custo-benefício e hábito, para o contexto do consumidor.

## Condição de uso
Uso livre, citando a fonte (segundo o documento de métodos; **não verificado** na fonte). Os itens são publicados em
artigos de periódico; a licença deles não foi conferida.

## Versão em português
Não encontrada na busca de 2026-11-22 (Crossref). Não equivale a "não existe".

## Perguntas em aberto
- Quantos itens tem cada construto? O documento diz "cerca de 6" no TAM, mas o exemplo usa 4.
- Qual é a redação oficial dos itens e se há restrição para reproduzi-los? Esta ficha não os reproduz.
- O valor "cerca de 70%" do UTAUT vem de Venkatesh et al. (2003) pelo documento; não foi conferido no artigo.
- Existe versão validada em português? Busca inicial sem resultado.
- O UTAUT2 entra na plataforma? O documento só o cita.

## Referências
- DAVIS, F. D. Perceived usefulness, perceived ease of use, and user acceptance of information technology. *MIS
  Quarterly*, v. 13, n. 3, p. 319-340, 1989. DOI: 10.2307/249008.
- VENKATESH, V. et al. User acceptance of information technology: toward a unified view. *MIS Quarterly*, v. 27,
  n. 3, p. 425-478, 2003. DOI: 10.2307/30036540.
- VENKATESH, V.; THONG, J. Y. L.; XU, X. Consumer acceptance and use of information technology: extending the
  unified theory of acceptance and use of technology. *MIS Quarterly*, v. 36, n. 1, p. 157-178, 2012.
  DOI: 10.2307/41410412.
- FISHBEIN, M.; AJZEN, I. *Belief, attitude, intention, and behavior*: an introduction to theory and research.
  Reading: Addison-Wesley, 1975. (Livro; DOI não verificado.)
