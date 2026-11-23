---
titulo: Ficha do método Metodologia Q (Q-sort)
proposito: Dizer como a metodologia Q funciona, como a plataforma valida a grade e o que exporta para a análise
status: rascunho
atualizado: 2026-11-22
mantido-por: manual
relacionados: [README.md]
---

# Metodologia Q (Q-sort)

Nível 3 · Uso geral · Etapa 5 · Status: não implementado.
Texto da fonte "Métodos de pesquisa da plataforma"; os números do exemplo foram recalculados e as referências foram
conferidas no Crossref quando têm DOI.

## Como funciona
O estudo tem quatro etapas:
1. O pesquisador reúne tudo o que se diz sobre o tema (o *concourse*) e seleciona de 30 a 60 afirmações (o *Q-set*).
2. Cada participante ordena as afirmações numa grade com distribuição forçada em forma de sino, por exemplo de −4
   (discordo totalmente) a +4 (concordo totalmente), com poucas casas nas pontas e mais no meio.
3. As ordenações são correlacionadas entre **pessoas** (e não entre itens) e passam por análise fatorial, geralmente
   com extração centroide ou por componentes principais e rotação varimax.
4. Cada fator encontrado representa um ponto de vista compartilhado por um grupo de participantes, e o pesquisador o
   interpreta a partir das afirmações mais características.

Costumam bastar de 20 a 60 participantes, porque o objetivo é encontrar pontos de vista, e não estimar porcentagens
da população. Na plataforma, a parte nova é a grade de arrastar; a análise pode ser feita com o pacote *qmethod* do R,
a partir dos dados exportados.

## Regras para o código
- Validar a distribuição forçada: o envio só é liberado com a grade completa e correta.
- Exportar no formato aceito pelo pacote *qmethod*: uma linha por afirmação e uma coluna por participante (segundo o
  documento; conferir na documentação do pacote).
- Guardar a posição de cada afirmação por participante.
- Conferência da carga significativa: 2,58 / √N (N = número de afirmações) para *p* < 0,01.

## Teste de referência
Versão reduzida com 9 afirmações (S1 a S9) e grade de −2 a +2 com casas 1, 2, 3, 2, 1 (total 9). Dois participantes:

| | S1 | S2 | S3 | S4 | S5 | S6 | S7 | S8 | S9 |
|---|---|---|---|---|---|---|---|---|---|
| P1 | +2 | +1 | +1 | 0 | 0 | 0 | −1 | −1 | −2 |
| P2 | +1 | +2 | 0 | +1 | 0 | −1 | 0 | −2 | −1 |

1. Validação: as duas grades respeitam a distribuição (uma em +2, duas em +1, três em 0, duas em −1, uma em −2).
2. Correlação de Pearson entre P1 e P2, nas 9 afirmações: 0,67. Com *N* participantes, monta-se a matriz *N* × *N* dessas
   correlações, e ela é a entrada da análise fatorial.
3. Carga significativa num estudo real com 40 afirmações: 2,58 / √40 = 0,41.

## Fundamentação
Stephenson (1935) propôs inverter a análise fatorial tradicional: em vez de agrupar itens, agrupar pessoas que
pensam de forma parecida. Desenvolveu o método em livro (Stephenson, 1953) como um jeito de estudar a subjetividade de
forma sistemática. Brown (1980) o difundiu nas ciências sociais, e Watts e Stenner (2012) escreveram o guia prático
mais usado hoje. É considerado um método misto: a coleta e a análise são quantitativas, e a interpretação é
qualitativa.

## Condição de uso
Método geral de pesquisa; o pacote *qmethod* é de terceiros. Uso livre, citando a fonte (segundo o documento de
métodos; não verificado na fonte). A licença do pacote não foi conferida.

## Versão em português
Não se aplica: é um método de coleta e análise.

## Perguntas em aberto
- O formato de exportação (linha por afirmação, coluna por participante) confere com a documentação do *qmethod*?
- Qual é a grade padrão (−4 a +4 é só exemplo) e quem define a distribuição?
- Como a plataforma oferece a grade para quem não consegue arrastar (alternativa pelo teclado, prevista no guia para
  a Etapa 4)?
- A plataforma faz algum cálculo da análise fatorial ou só a coleta e a exportação? O documento diz que faz só as
  etapas 1 e 2.
- As faixas de 20 a 60 participantes e de 30 a 60 afirmações vêm do documento; não foram conferidas em Watts e Stenner.

## Referências
- STEPHENSON, W. Technique of factor analysis. *Nature*, v. 136, p. 297, 1935. DOI: 10.1038/136297b0.
- STEPHENSON, W. *The study of behavior*: Q-technique and its methodology. Chicago: University of Chicago Press,
  1953. (Livro; DOI não verificado.)
- BROWN, S. R. *Political subjectivity*: applications of Q methodology in political science. New Haven: Yale
  University Press, 1980. (Livro; DOI não verificado.)
- WATTS, S.; STENNER, P. *Doing Q methodological research*: theory, method and interpretation. London: SAGE, 2012.
  DOI: 10.4135/9781446251911.
- ZABALA, A. qmethod: a package to explore human perspectives using Q methodology. *The R Journal*, v. 6, n. 2,
  p. 163-173, 2014. DOI: 10.32614/RJ-2014-032.
