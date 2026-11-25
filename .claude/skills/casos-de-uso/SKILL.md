---
name: casos-de-uso
description: Escreve docs/requisitos/casos-de-uso/UC-NN-<nome>.md (ator, objetivo, pré e pós-condições, fluxo principal numerado, fluxos alternativos, exceções, RNs envolvidas) e mantém docs/requisitos/casos-de-uso/diagrama.md em PlantUML. Use quando uma spec for aprovada (a entrevista-spec a aciona), quando um fluxo de usuário nascer ou mudar, ou com /casos-de-uso <feature ou UC-NN>. Não use para desenhar tela, escolher tecnologia, inventar fluxo que a spec não tem nem para escrever teste (isso é da casos-de-teste).
argument-hint: "[<feature> | <UC-NN>]"
---

# Casos de uso

## Conceito (para você, dono do projeto)
Um caso de uso conta, passo a passo, como um **ator** alcança um **objetivo**
usando o sistema, sem dizer como o sistema é feito por dentro.

- **Ator:** quem (ou o quê) interage de fora: Pesquisador, Respondente. Use o
  nome oficial do `/glossario`. Não é o botão nem a tela.
- **Fluxo principal:** o caminho em que tudo dá certo, em passos numerados.
- **Fluxo alternativo:** caminho diferente que ainda chega ao objetivo
  (ex.: o Respondente salva e continua depois).
- **Exceção:** algo dá errado e o objetivo não é alcançado, ou é alcançado
  só em parte (ex.: pesquisa já encerrada). **Todo caso tem exceções.**
- **`include`:** um caso sempre usa outro (Publicar pesquisa *inclui*
  Validar pesquisa). Seta tracejada do que usa para o usado.
- **`extend`:** um caso opcional acrescenta comportamento a outro só em certa
  condição (Exportar resultados *estende* Ver resultados). Seta tracejada do
  que estende para o estendido.
- **Como UC vira teste:** na `/casos-de-teste`, o fluxo principal vira um caso
  de teste de sucesso; **cada fluxo alternativo e cada exceção vira ao menos um
  caso de teste**; cada RN envolvida gera casos de borda. Por isso o UC precisa
  ter passos numerados e resultados observáveis: o teste cita "UC-02, passo 4"
  e "exceção E1".

## Formato de UC-NN-<nome>.md
Nome do arquivo em minúsculas com hífen (ex.: UC-02-responder-pesquisa.md).
Cabeçalho de docs/templates/cabecalho.md e depois:

```
# UC-NN — <verbo no infinitivo + objeto>
- **Ator principal:** <termo do glossário>
- **Outros atores:** <ou "nenhum">
- **Objetivo:** <o que o ator quer alcançar, em uma frase>
- **Origem:** <spec e RF que o motivam>
- **Pré-condições:** <o que já deve ser verdade antes>
- **Pós-condições (sucesso):** <o que é verdade depois; estado dos dados>
- **Pós-condições (falha):** <o que NÃO muda quando dá errado>

## Fluxo principal
1. <ator faz / sistema responde, em linguagem do domínio>
2. ...

## Fluxos alternativos
- **2a.** <condição no passo 2> → <passos> → <volta ao passo N ou termina>

## Exceções
- **E1 (passo N).** <o que dá errado> → <resposta esperada do sistema e
  estado final>

## Regras de negócio envolvidas
- RN-xx — <título> (passo N)

## Inclui / estende
- inclui: UC-yy   |   estende: UC-zz (condição)
```

## Passos
1. Argumento: feature (extrair UC da spec) ou UC-NN (revisar). Sem argumento,
   pergunte. Leia a spec Aprovada, docs/requisitos/regras-de-negocio.md,
   docs/produto/glossario.md e os UC existentes. Sem spec Aprovada, PARE
   (CLAUDE.md §2).
2. Liste os candidatos a UC: um por objetivo de ator (não por tela, nem por
   RF; um UC pode cobrir vários RF). Mostre a lista e peça o ok antes de
   detalhar.
3. Para cada UC, preencha o formato acima só com base na spec, nas RN, em ADR
   ou no dono. Falta base (condição, resposta de erro, pós-condição)? Vira
   PERGUNTA ao dono, nunca invente (CLAUDE.md §5).
4. **Exceções obrigatórias:** todo UC tem pelo menos uma. Percorra: dado
   inválido, ação em estado inválido (pesquisa não publicada ou encerrada),
   permissão (outro pesquisador, sem login), repetição (envio duplicado) e
   falha do sistema. Cada uma entra ou vira pergunta. Se nenhuma se aplica,
   explique por quê e peça confirmação do dono: não fica sem exceção em
   silêncio.
5. Cada passo cita termos do glossário; termo novo aciona `/glossario`. Cada
   RN citada deve existir no catálogo; RN que falta aciona `/regras-negocio`.
   Não copie o texto da RN: cite RN-xx.
6. MOSTRE cada UC inteiro e espere aprovação antes de salvar (CLAUDE.md §6).
   Salve com Write/Edit e atualize o README.md da pasta.
7. **Diagrama:** atualize docs/requisitos/casos-de-uso/diagrama.md, com o
   cabeçalho padrão e UM bloco ```` ```plantuml ```` com estas peças (sintaxe
   conferida no Context7, plantuml.com/use-case-diagram):
   ```
   @startuml
   left to right direction
   actor Pesquisador
   actor Respondente
   rectangle "Plataforma Instrumentus" {
     usecase "UC-01 Publicar pesquisa" as UC01
     usecase "UC-02 Responder pesquisa" as UC02
     usecase "UC-03 Validar pesquisa" as UC03
   }
   Pesquisador -- UC01
   Respondente -- UC02
   UC01 .> UC03 : include
   @enduml
   ```
   Use `(Y) .> (X) : extends` para extend (Y estende X) e `Ator1 <|-- Ator2`
   para especialização de ator. Cada UC do diagrama tem arquivo, e cada arquivo
   está no diagrama. Se a sintaxe for dúvida, consulte o Context7 de novo; não
   invente.
8. Liste o que fica para depois: `/casos-de-borda` e `/casos-de-teste` (a
   partir dos UC), `/rastreabilidade` (UC ↔ RF ↔ RN ↔ CT, quando existir) e
   `/glossario` se surgiu termo.
9. Termine com 3–5 linhas explicando o que mudou e por quê (CLAUDE.md §7).

## Proibido
- Tela, botão, campo, cor, URL, rota ou tecnologia no caso de uso (nada de
  "clica no botão azul", "chama a API", "grava no banco"). Diga o que o ator
  faz e o que o sistema garante, em linguagem do domínio.
- UC sem exceções, ou com exceções vazias.
- Inventar fluxo, condição ou resposta que a spec, a RN ou o dono não disseram.
- Copiar o texto de uma RN no UC em vez de citar RN-xx.
- Mais de um objetivo por UC; ator fora do glossário.
- Salvar sem aprovação do dono.
- Editar spec, RN ou teste; a spec só muda pela `/entrevista-spec`.
- Criar ou editar arquivos por Bash (cat, echo, sed, tee, redirecionamento).

## Como verificar
- Cada UC tem os campos do formato, fluxo principal numerado e pelo menos
  uma exceção.
- `grep -n -i "botão\|tela\|clica\|api\|banco\|http" docs/requisitos/casos-de-uso/UC-*.md`
  não acha nada (ou só falsos positivos explicados).
- Todo RN-xx citado existe no catálogo.
- O diagrama e os arquivos UC-* batem (mesmo conjunto de UC).
- `git diff --stat` mostra só docs/requisitos/casos-de-uso/ e índices.
