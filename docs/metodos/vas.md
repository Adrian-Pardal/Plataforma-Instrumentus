---
titulo: Ficha do método Escala visual analógica (VAS)
proposito: Dizer como a VAS funciona e como a plataforma grava e calcula o valor
status: rascunho
atualizado: 2026-11-22
mantido-por: manual
relacionados: [README.md, vas-dor.md]
---

# Escala visual analógica (VAS)

Nível 1 · Uso geral · Etapa 2 · Status: não implementado.
Texto da fonte "Métodos de pesquisa da plataforma"; as referências foram conferidas no Crossref quando têm DOI.

## Como funciona
O respondente marca um ponto numa linha contínua com rótulos só nas extremidades. No papel, a linha tem 100 mm e a
resposta é a distância medida em milímetros; na tela, é um controle deslizante (*slider*) que grava um valor de 0 a
100. Sem números visíveis, o respondente não fica preso a categorias.

## Regras para o código
- Gravar o valor de 0 a 100, nunca em pixels (o tamanho da tela muda): valor = posição / largura × 100.
- O marcador não começa posicionado num valor (isso induz a resposta).
- Se o respondente não tocar no *slider*, a resposta fica vazia, e não 0.

## Teste de referência
*Slider* de 320 px; o respondente soltou o marcador a 208 px da borda esquerda: valor = 208 / 320 × 100 = 65,0.
Com 4 respostas (65; 40; 72,5; 58), a média é 235,5 / 4 = 58,9.

## Fundamentação
A ideia vem das escalas de avaliação gráfica de Hayes e Patterson (1921) e Freyd (1923), usadas inicialmente para
avaliar trabalhadores. Por ser contínua, a VAS se aproxima de uma medida intervalar. Reips e Funke (2008) mostraram
que, na internet, a VAS mantém essa propriedade intervalar e funciona bem em diferentes tamanhos de tela.

## Condição de uso
Técnica geral de pesquisa. Uso livre, citando a fonte (segundo o documento de métodos; não verificado na fonte).

## Versão em português
Não se aplica: é um formato de pergunta. A aplicação à dor tem ficha própria ([vas-dor.md](vas-dor.md)).

## Perguntas em aberto
- Quantas casas decimais a plataforma grava? O exemplo do documento usa 72,5.
- Que alternativa a plataforma oferece a quem não consegue usar o *slider*? O documento não cobre.

## Referências
- HAYES, M. H. S.; PATTERSON, D. G. Experimental development of the graphic rating method. *Psychological
  Bulletin*, v. 18, p. 98-99, 1921. (DOI não verificado.)
- FREYD, M. The graphic rating scale. *Journal of Educational Psychology*, v. 14, n. 2, p. 83-102, 1923.
  DOI: 10.1037/h0074329.
- REIPS, U.-D.; FUNKE, F. Interval-level measurement with visual analogue scales in Internet-based research: VAS
  Generator. *Behavior Research Methods*, v. 40, n. 3, p. 699-704, 2008. DOI: 10.3758/BRM.40.3.699.
