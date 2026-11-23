---
titulo: Ficha do método CES (esforço do cliente)
proposito: Dizer como o CES funciona, as duas versões e como a plataforma evita misturá-las
status: rascunho
atualizado: 2026-11-22
mantido-por: manual
relacionados: [README.md]
---

# CES (esforço do cliente)

Nível 1 · Empresarial e mercado · Etapa 2 · Status: não implementado.
Texto da fonte "Métodos de pesquisa da plataforma".

## Como funciona
Mede o quanto foi fácil resolver algo com a empresa. Existem duas versões, com sentidos opostos:
- **CES 1.0 (2010):** pergunta sobre o esforço feito, de 1 (muito pouco) a 5 (muito). Quanto menor, melhor.
- **CES 2.0 (2013):** concordância com uma afirmação de que a empresa facilitou a resolução, de 1 (discordo
  totalmente) a 7 (concordo totalmente). Quanto maior, melhor.

O resultado é a média das notas ou a porcentagem de respostas de 5 a 7 (na versão 2.0). O documento recomenda a
versão 2.0, porque a 1.0 confundia respondentes com a escala invertida. Esta ficha não reproduz a redação.

## Regras para o código
- Gravar qual versão foi usada em cada resposta; nunca misturar as duas num mesmo resultado.
- Na versão 2.0: % fáceis = respostas de 5 a 7 / total; média na escala de 1 a 7.

## Teste de referência
CES 2.0, 100 respostas na escala de 1 a 7:

| Nota | 7 | 6 | 5 | 4 | 3 | 2 | 1 |
|---|---|---|---|---|---|---|---|
| Respostas | 30 | 25 | 15 | 10 | 8 | 7 | 5 |

- % de respostas fáceis (5 a 7) = (30 + 25 + 15) / 100 = 70%
- Média = (7×30 + 6×25 + 5×15 + 4×10 + 3×8 + 2×7 + 1×5) / 100 = 518 / 100 = 5,18

## Fundamentação
Dixon, Freeman e Toman (2010) analisaram dados de dezenas de milhares de clientes e concluíram, segundo o documento,
que "encantar" o cliente pouco aumenta a lealdade, enquanto reduzir o esforço diminui muito a chance de ele ir
embora. Dixon, Toman e DeLisi (2013) aprofundaram a pesquisa e propuseram o CES 2.0. A métrica é mais útil em
atendimento e suporte.

## Condição de uso
Uso livre, citando a fonte (segundo o documento de métodos; não verificado na fonte).

## Versão em português
Não encontrada na busca de 2026-11-22 (Crossref). Não equivale a "não existe".

## Perguntas em aberto
- Qual é a redação oficial de cada versão e se há restrição para reproduzi-la? Esta ficha não a reproduz.
- A plataforma oferece a 1.0 ou só a 2.0 (a recomendada)?
- O corte de 5 a 7 como "fácil" é dos autores ou escolha do documento? A fonte não diz.

## Referências
- DIXON, M.; FREEMAN, K.; TOMAN, N. Stop trying to delight your customers. *Harvard Business Review*, v. 88,
  n. 7/8, p. 116-122, 2010. (DOI não localizado no Crossref.)
- DIXON, M.; TOMAN, N.; DELISI, R. *The effortless experience*: conquering the new battleground for customer
  loyalty. New York: Portfolio/Penguin, 2013. (Livro; DOI não verificado.)
