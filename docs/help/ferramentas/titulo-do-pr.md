# NOME
titulo-do-pr — o título do PR segue Conventional Commits; como o CI confere e como corrigir

Última verificação: 2026-11-21 · Testado com: scripts/tests/validar-titulo-pr.test.sh (o job no CI ainda não
foi visto rodando num PR)

## PARA QUE SERVE
O título do PR vira o título do commit de merge (o repositório usa `merge_commit_title = PR_TITLE`). O job
`titulo-do-pr`, em `.github/workflows/ci.yml`, roda `scripts/validar-titulo-pr.sh` e falha se o título não
seguir Conventional Commits. Usa a mesma regex do hook `commit-msg` do lefthook, com uma diferença:
descrição só de espaços é recusada aqui (o lefthook a aceita).

Padrão: `tipo(escopo opcional): descrição`, com `!` depois do tipo ou do escopo para mudança incompatível.
Tipos aceitos: `feat`, `fix`, `docs`, `test`, `refactor`, `chore`, `ci`, `build`, `perf`. Escopo em minúsculas.
Exemplos: `feat: abre pesquisa`, `fix(ci): corrige o job`, `feat!: troca a escala`.

Quando vale: em todo PR (abrir, editar o título, novo push, reabrir). Em push direto não roda (fica
`skipping`). Obrigatório na proteção da `develop` e da `main`: ainda não (plano 003, T5; esta página muda
quando isso for feito).

## QUANDO FAZER
- Ao abrir um PR: escreva o título já no padrão.
- Quando o check `titulo-do-pr` ficar vermelho: corrija o título.
- No PR da `develop` para a `main`: o título também segue o padrão (por exemplo, `chore(release): v0.1.0`).

## PRÉ-REQUISITOS
- `gh` autenticado (`gh auth status`) para abrir e editar o PR pelo terminal.

## PASSO A PASSO
1. Abra o PR com o título certo.
   ```bash
   gh pr create --base develop --title "feat(ci): descrição curta"
   ```
2. Se o job reprovar, corrija o título. Editar o título reexecuta o CI inteiro (o evento `edited` está no
   gatilho).
   ```bash
   gh pr edit <número> --title "fix(ci): descrição curta"
   ```
3. Para testar um título antes, sem abrir PR:
   ```bash
   TITULO="feat: abre pesquisa" scripts/validar-titulo-pr.sh; echo "saída: $?"
   ```
   0 = válido, 1 = fora do padrão, 2 = faltou a variável `TITULO`.

## COMO CONFERIR QUE DEU CERTO
```bash
gh pr checks <número>
```
Esperado: `titulo-do-pr  pass`, junto de `seguranca` e `verificar`.

## SE DER ERRADO
- **O check ficou vermelho:** leia o log (`gh run view <id> --log-failed`), a mensagem mostra o título e o
  formato. Corrija com o passo 2.
- **Corrigi o título e o check não mudou:** confira que o `edited` disparou uma execução nova
  (`gh run list --limit 3`). Se não, `gh run rerun <id>`.
- **PR de revert do GitHub (`Revert "..."`):** o título automático não passa. Renomeie, por exemplo
  `fix: reverte a abertura de pesquisa`.
- **PR do Dependabot:** já vem como `chore(deps): ...`, que passa.
- **Desligar o job:** antes, tire `titulo-do-pr` da proteção das branches (senão todo PR fica esperando um
  check que não existe; veja `protecao-de-branches.md`); depois remova o job do `ci.yml` em um PR.

## VER TAMBÉM
- `docs/help/ferramentas/ci.md`
- `docs/help/ferramentas/protecao-de-branches.md`
- `docs/help/ferramentas/merge-de-pr.md`
- `docs/help/ferramentas/lefthook.md` (a regra dos commits)
- `docs/plans/003-titulo-do-pr-e-estrategia-de-merge.md`
