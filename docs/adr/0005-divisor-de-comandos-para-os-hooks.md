# ADR 0005: Um divisor de comandos compartilhado para os hooks que leem o comando do shell

- **Status:** Aceito
- **Data:** 2026-11-20
- **Substitui:** nenhum (complementa o ADR 0003)

## Contexto
- Os hooks `protect-merge`, `protect-push` e `protect-files` leem o texto de `tool_input.command`.
  Cada um corta o comando com a sua própria lógica. O ERR-001 foi corrigido só no `protect-push`;
  o ERR-002 é a mesma falha no `protect-merge`.
- O PR #8 teve 7 revisões seguidas e todas acharam uma forma nova de esconder uma opção proibida:
  redirecionamentos, `>|`, texto entre aspas, expansões (`$`, crase, `{}`), flag antes do subcomando
  e `&` solto (ERR-002, ERR-003). Cada correção cobriu a forma que falhou.
- O `ask` do `settings.json` (`Bash(gh pr merge *)`) é a 1ª camada. Pela documentação oficial do Claude
  Code, ele separa comandos compostos (`&&`, `||`, `;`, `|`, `|&`, `&`, quebra de linha), vê subshell e
  `$(...)`, e remove wrappers como `command`, `timeout` e `xargs` sem flags. Não cobre `sh -c`, formas com
  flag no meio (`gh -R x pr merge`) nem `gh api`; a doc diz que a regra não é fronteira de segurança.
- O `gh` real (2.103.2) aceita flag antes do subcomando (`gh pr -R x merge`, `gh --paginate=true api`).
- No GitHub, merge commit, squash e rebase estão permitidos; o auto-merge está desligado.
- Ambiente: bash 5.2, jq e python3 instalados; `shfmt` não está instalado (nem no CI).

## Decisão
Criaremos um divisor de comandos compartilhado, em bash (`.claude/hooks/lib/`), que respeita aspas e os
separadores `&`, `&&`, `||`, `;`, `|`, `|&` e quebra de linha, e entrega cada segmento já em tokens. Os três
hooks passam a usá-lo, um por vez, começando pelo `protect-merge`. Quando não conseguir interpretar um
segmento de um comando protegido (aspas abertas, `$(`, crase), o hook bloqueia (falha fechada).
Será feito em PR próprio, com plano e TDD; os testes atuais dos hooks viram a suíte de regressão.

## Alternativas
1. **Continuar remendando regra a regra** — prós: nenhum trabalho novo agora; cada remendo é pequeno ·
   contras: 7 revisões seguidas acharam uma brecha nova; o hook só cresce; a lógica fica duplicada.
2. **Divisor próprio em bash, compartilhado** (escolhida) — prós: um lugar só; fecha pela raiz `&` e aspas;
   sem dependência nova (bash e jq já são usados e rodam no CI); fácil de testar · contras: continua sendo
   uma aproximação do shell (variáveis, aliases e `sh -c` não são resolvidos, por isso a falha fechada);
   PR grande; migrar 3 hooks.
3. **Parser de shell de verdade (`shfmt`)** — prós: lê a gramática do bash, mais fiel · contras: dependência
   nova, não instalada aqui nem no CI (instalar no CI com versão fixa é um trabalho à parte, como o DEBT-001);
   mais uma ferramenta para o dono manter.
4. **Impor no GitHub e reduzir o hook** (fechar squash e rebase no repositório) — prós: `--squash` e
   `--rebase` falham no servidor, sem depender do texto; barato · contras: não cobre o destino (develop ou
   main) nem quem pede (o `gh` usa o token do dono); a configuração fica fora do repositório e some sem aviso.
   **Descartada como substituta; recomendada como complemento**, em decisão separada.

## Consequências
**Positivas:** uma só lógica de corte nos três hooks; os 2 achados abertos do PR #8 (`&` solto e flag antes
de `api`/`alias`) viram casos de teste; o DEBT-002 pode ser quitado e o ERR-003 fechado.

**Negativas:** PR grande; a falha fechada gera falsos bloqueios; continua sem enxergar variáveis,
`sh -c` e aliases, então o `ask` e a leitura do dono seguem necessários.

**Daqui para frente:**
- Escrever o plano em `docs/plans` e implementar em TDD, um hook por vez.
- Atualizar `docs/help` (`merge-de-pr.md`, `testes-dos-hooks.md`) e corrigir nelas o que se diz do `ask`.
- Avaliar, à parte, fechar squash e rebase no GitHub (alternativa 4) e registrar em `protecao-de-branches.md`.
