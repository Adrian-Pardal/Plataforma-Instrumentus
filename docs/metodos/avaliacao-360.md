---
titulo: Ficha do método Avaliação 360°
proposito: Dizer como a avaliação 360° funciona, como a plataforma calcula e protege o anonimato dos grupos
status: rascunho
atualizado: 2026-11-22
mantido-por: manual
relacionados: [README.md, likert.md]
---

# Avaliação 360°

Nível 2 · Empresarial e mercado · Etapa 4 · Status: não implementado.
Texto da fonte "Métodos de pesquisa da plataforma"; os números do exemplo foram recalculados e as referências foram
conferidas no Crossref quando têm DOI.

## Como funciona
Uma pessoa é avaliada pelo mesmo questionário de competências (itens tipo Likert e perguntas abertas), respondido por
vários grupos: ela mesma (autoavaliação), o gestor, os pares, os subordinados e, às vezes, clientes. O relatório
mostra a média de cada competência por grupo e compara a autoavaliação com a visão dos outros.

## Regras para o código
- Calcular primeiro a média de cada avaliador (por competência) e depois a de cada grupo.
- Só mostrar o resultado de um grupo quando ele tiver pelo menos 3 respondentes; o gestor é a exceção, por ser uma
  pessoa só.
- Média dos outros = média de todos os avaliadores menos a autoavaliação (inclui os grupos que não aparecem).
- Diferença = autoavaliação − outros.
- Guardar o grupo de cada resposta (ligado a um código, sem identificar a pessoa).

## Teste de referência
Competência "Comunicação" (média de 4 itens, 1 a 5):

| Grupo | Médias dos avaliadores | Respondentes | Média do grupo | Exibir? |
|---|---|---|---|---|
| Autoavaliação | 4,5 | 1 | 4,50 | sim |
| Gestor | 3,5 | 1 | 3,50 | sim (exceção) |
| Pares | 3,8; 3,5; 4,1 | 3 | 3,80 | sim |
| Subordinados | 4,0; 3,6 | 2 | – | não (menos de 3) |

- Média dos outros = (3,5 + 3,8 + 3,5 + 4,1 + 4,0 + 3,6) / 6 = 3,75
- Diferença = 4,50 − 3,75 = +0,75

## Fundamentação
É chamada na literatura de *feedback multifonte*. A ideia é que cada grupo vê um lado diferente do trabalho da
pessoa, e a diferença entre como ela se vê e como os outros a veem estimula mudança de comportamento (London;
Smither, 1995). A meta-análise de Smither, London e Reilly (2005) mostrou, segundo o documento, que a melhora média
após um 360° é pequena, e maior quando o resultado é usado para desenvolvimento (e não para promoção ou punição), vem
acompanhado de metas e de conversa com um orientador. Bracken, Timmreck e Church (2001) reúnem as boas práticas de
aplicação.

## Condição de uso
Técnica geral; o questionário de competências é definido pelo pesquisador. Uso livre, citando a fonte (segundo o
documento de métodos; não verificado na fonte).

## Versão em português
Não encontrada para um instrumento de 360° na busca de 2026-11-22 (Crossref). Não equivale a "não existe".

## Perguntas em aberto
- **Anonimato do grupo oculto:** o exemplo esconde os subordinados (2 respondentes), mas inclui as respostas deles na
  média dos outros. Como a plataforma mostra as médias da autoavaliação, do gestor, dos pares e dos outros, dá para
  recuperar a média dos subordinados: 22,5 − 3,5 − 11,4 = 7,6, ou seja, 3,8. A regra de mínimo 3 não protege esse
  grupo. Como proteger?
- A média dos outros é por avaliador (3,75) ou por grupo? Pela média das médias dos grupos, o exemplo daria 3,70.
- O mínimo de 3 vale também para a média dos outros e para as perguntas abertas?
- Dados de desempenho de uma pessoa identificada: como ficam LGPD e o uso restrito a desenvolvimento? O documento
  só recomenda o uso para desenvolvimento.
- Quem convida cada grupo e como o código de cada avaliador é gerado sem identificá-lo?

## Referências
- LONDON, M.; SMITHER, J. W. Can multi-source feedback change perceptions of goal accomplishment, self-evaluations,
  and performance-related outcomes? Theory-based applications and directions for research. *Personnel Psychology*,
  v. 48, n. 4, p. 803-839, 1995. DOI: 10.1111/j.1744-6570.1995.tb01782.x.
- SMITHER, J. W.; LONDON, M.; REILLY, R. R. Does performance improve following multisource feedback? A theoretical
  model, meta-analysis, and review of empirical findings. *Personnel Psychology*, v. 58, n. 1, p. 33-66, 2005.
  DOI: 10.1111/j.1744-6570.2005.514_1.x.
- BRACKEN, D. W.; TIMMRECK, C. W.; CHURCH, A. H. (ed.). *The handbook of multisource feedback*. San Francisco:
  Jossey-Bass, 2001. (Livro; DOI não verificado.)
