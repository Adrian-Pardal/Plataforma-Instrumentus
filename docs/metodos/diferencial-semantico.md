---
titulo: Ficha do método Diferencial semântico
proposito: Dizer como o diferencial semântico funciona, como a plataforma recodifica os pares e calcula
status: rascunho
atualizado: 2026-11-22
mantido-por: manual
relacionados: [README.md]
---

# Diferencial semântico

Nível 1 · Uso geral · Etapa 2 · Status: não implementado.
Texto da fonte "Métodos de pesquisa da plataforma".

## Como funciona
O respondente avalia um objeto entre dois adjetivos opostos, numa escala geralmente de 7 pontos (por exemplo,
"difícil" numa ponta e "fácil" na outra). O resultado é a média de cada par e, quando os pares são agrupados, a média
de cada dimensão. O UEQ (Nível 2, ver [ueq.md](ueq.md)) é inteiro construído nesse formato.

## Regras para o código
- Guardar, em cada par, qual polo é o positivo.
- Pares exibidos ao contrário são recodificados com 8 − resposta (escala de 7 pontos).
- Para centralizar, subtrair 4 (o ponto do meio): o resultado vai de −3 a +3.
- Guardar a resposta bruta; recodificar só na análise.

## Teste de referência
Avaliação de um aplicativo com 3 pares de 7 pontos; o terceiro par aparece invertido na tela (polo positivo à esquerda).

| Par na tela | Resposta (1 a 7) | Recodificado (1 a 7) | Centralizado (−3 a +3) |
|---|---|---|---|
| difícil – fácil | 6 | 6 | 6 − 4 = +2 |
| lento – rápido | 5 | 5 | +1 |
| bonito – feio | 5 | 8 − 5 = 3 | 3 − 4 = −1 |

Média = (2 + 1 − 1) / 3 = +0,67.

## Fundamentação
Osgood, Suci e Tannenbaum (1957) criaram a técnica para medir o significado que as pessoas atribuem a conceitos. Com
análise fatorial, encontraram três dimensões que se repetem entre culturas: avaliação (bom–ruim), potência
(forte–fraco) e atividade (rápido–lento).

## Condição de uso
Técnica geral de pesquisa. Uso livre, citando a fonte (segundo o documento de métodos; não verificado na fonte).

## Versão em português
Não se aplica: é um formato de pergunta. Instrumentos nesse formato (UEQ) têm a sua própria ficha.

## Perguntas em aberto
- Quantos pontos a plataforma oferece (o documento diz "geralmente 7")?
- Os pares são livres (o pesquisador escreve) ou vêm de uma lista? O documento não decide.

## Referências
- OSGOOD, C. E.; SUCI, G. J.; TANNENBAUM, P. H. *The measurement of meaning*. Urbana: University of Illinois
  Press, 1957. (Livro; DOI não verificado.)
