---
name: casos-de-teste
description: Deriva casos de teste em docs/testes/casos-de-teste/CT-<feature>.md a partir dos critérios de aceite da spec e das regras RN, escolhendo e explicando a técnica por caso (partição de equivalência, valor limite, tabela de decisão, transição de estados, baseado em caso de uso). Cada caso (ID CT-<feature>-NN) tem objetivo, técnica, pré-condição, entrada, resultado esperado objetivo, origem e o teste automatizado que o implementa. Aciona casos-de-borda e atualiza a rastreabilidade. Use após o plano de uma feature, ou quando um critério de aceite ficar sem caso de teste (a implementar-tdd a aciona). Não use para implementar os testes, nem para inventar requisito que a spec não tem.
---

# Casos de teste

## Conceito (para você, dono do projeto)
Caso de teste é uma pergunta com resposta objetiva: "dado isto, quando
aquilo, então exatamente isto". Aqui eles não nascem da cabeça do
programador: nascem dos critérios de aceite e das regras RN, com uma técnica
que explica POR QUE aquele conjunto de casos basta. Cada caso aponta para o
teste automatizado que o implementa, fechando o caminho
requisito → caso → teste.

## Passos
1. Identifique a feature (argumento ou plano atual). Leia a spec Aprovada
   (critérios CA-x), o plano Aprovado (tasks e testes previstos), as regras RN
   citadas (docs/requisitos/regras-de-negocio.md) e os casos de uso, se
   existirem. Sem spec ou plano aprovado, PARE (CLAUDE.md §2). Regra RN citada
   que não existe: pergunte; nunca invente a regra.
2. Se docs/testes/casos-de-teste/CT-<feature>.md já existe, é atualização:
   mantenha os IDs existentes. Nunca renumere nem reutilize um ID.
3. Para CADA critério de aceite e cada RN relevante, escolha a técnica e
   explique em 1–2 linhas por que ela serve:
   - **Partição de equivalência:** entradas que o sistema trata igual (ex.:
     nota Likert válida × inválida).
   - **Valor limite:** fronteiras de faixas (ex.: 1 e 5 na escala; 0 e 6).
   - **Tabela de decisão:** várias condições que combinam (ex.: regras de
     publicação).
   - **Transição de estados:** ciclo de vida (ex.: pesquisa rascunho →
     publicada → encerrada), incluindo transições proibidas.
   - **Baseado em caso de uso:** o fluxo principal e as alternativas de um UC.
   Em escolha de técnica não óbvia, apresente 2–3 opções com prós e contras
   (CLAUDE.md §7).
4. Escreva cada caso, com o cabeçalho de docs/templates/cabecalho.md no
   arquivo (`mantido-por: /casos-de-teste`; `relacionados`: spec, plano, RNs),
   com estes campos:
   - **ID:** `CT-<slug>-NN`, em que `<slug>` é o nome da feature em minúsculas
     com hífen (o mesmo de `CT-<feature>.md`) e NN é sequencial de 2 dígitos
     dentro da feature (ex.: `CT-publicar-pesquisa-03`). O slug é definido na
     primeira vez e nunca muda; o ID é único em todo o projeto.
   - **Objetivo:** uma frase.
   - **Técnica:** qual e por quê.
   - **Pré-condição:** estado inicial.
   - **Entrada:** valores concretos.
   - **Resultado esperado:** OBJETIVO e verificável (valor, status, mensagem,
     estado); nunca "funciona", "é exibido corretamente".
   - **Origem:** CA-x da spec e/ou RN-xx (com link). Sem origem, o caso não
     entra.
   - **Teste automatizado:** nome do teste e caminho, ou "pendente (T<n> do
     plano)" enquanto não existir. Nunca cite teste que não existe como se
     existisse. O nome do teste deve conter o ID do caso, para o `grep`
     achar caso e teste juntos.
5. Confira as lacunas: se um critério ficou sem caso, liste; se um caso não
   deriva de critério ou RN, remova-o ou registre como pergunta em aberto na
   spec (não assuma requisito, CLAUDE.md §5).
6. Acione `/casos-de-borda` para a feature (limites e situações extremas além
   dos casos derivados). Se essa skill ainda não existir, avise o dono e liste
   isso como pendência; não improvise borda por conta própria.
7. **Rastreabilidade:** em docs/requisitos/rastreabilidade.md, adicione ou
   atualize apenas a coluna CT dos RF/CA/RN cobertos. Se o arquivo ainda não
   existe, não o crie: avise e aponte `/rastreabilidade`. Não edite outras
   colunas nem a seção Rastreabilidade do plano (é da `/planejar`).
8. Atualize a tabela de docs/testes/casos-de-teste/README.md (criando o
   README da pasta se ainda não existir, com o cabeçalho padrão) e de
   docs/testes/README.md (status do item casos-de-teste/).
9. MOSTRE cada arquivo novo ou alterado inteiro e espere aprovação antes de
   salvar. Depois rode `scripts/verify.sh test` e mostre a saída.

## Proibido
- Caso sem resultado esperado objetivo.
- Caso sem origem (CA-x ou RN-xx).
- Inventar regra, critério, valor de limite ou resultado que a spec e as RN
  não definem: vira pergunta em aberto.
- Citar como existente um teste automatizado que não existe.
- Renumerar ou reaproveitar um ID já existente, ou mudar o slug da feature.
- Editar spec, plano ou RN (só ler e linkar); editar rastreabilidade além da
  coluna CT.
- Escrever o código dos testes: é da `/implementar-tdd`.
- Salvar sem mostrar o conteúdo e receber aprovação.
- Criar ou editar arquivos por Bash (cat, echo, sed, tee, redirecionamento).

## Como verificar
- Todo CA da spec tem ao menos um caso; lacunas estão listadas.
- Todo caso tem os 8 campos, ID no formato `CT-<slug>-NN`, resultado esperado
  objetivo e origem que existe.
- A técnica de cada caso está explicada.
- `Teste automatizado` aponta para teste real ou diz "pendente (T<n>)".
- Rastreabilidade atualizada (ou ausência avisada) e READMEs dos índices
  atualizados.
- `scripts/verify.sh test` mostrado, 100% verde.
