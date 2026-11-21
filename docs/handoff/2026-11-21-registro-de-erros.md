# Handoff — 2026-11-21 (registro de erros, plano 002)

## Onde estamos
Plano `docs/plans/002-registro-de-erros.md` (sem spec; exceção autorizada pelo dono): T1 a T6 feitas e
MERGEADAS na `develop` (PR #16, commit de merge 1872ea8, 2026-11-21 23:24 UTC, `gh pr merge --merge`). CI
verde (`seguranca` e `verificar`; `registrar-falha` ficou `skipping`, o esperado num PR). O plano 001
(divisor de comandos) segue PAUSADO.

## Feito
- Itens 1 e 3 do pedido já estavam atendidos: `docs/erros/` com README, `docs/templates/erro.md` e a skill
  `registrar-erro` (não havia `docs/ERRORS.md` para migrar).
- T1/T2: `scripts/abrir-issue-ci.sh` (abre a issue "CI falhou na main", etiqueta `incidente`, link do log,
  sem duplicar) e `scripts/tests/abrir-issue-ci.test.sh` (8 casos, `gh` falso). TDD: teste vermelho antes.
- T3: formulários `bug.yml`, `erro-ia.yml` e `ambiente.yml` em `.github/ISSUE_TEMPLATE/` (sem `config.yml`:
  issue em branco continua permitida).
- T4: job `registrar-falha` no `ci.yml` (`needs: [seguranca, verificar]`, `failure()` + push na `main`,
  `issues: write`, valores do `github.*` só por `env:`, `concurrency` próprio).
- T5: frase no CLAUDE.md §6 (mesma linha; segue com 62 linhas) e campo `issue` na skill `registrar-erro`.
- T6: `docs/help/ferramentas/registro-de-erros.md` (página nova), `ci.md` e índice do help.
- Revisão em duas rodadas (agentes `revisor-codigo` e `auditor-spec`): nenhum 🔴. Corrigidos 2 🟡 (o teste
  não protegia `--state open --label incidente`; corrida entre jobs) e depois 1 🟡 + 🔵 (texto do help
  prometia "não duplicam"; teste lia o log inteiro).
- Etiquetas criadas no GitHub: `erro-ia`, `ambiente`, `producao`, `incidente` (a `bug` já existia).

## Em andamento
Nada pela metade.

## Próximo passo
1. Abrir GitHub → Issues → New issue e conferir os três formulários (Bug, Erro da IA, Ambiente). É a
   única parte sem prova: as chaves do topo do YAML (`name`, `description`, `title`, `labels`, `body`) só
   foram confirmadas na doc pelo revisor, e a renderização nunca foi vista. Depois, trocar a linha "ainda
   não foi feita" na `registro-de-erros.md` pela data da conferência.
2. Depois, a spec do método de Aceitabilidade TFA (CLAUDE.md §2: sem spec aprovada, nada de código).
   Perguntas ao dono: quais outros métodos virão? Escala e relatório são próprios ou compartilhados?

## Decisões
- Script testável em vez de shell no YAML; etiqueta `incidente`; só a `main`; sem ADR (automação de CI,
  fácil de desfazer).
- Não implementei a opção (b) da revisão (trocar `--search` por `--label` + `--jq` para evitar o atraso do
  índice de busca): não está confirmado que o atraso acontece. Se aparecer issue duplicada, ela entra com
  teste novo. O help avisa o limite.
- A `/revisar` (skill) não foi invocada: usei direto os agentes `revisor-codigo` e `auditor-spec`. O dono
  não objetou ao merge.

## Problemas
- Erro de processo meu: commitei e enviei (`47db919`) com o teste vermelho, porque encadeei commit e push
  com `;` em vez de parar na falha. Causa: o filtro novo do teste lia só a 1ª linha da chamada `issue create`
  (o corpo tem várias linhas). A "prova da mutação" feita nesse commit era inválida (vermelha pelo motivo
  errado); refeita e correta em `62d025f`. Lição: verificar primeiro e só então commitar/enviar, sem
  encadear com `;`; conferir que o vermelho de uma mutação é pelo motivo esperado.
- Deslize menor: deixei um `sed -i` apontando para `/dev/null` num comando (não fez nada; o CLAUDE.md
  proíbe `sed` para editar).
- O job `registrar-falha` só roda de verdade quando a `main` falhar; o que está testado é o script e a
  sintaxe (actionlint no CI).
- Abertos: CLAUDE.md com 62 linhas (limite 60); DEBT-001, DEBT-002, DEBT-003; PR #5 do dependabot; branch
  local `feat/protect-merge-divisor` (commit vermelho da T8, não enviado); branches remotas antigas
  `feat/divisor-de-comandos` e `docs/handoff-pr1a-mergeado` (só o dono apaga); `actionlint` não instalado
  localmente (o CI instala).

## Estado da verificação
`scripts/verify.sh full` rodou com rc=0 antes do último push (62d025f): "todos os casos passaram", "testes
dos scripts passaram", shellcheck sem alertas em 20 arquivos; actionlint pulado local, rodou no CI (verde).
- Resultado: passou
- Testes desativados/dívidas abertas: ver docs/DEBT.md
