# NOME
testes-dos-hooks — rodar os testes dos hooks e do verify.sh

Última verificação: 2026-11-20 · Testado com: bash 5, jq, node/npm, lefthook

## PARA QUE SERVE
Os hooks em `.claude/hooks/` e o `scripts/verify.sh` protegem o projeto
(push e merge perigosos, ADR aceito, teste desativado). Os testes em
`scripts/tests/*.test.sh` garantem que essas proteções continuam
funcionando depois de cada mudança. Cada teste sai com 0 se tudo passou
e com 1 se algum caso falhou.

O `scripts/verify.sh test` e o `full` já rodam todos os
`scripts/tests/*.test.sh` e falham se algum falhar. O `full` também roda o
`shellcheck` nos hooks e scripts, se ele estiver instalado
(`sudo apt install shellcheck`), e o `actionlint` nos workflows (veja
`instaladas.md`); sem eles, avisa e segue.

## QUANDO FAZER
Sempre que mudar um hook ou o `verify.sh`, antes do commit. Para rodar
só um teste, use o passo 1; para rodar tudo, `scripts/verify.sh test`.

## PRÉ-REQUISITOS
- `jq` instalado (os hooks também precisam dele).
- `node` e `npm` para o `stop-verify.test.sh` (sem eles, pula esse teste).
- Estar na raiz do projeto.

## PASSO A PASSO
1. Rode o teste do hook que você mudou.
   ```bash
   scripts/tests/protect-push.test.sh
   ```
   Troque o nome pelo teste que quiser rodar (tabela abaixo).

| Teste                  | O que cobre                                       |
|------------------------|---------------------------------------------------|
| protect-push.test.sh   | `git push` liberado ou bloqueado (hook protect-push) |
| protect-merge.test.sh  | `gh pr merge` e `gh api` de merge: só destino develop e só `--merge`; sem `--squash`/`--rebase`/`--admin`/`--auto` (usa um gh falso, não chama o GitHub) |
| protect-files.test.sh  | Write e Edit em ADR Aceito (caminho relativo e absoluto; só trocar o Status é liberado), Edit em `.env` e `src/`, e Bash: `cat .env` e `sed -i` em ADR bloqueados, `cat .env.example` liberado (hook protect-files) |
| lefthook.test.sh       | `lefthook.yml`: mensagens do commit-msg e segredo staged no pre-commit (precisa de lefthook e gitleaks; sem eles, pula) |
| verify.test.sh         | detecção de teste desativado/isolado (`it.only`, `xit`, `fit`...), shellcheck e actionlint (só no modo full) no verify.sh |
| stop-verify.test.sh    | hook Stop: `stop_hook_active` e sem mudança de código saem com 0; com código alterado, teste falhando bloqueia (2) e passando libera (0); usa projeto temporário com `package.json` (precisa de node/npm; sem eles, pula) |
| post-edit-check.test.sh | hook PostToolUse: `.md` não roda o verify; `.java` e `pom.xml` rodam; verify falhando dá 2 e mostra só as últimas 40 linhas (usa um verify.sh falso) |
| config.test.sh         | `settings.json` e `.mcp.json` válidos (jq), `lefthook validate`, frontmatter (name/description) de skills e subagentes, e `disable-model-invocation` conforme manual/automática do `docs/skills.md` (lefthook ausente: pula só essa parte) |

## COMO CONFERIR QUE DEU CERTO
A última linha é `✔ todos os casos passaram` e o código de saída é 0
(`echo $?`).

## SE DER ERRADO
Linhas `FALHA (esperado X, veio Y)` mostram o caso. Se o hook foi mudado
de propósito, corrija o hook, não o teste, a menos que o teste esteja
errado. Para voltar atrás: `git restore .claude/hooks/<hook>.sh`.

## VER TAMBÉM
- `docs/help/ferramentas/skills.md`
- `docs/help/ferramentas/merge-de-pr.md`
