---
name: documentar-tecnologia
description: Cria docs/tecnologias/<tecnologia>.md com o cabeçalho padrão e as seções o que é, por que foi escolhida (link para o ADR), como é usada NESTE projeto (arquivos, configuração, exemplo real), armadilhas (links para os ERR-NNN de docs/erros/), links oficiais conferidos e versão em uso; atualiza o índice docs/tecnologias/README.md. Use depois que a tecnologia foi decidida em ADR e entrou no projeto, ou quando a versão ou o uso mudarem. Não use para tecnologia sem ADR, para copiar a documentação oficial, nem para decidir stack (isso é /registrar-adr).
argument-hint: "<tecnologia>"
---

# Documentar tecnologia

## Conceito (para você, dono do projeto)
A página de uma tecnologia responde quatro perguntas: o que é, por que a
escolhemos, como a usamos AQUI e onde ela costuma morder. A documentação
oficial já explica a tecnologia em geral; esta página só registra o que é
específico do projeto e aponta para o oficial.

## Passos
1. Argumento: nome da tecnologia, em minúsculas com hífen (`postgresql`,
   `spring-boot`). Sem argumento, pergunte.
2. Procure o ADR que a escolheu em docs/adr/. Sem ADR Aceito, PARE e sugira
   `/registrar-adr`; não documente tecnologia não decidida.
3. Se docs/tecnologias/<tecnologia>.md já existe, é atualização: leia-o e
   mude só o que ficou desatualizado.
4. **Versão em uso:** leia a fonte real (pom.xml, build.gradle, package.json,
   lockfile, Dockerfile). Sem fonte no repositório, escreva "não sei" e diga o
   que falta; nunca deduza do ADR ou da memória.
5. **Documentação oficial (CLAUDE.md §5):** consulte o Context7
   (`resolve-library-id`, depois `query-docs`) para a versão em uso. Cada
   recurso, configuração ou API citada tem de ter sido conferida; o que não
   foi conferido, não entra. Para cada link oficial, abra-o e confirme que
   responde e trata do assunto; registre a data da conferência.
6. **Uso neste projeto:** ache no código os arquivos e a configuração
   reais e cite o caminho (`caminho/arquivo`). O exemplo vem de código que
   existe no repositório, com o caminho; não escreva exemplo inventado.
   Sem uso ainda: escreva "ainda não usada no código".
7. **Armadilhas:** procure em docs/erros/ os ERR-NNN ligados à tecnologia e
   linke cada um com uma linha de resumo. Nenhum: "nenhuma registrada até
   agora". Não invente armadilhas.
8. Monte a página, começando pelo cabeçalho de docs/templates/cabecalho.md
   (`mantido-por: /documentar-tecnologia`; `relacionados`: o ADR, ERRs e
   arquivos de configuração). Seções: O que é · Por que foi escolhida · Como
   é usada neste projeto · Armadilhas · Links oficiais · Versão em uso.
   Explique em linguagem de estudante, com clareza antes de esperteza.
9. MOSTRE o arquivo inteiro e espere aprovação antes de salvar. Depois
   atualize a tabela de docs/tecnologias/README.md (Arquivo | Do que trata |
   Status), removendo a linha "(uma página por tecnologia...)" na primeira
   vez, e mostre essa alteração também.
10. Se a tecnologia traz credencial, ferramenta ou rotina manual nova, lembre
    de criar a página em docs/help/ no mesmo commit (CLAUDE.md §6).

## Proibido
- Copiar ou parafrasear longos trechos da documentação oficial: resuma em
  poucas linhas e linke.
- Afirmar versão ou recurso sem conferir (fonte no repositório ou Context7).
- Documentar tecnologia sem ADR Aceito.
- Inventar exemplo, armadilha, link ou ERR-NNN.
- Linkar documentação oficial sem abrir o link.
- Editar ADR ou ERR existente (só linkar).
- Salvar sem mostrar o conteúdo e receber aprovação.
- Criar ou editar arquivos por Bash (cat, echo, sed, tee, redirecionamento).

## Como verificar
- O arquivo tem o cabeçalho completo (6 campos) e as 6 seções.
- O link do ADR e cada link de ERR-NNN apontam para arquivos que existem.
- A versão bate com a fonte citada; nada afirmado sem conferência.
- O exemplo existe no caminho citado.
- docs/tecnologias/README.md lista a página.
- `scripts/verify.sh test` mostrado, 100% verde.
