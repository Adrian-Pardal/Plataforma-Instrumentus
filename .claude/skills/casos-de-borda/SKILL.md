---
name: casos-de-borda
description: Para a regra (RN-xx) ou o método indicado, lista cenários de borda em 8 categorias (nulo/vazio, limites, tipos inválidos, repetição, concorrência, permissão de outro usuário, estado inválido, volume) e, para cada um, o comportamento esperado segundo a spec ou uma pergunta em aberto. Entrega a lista para a casos-de-teste transformar em CT-<feature>-NN e propõe as perguntas em aberto para a spec. Use quando a casos-de-teste a acionar, ou ao revisar uma regra ou método em busca do que pode quebrar. Não use para decidir o comportamento esperado sem base na spec, nem para escrever o código dos testes.
argument-hint: "<regra ou método>"
---

# Casos de borda

## Conceito (para você, dono do projeto)
Os bugs moram nas bordas: o valor 0 numa escala de 1 a 5, o campo vazio, o
clique duplo, o usuário que mexe na pesquisa de outro. Esta skill faz o
varrimento sistemático dessas situações para uma regra ou método, e para cada
uma pergunta: o que a spec manda acontecer? Se a spec não diz, isso NÃO é
decidido aqui: vira pergunta para você.

## Passos
1. Argumento: regra (RN-xx) ou método (função, endpoint, caso de uso).
   Sem argumento, pergunte. Leia a spec Aprovada, o plano, a RN indicada
   (docs/requisitos/regras-de-negocio.md) e, se existir, o
   docs/testes/casos-de-teste/CT-<feature>.md. Sem spec, PARE (CLAUDE.md §2).
2. Percorra as 8 categorias e liste só os cenários que fazem sentido para o
   alvo (se uma categoria não se aplica, diga "não se aplica" com o motivo):
   - **Nulo/vazio:** ausente, null, string vazia, só espaços, lista vazia.
   - **Limites:** fronteiras e vizinhos (escala Likert 1–5: 0, 1, 5, 6; tamanhos
     mínimo e máximo; datas de início e fim).
   - **Tipos inválidos:** texto onde se espera número, decimal onde se espera
     inteiro, formato de data errado, valor fora do enum.
   - **Repetição:** mesmo envio duas vezes, duplo clique, reenvio, mesmo
     identificador repetido.
   - **Concorrência:** duas requisições ao mesmo tempo, edição simultânea,
     envio no instante em que a pesquisa é encerrada.
   - **Permissão de outro usuário:** acessar ou alterar recurso de outro
     pesquisador, sem login, com sessão expirada, resposta anônima tentando ler
     resultado. Dados de respondentes: ler antes os erros de docs/erros/
     (CLAUDE.md §6).
   - **Estado inválido:** ação em estado que não a permite (responder pesquisa
     não publicada ou encerrada, publicar duas vezes, editar o que já tem
     respostas).
   - **Volume:** muitas respostas, muitos construtos ou itens, payload grande,
     paginação, lista no limite.
3. Para CADA cenário, preencha **Comportamento esperado** assim:
   - Se a spec, uma RN ou um ADR define: cite o trecho (arquivo e identificador)
     e escreva o comportamento exatamente como lá.
   - Se NÃO define: escreva "pergunta em aberto" com a pergunta objetiva
     (ex.: "O que acontece com a nota 6: erro 400 ou valor truncado?"). Nunca
     escreva um esperado "óbvio" por conta própria.
4. Entregue a tabela no chat: # | Categoria | Cenário | Comportamento esperado
   | Base (spec/RN/ADR) ou "pergunta em aberto". Termine com a lista das
   perguntas em aberto numeradas.
5. **Quem grava o quê.** Esta skill responde no chat e não cria arquivo:
   - Cenários COM base vão para a `/casos-de-teste`, a única que grava o
     CT-<feature>.md (cada um vira CT-<feature>-NN). Se foi acionada por ela,
     devolva a tabela; se foi chamada direto, ofereça acionar a
     `/casos-de-teste`.
   - Cenários SEM base são perguntas em aberto: eles ficam pendentes (sem CT)
     até o dono responder.
6. **Perguntas em aberto:** escreva o texto exato, no formato da seção
   "Perguntas em aberto" da spec, MOSTRE-o ao dono e, só com o ok, acione a
   `/entrevista-spec` para gravá-lo na spec. Nunca edite a spec diretamente.
   Sem ok, as perguntas ficam só no chat; lembre o dono de que elas se perdem
   se a sessão acabar (o `/handoff` deve listá-las).
7. Se algum arquivo, mesmo assim, for criado, mostre-o inteiro e espere
   aprovação antes de salvar.

## Proibido
- Decidir o comportamento esperado sem base na spec, RN ou ADR: vira pergunta
  em aberto.
- Preencher "Base" com citação que não confere ou com a "boa prática" geral.
- Editar spec, plano, RN ou casos de teste existentes (a spec só muda pela
  `/entrevista-spec`, com o ok do dono).
- Gravar o CT-<feature>.md: é da `/casos-de-teste`.
- Escrever o código dos testes (é da `/implementar-tdd`).
- Pular categoria sem escrever "não se aplica" e o motivo.
- Criar ou editar arquivos por Bash (cat, echo, sed, tee, redirecionamento).

## Como verificar
- As 8 categorias aparecem, cada uma com cenários ou "não se aplica" + motivo.
- Todo cenário tem esperado com citação que existe, ou é pergunta em aberto
  explícita.
- As perguntas em aberto estão numeradas, com o texto proposto para a spec,
  e foram apresentadas ao dono.
- Nenhuma spec, plano, RN ou CT foi alterado por esta skill
  (`git diff --stat`).
