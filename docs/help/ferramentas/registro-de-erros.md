# NOME
registro-de-erros — modelos de issue, etiquetas, a issue automática do CI e como registrar um erro

Última verificação: 2026-11-21 · Testado com: gh 2.103.2 (o script da issue automática, com `gh` falso;
os formulários ainda não foram conferidos em "New issue")

## PARA QUE SERVE
Transformar um tropeço em aprendizado. O fluxo tem três peças:
- **Issue:** o aviso do problema. Nasce pelos modelos de `.github/ISSUE_TEMPLATE/` (`bug`, `erro-ia`,
  `ambiente`) ou, sozinha, pelo CI quando a `main` falha (etiqueta `incidente`).
- **Registro `ERR-NNN`** em `docs/erros/`: causa raiz, correção, teste de regressão e lição para a IA.
  Criado com a skill `/registrar-erro` depois que a causa raiz é descoberta.
- **Índice** `docs/erros/README.md`, atualizado a cada registro.

Etiquetas: `bug`, `erro-ia`, `ambiente`, `producao`, `incidente`. A `bug` já existe no GitHub; as demais
você cria uma vez (passo 1). Cada modelo de issue aplica a sua etiqueta sozinho.

## QUANDO FAZER
- **Criar as etiquetas:** uma vez, antes do merge do PR que traz o job `registrar-falha`.
- **Abrir uma issue:** quando algo quebrar e você quiser deixar registrado (GitHub → Issues → New issue).
- **Registrar o `ERR-NNN`:** depois de descobrir a causa raiz de um erro relevante.
- **Fechar a issue do CI:** quando a `main` voltar a passar.

## PRÉ-REQUISITOS
- `gh` autenticado (`gh auth status`).
- Para o job do CI: a etiqueta `incidente` existir no repositório.

## PASSO A PASSO
1. Crie as etiquetas que faltam (uma vez).
   ```bash
   gh label create erro-ia --description "Erro cometido pela IA (ver docs/erros)" --color D93F0B
   gh label create ambiente --description "Problema de ferramenta, versão ou configuração do ambiente" --color FBCA04
   gh label create producao --description "Falha em produção" --color B60205
   gh label create incidente --description "Incidente (por exemplo, o CI da main falhou)" --color 5319E7
   gh label list
   ```
2. Abra a issue pelo navegador: GitHub → Issues → New issue, e escolha o modelo (Bug, Erro da IA ou
   Ambiente). Os formulários são YAML; o `gh issue create --template` serve a modelos em Markdown e não
   foi confirmado para formulários.
3. Quando a causa raiz for conhecida, peça `/registrar-erro`. Ponha o número da issue no campo `issue`
   do registro.
4. **Issue automática do CI:** se um push na `main` falhar, o job `registrar-falha` (em `ci.yml`) roda
   `scripts/abrir-issue-ci.sh`. Ele abre a issue "CI falhou na main", com a etiqueta `incidente`, o link
   do log e o commit. Se já houver uma issue aberta com essa etiqueta e esse título, não abre outra.
   A checagem busca o título como texto (`in:title`), não por igualdade exata: uma issue aberta com
   etiqueta `incidente` e um título parecido também impede a abertura. Falhas simultâneas na `main` são
   serializadas (`concurrency` do workflow e do job; um pendente pode ser substituído por outro mais novo),
   o que reduz muito a chance de duplicar, mas não a elimina: a busca do GitHub pode demorar alguns
   segundos para enxergar a issue recém-criada. Se aparecer uma duplicada, feche uma delas.
   Para ver o log: `gh run view <id> --log-failed`.

## COMO CONFERIR QUE DEU CERTO
- `gh label list` mostra `bug`, `erro-ia`, `ambiente`, `producao` e `incidente`.
- GitHub → Issues → New issue mostra os três formulários (Bug, Erro da IA, Ambiente) com os campos
  esperados. Esta conferência é manual e ainda não foi feita.
- Teste do script: `scripts/tests/abrir-issue-ci.test.sh` termina com "todos os casos passaram".

## SE DER ERRADO
- **O formulário não aparece em "New issue":** o YAML tem erro de formato. A página de edição do arquivo
  no GitHub aponta a linha. Corrija em um PR.
- **O job `registrar-falha` falhou com "label not found":** a etiqueta `incidente` não existe; crie-a
  (passo 1) e rode o job de novo (`gh run rerun <id>`).
- **Issue de CI duplicada ou que não abriu:** o script só olha issues abertas com a etiqueta `incidente`.
  Se a anterior foi fechada, uma nova falha abre outra, de propósito.
- **Etiqueta com nome errado:** `gh label delete <nome>` e crie de novo.
- **Desligar a issue automática:** remova o job `registrar-falha` do `ci.yml` em um PR.

## VER TAMBÉM
- `docs/erros/README.md` e `docs/templates/erro.md`
- `docs/skills.md` (skill `registrar-erro`)
- `docs/help/ferramentas/ci.md`
- `docs/plans/002-registro-de-erros.md`
