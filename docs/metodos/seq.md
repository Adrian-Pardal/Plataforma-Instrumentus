---
titulo: Ficha do método SEQ (Single Ease Question)
proposito: Dizer como o SEQ funciona e como a plataforma calcula a média por tarefa
status: rascunho
atualizado: 2026-11-22
mantido-por: manual
relacionados: [README.md, sus.md]
---

# SEQ (Single Ease Question)

Nível 1 · Software e UX · Etapa 2 · Status: não implementado.
Texto da fonte "Métodos de pesquisa da plataforma"; as referências foram conferidas no Crossref quando têm DOI.

## Como funciona
Logo depois de cada tarefa num teste de usabilidade, o participante responde uma pergunta sobre o quão fácil ou
difícil foi a tarefa, de 1 (muito difícil) a 7 (muito fácil). O resultado é a média por tarefa, o que mostra quais
tarefas dão mais trabalho. Por ser aplicado tarefa a tarefa, complementa um questionário geral aplicado no fim, como o
SUS ([sus.md](sus.md)). Esta ficha não reproduz a redação da pergunta.

## Regras para o código
- O relatório mostra a média por tarefa, e não uma média geral.
- Permitir ligar a nota ao tempo e ao sucesso ou falha na tarefa.

## Teste de referência
5 participantes fizeram duas tarefas:

| Tarefa | Respostas (1 a 7) | Média |
|---|---|---|
| 1. Criar uma pesquisa | 6, 7, 5, 6, 7 | 31 / 5 = 6,2 |
| 2. Exportar os resultados | 3, 4, 2, 5, 3 | 17 / 5 = 3,4 |

A tarefa 2 é a que precisa de melhoria.

## Fundamentação
Sauro e Dumas (2009) compararam três formatos de pergunta única pós-tarefa: um item tipo Likert de 7 pontos (o
formato do SEQ), uma estimativa de magnitude e uma escala de esforço mental. Segundo o documento, os três distinguiram
os sistemas testados, mas o item Likert foi dos mais sensíveis com amostras pequenas e o mais simples de aplicar.
Sauro e Lewis (2016) detalham como analisar e comparar as médias.

## Condição de uso
Uso livre, citando a fonte (segundo o documento de métodos; não verificado na fonte).

## Versão em português
Não encontrada na busca de 2026-11-22 (Crossref). Não equivale a "não existe".

## Perguntas em aberto
- Como a plataforma mede o tempo e o sucesso da tarefa para ligá-los à nota? O documento pede a ligação, mas não diz como.
- Qual é a redação oficial da pergunta e se há restrição para reproduzi-la? Esta ficha não a reproduz.

## Referências
- SAURO, J.; DUMAS, J. S. Comparison of three one-question, post-task usability questionnaires. In: CHI CONFERENCE
  ON HUMAN FACTORS IN COMPUTING SYSTEMS, 27., 2009, Boston. *Proceedings* [...]. New York: ACM, 2009. p. 1599-1608.
  DOI: 10.1145/1518701.1518946.
- SAURO, J.; LEWIS, J. R. *Quantifying the user experience*: practical statistics for user research. 2. ed.
  Cambridge: Morgan Kaufmann, 2016. (Livro; DOI não verificado.)
