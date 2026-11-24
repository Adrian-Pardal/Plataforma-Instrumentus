---
titulo: Spec 000 — Visão do MVP
proposito: Dizer o que entra no MVP da Instrumentus, o que fica de fora e em quais features ele se divide
status: vigente
atualizado: 2026-11-24
mantido-por: /entrevista-spec
relacionados: [../adr/0004-plataforma-multi-metodo-instrumentus.md, ../metodos/README.md, ../produto/visao.md, ../produto/roadmap.md, ../requisitos/regras-de-negocio.md, ../requisitos/casos-de-uso/README.md]
---

# Spec: Visão do MVP

- **Status:** Aprovada (pelo dono, em 2026-11-24)
- **Data:** 2026-11-24
- **Plano:** não se aplica (esta spec orienta as specs das features; não vira código sozinha)

## Problema
Quem faz pesquisa com instrumentos validados monta o questionário e as regras do método à mão (itens, escala,
inversões) e calcula o resultado em planilha. Isso toma tempo e dá erro. O MVP resolve duas dores: **montar o instrumento**
e **calcular o resultado certo de cada método**. (Origem: resposta do dono, pergunta 1, opção A+B.)

## Usuários e papéis
- **Pesquisador** — perfil acadêmico (estudante, pesquisador) e perfil de saúde ou implementação. Tem conta (e-mail e
  senha), monta, publica e encerra suas pesquisas e vê os resultados. NÃO vê pesquisa de outro pesquisador.
- **Respondente** — responde pelo link público, sem se identificar. NÃO vê resultados nem outras respostas.

## Fluxo principal
Passos propostos a partir do CLAUDE.md §1 e da ficha do TFA; o dono corrigiu o 2 e decidiu conta e exportação.
Os passos 3 a 7 foram aprovados pelo dono junto com a spec, em 2026-11-24.
1. O pesquisador entra com sua conta.
2. Cria uma pesquisa com **uma ou mais seções**; cada seção usa um **modelo padrão** de um método, com a lógica já
   estabelecida. O pesquisador só adapta o que o método permite (modo limitado; ex.: o nome da intervenção no TFA).
3. Publica a pesquisa e recebe um link público.
4. Os respondentes abrem o link e respondem, em celular ou computador, sem se identificar.
5. O pesquisador vê o resultado calculado por cada seção, conforme o método (no TFA, a média por construto).
6. Baixa as respostas em planilha.
7. Encerra a pesquisa.

## Requisitos funcionais
Nível de visão: cada RF corresponde a uma ou mais features do roadmap. Os critérios detalhados ficam na spec de cada
feature.

### RF-01 — Conta do pesquisador
O pesquisador se cadastra e entra com e-mail e senha; vê só as pesquisas dele.

**Critérios de aceite**
- **CA-1 (sucesso)** — Dado um pesquisador cadastrado, Quando ele entra, Então vê a lista só das suas pesquisas.
- **CA-2 (erro)** — Dado uma senha errada, Quando tenta entrar, Então não entra e a mensagem não revela se o e-mail existe.
- **CA-3 (abuso)** — Dado a pesquisa de outro pesquisador, Quando alguém tenta abri-la ou alterá-la, Então o acesso é negado.

### RF-02 — Montar pesquisa por modelos
O pesquisador cria uma pesquisa com seções; cada seção parte de um modelo padrão do método e aceita só as adaptações
permitidas.

**Critérios de aceite**
- **CA-1 (sucesso)** — Dado um modelo de método, Quando o pesquisador o adiciona como seção, Então os itens e o cálculo são os do método.
- **CA-2 (erro)** — Dado um campo que o método não permite alterar, Quando o pesquisador tenta alterá-lo, Então a alteração é recusada.
- **CA-3 (erro)** — Dado uma pesquisa sem nenhuma seção, Quando tenta publicar, Então a publicação é recusada.

### RF-03 — Publicar e coletar respostas anônimas
O pesquisador publica a pesquisa e compartilha o link; o respondente responde sem se identificar, no celular ou no
computador.

**Critérios de aceite**
- **CA-1 (sucesso)** — Dado uma pesquisa publicada, Quando o respondente envia, Então a resposta é guardada sem dado que o identifique.
- **CA-2 (erro)** — Dado uma pesquisa não publicada ou encerrada, Quando alguém abre o link, Então não consegue responder.
- **CA-3 (abuso)** — Dado um navegador que já respondeu, Quando tenta responder de novo, Então o sistema avisa e não conta nova resposta. A proteção é leve: outro navegador a contorna, e a spec da feature deve dizer isso.

### RF-04 — Resultados e encerramento
O pesquisador vê, por seção, o resultado calculado conforme o método, e encerra a pesquisa.

**Critérios de aceite**
- **CA-1 (sucesso)** — Dado respostas de teste da ficha do método, Quando o pesquisador abre os resultados, Então os valores batem com o teste de referência da ficha.
- **CA-2 (erro)** — Dado uma pesquisa sem respostas, Quando abre os resultados, Então vê o aviso "sem respostas" e nenhum cálculo quebra.

### RF-05 — Várias seções por pesquisa
Uma pesquisa pode combinar métodos diferentes; cada seção calcula pelo seu método, sem misturar escores entre seções.

**Critérios de aceite**
- **CA-1 (sucesso)** — Dado uma pesquisa com seção TFA e seção Likert, Quando há respostas, Então cada seção mostra o seu resultado separado.

### RF-06 — Métodos da etapa 1
O MVP entrega, em ordem, os 7 métodos da etapa 1: TFA; Likert, múltipla escolha e caixas, escala numérica e perguntas
abertas; AIM/IAM/FIM e SUS. Cada um segue a sua ficha em docs/metodos/.

**Critérios de aceite**
- **CA-1 (sucesso)** — Dado cada método, Quando os testes de referência da ficha rodam, Então os resultados batem.

### RF-07 — Exportar respostas
O pesquisador baixa as respostas de uma pesquisa em planilha.

**Critérios de aceite**
- **CA-1 (sucesso)** — Dado uma pesquisa com respostas, Quando o pesquisador exporta, Então recebe um arquivo com todas elas.
- **CA-2 (abuso)** — Dado a pesquisa de outro pesquisador, Quando alguém tenta exportá-la, Então o acesso é negado.
- **CA-3 (abuso)** — Dado qualquer exportação, Então o arquivo não contém dado que identifique o respondente.

## Regras de negócio
Catálogo único: [regras-de-negocio.md](../requisitos/regras-de-negocio.md). Esta spec usa as regras
RN-01 (resposta anônima), RN-02 (acesso só às próprias pesquisas), RN-03 (seção calcula só pelo seu método),
RN-04 (adaptação limitada do modelo), RN-05 (limite leve por navegador), RN-06 (só pesquisa publicada recebe
respostas) e RN-07 (pesquisa sem seção não se publica). Regras de um método ficam na ficha dele; o TFA, por
construto e sem escore único, está na [ficha do TFA](../metodos/tfa.md).

## Requisitos não funcionais
- A página de resposta funciona em celular e computador. O pesquisador usa só computador nesta versão.
- Privacidade: resposta anônima; dados pessoais só do pesquisador (e-mail, senha).
- Demais metas (desempenho, volume, acessibilidade, retenção): em "Perguntas em aberto".

## Casos de abuso
- Responder várias vezes para distorcer a média (RF-03 CA-3).
- Acessar ou exportar pesquisa de outro pesquisador (RF-01 CA-3, RF-07 CA-2).
- Identificar respondente pela exportação (RF-07 CA-3).

## Dados
- Pesquisador: e-mail e senha (dado pessoal).
- Pesquisa, seções e respostas: sem dado pessoal do respondente.
- Tempo de guarda e pedido de exclusão: em aberto.

## Fora de escopo
Aprovados pelo dono junto com a spec, em 2026-11-24:
- Os 23 métodos das etapas 2 a 5.
- Os modos de modelo travado e editável (só o limitado entra); vira item do roadmap.
- Respostas ligadas à mesma pessoa (pré e pós, Delphi, 360°); depende da decisão de anonimato.
- Vários pesquisadores na mesma pesquisa.
- Outros idiomas além do português.

## Critério de pronto
O MVP está pronto quando **(a)** os 7 métodos da etapa 1 batem com os testes de referência das fichas e todos os testes
passam, **e (b)** uma pessoa real monta uma pesquisa, publica o link, recebe respostas de pessoas reais e vê o resultado.

## Perguntas em aberto
- [x] Passos 1 e 3 a 7 do fluxo: estão certos? (resolvida pela aprovação da spec, 2026-11-24)
- [ ] Regra de adaptação limitada: o que cada método permite mudar? (o dono decide por método)
- [ ] Modo editável futuro: o resultado deve avisar "instrumento modificado"?
- [ ] A versão em português do TFA não foi encontrada (ficha, 2026-11-22). De onde vêm os itens em português? Bloqueia a feature do TFA.
- [ ] Licença de uso dos itens do questionário TFA e do SUS ainda não conferida (fichas).
- [ ] A etapa final de entrega (seção 4.2 do guia) não está no repositório; a ordem usa a sugerida na tabela.
- [ ] Retenção e exclusão de dados (LGPD); a skill `lgpd` ainda não existe.
- [ ] Cadastro: confirmar e-mail? Recuperar senha?
- [ ] Sair da conta: existe? E por quanto tempo o pesquisador continua dentro sem entrar de novo? (UC-02)
- [ ] Editar ou excluir uma pesquisa: o pesquisador pode, depois de montada e depois de publicada? (UC-03)
- [ ] Formato da exportação (CSV ou outro) e o que ela inclui.
- [ ] Metas de desempenho, volume por pesquisa e acessibilidade.
- [ ] Anonimato e ligação de respostas: decidir antes do primeiro método que liga respostas (fora do MVP).
