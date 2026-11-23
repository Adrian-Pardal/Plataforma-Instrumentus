---
titulo: Ficha do método Múltipla escolha e caixas de seleção
proposito: Dizer como esses dois tipos de pergunta funcionam e como a plataforma calcula as porcentagens
status: rascunho
atualizado: 2026-11-22
mantido-por: manual
relacionados: [README.md]
---

# Múltipla escolha e caixas de seleção

Nível 1 · Uso geral · Etapa 1 · Status: não implementado.
Texto da fonte "Métodos de pesquisa da plataforma"; as referências foram conferidas no Crossref quando têm DOI.

## Como funciona
Na múltipla escolha, o respondente marca uma opção entre várias; nas caixas de seleção, pode marcar todas as que se
aplicam. A análise é a frequência e a porcentagem de cada opção. Nas caixas de seleção, as porcentagens somam mais
de 100%, porque cada pessoa pode marcar mais de uma.

## Regras para o código
- O denominador de cada porcentagem é o número de respondentes daquela pergunta, e não o de marcações nem o total de
  participantes da pesquisa.
- Na escolha única a soma das porcentagens é 100%; nas caixas de seleção pode passar de 100%.

## Teste de referência
200 pessoas responderam às duas perguntas.

| Pergunta | Opção | Marcações | % dos respondentes |
|---|---|---|---|
| Escolha única | Manhã | 90 | 90 / 200 = 45% |
| | Tarde | 70 | 35% |
| | Noite | 40 | 20% |
| Caixas de seleção | E-mail | 150 | 150 / 200 = 75% |
| | WhatsApp | 120 | 60% |
| | Telefone | 30 | 15% |

Escolha única: soma 100%. Caixas: soma 150%, pois o denominador é 200 respondentes e não 300 marcações.

## Fundamentação
É o formato fechado clássico dos levantamentos (*surveys*). As opções precisam ser mutuamente exclusivas e cobrir
todas as respostas possíveis, o que muitas vezes exige "Outro" ou "Prefiro não responder". Smyth et al. (2006)
mostraram que perguntar "sim/não" para cada opção (escolha forçada) gera mais itens marcados e respostas mais
pensadas do que o "marque todas que se aplicam", porque o respondente para de ler a lista mais cedo no segundo
formato.

## Condição de uso
Formato geral de pergunta, sem instrumento proprietário. Uso livre, citando a fonte (segundo o documento de métodos;
não verificado na fonte).

## Versão em português
Não se aplica: é um formato de pergunta.

## Perguntas em aberto
- A plataforma oferece o formato de escolha forçada (sim/não por opção) como alternativa às caixas de seleção? O
  documento cita a vantagem, mas não decide.
- "Outro" e "Prefiro não responder" são opções automáticas ou o pesquisador as adiciona?

## Referências
- DILLMAN, D. A.; SMYTH, J. D.; CHRISTIAN, L. M. *Internet, phone, mail, and mixed-mode surveys*: the tailored design
  method. 4. ed. Hoboken: Wiley, 2014. (Livro, sem DOI encontrado.)
- SMYTH, J. D. et al. Comparing check-all and forced-choice question formats in web surveys. *Public Opinion
  Quarterly*, v. 70, n. 1, p. 66-77, 2006. DOI: 10.1093/poq/nfj007.
