# ADR 0005: Um divisor de comandos compartilhado para os hooks que leem o comando do shell

- **Status:** Aceito
- **Data:** 2026-11-20
- **Substitui:** nenhum (complementa o ADR 0003)

## Contexto
- Os hooks `protect-merge`, `protect-push` e `protect-files` leem o texto de `tool_input.command`. Cada um
  corta o comando com a sua própria lógica (substituição de texto nos dois primeiros; `grep` e `sed` no
  ramo Bash do `protect-files`). O ERR-001 foi corrigido só no `protect-push`; o ERR-002 é a mesma falha no
  `protect-merge`.
- As 8 primeiras revisões do PR #8 acharam, cada uma, formas novas de esconder uma opção proibida:
  redirecionamentos, `>|`, texto entre aspas, expansões (`$`, crase, `{}`), flag antes do subcomando e entre
  `pr` e `merge`, `&` e `|&` soltos, e `gh api` montado por expansão, `--input` ou `@arquivo` (ERR-002,
  ERR-003). Cada correção cobriu a forma que falhou.
- O `ask` do `settings.json` (`Bash(gh pr merge *)`) é a 1ª camada. Pela documentação oficial do Claude
  Code, ele separa comandos compostos (`&&`, `||`, `;`, `|`, `|&`, `&`, quebra de linha), vê subshell e
  `$(...)`, e remove wrappers como `command`, `timeout` e `xargs` sem flags. Não cobre `sh -c`, formas com
  flag no meio (`gh -R x pr merge`) nem `gh api`; a doc diz que a regra não é fronteira de segurança.
- O `gh` real (2.103.2) aceita flag antes do subcomando (`gh pr -R x merge`, `gh --paginate=true api`).
- No GitHub, merge commit, squash e rebase estão permitidos; o auto-merge está desligado.
- Ambiente: bash 5.2, jq e python3 instalados; `shfmt` não está instalado e o CI não o instala. O `jq`
  vem no runner do CI (os testes dos hooks, que o usam, já passam lá).
- Os testes dos hooks (`scripts/tests/*.test.sh`) são caixa-preta: JSON no stdin, `gh` falso, só o código
  de saída. Alguns afirmam falsos bloqueios aceitos (por exemplo, `--body "custa $5"`).

## Decisão
Criaremos um divisor de comandos compartilhado, em bash (`.claude/hooks/lib/`), que:
1. respeita aspas e separa em `&`, `&&`, `||`, `;`, `|`, `|&` e quebra de linha, entregando cada segmento
   em tokens e mantendo os redirecionamentos identificáveis;
2. acha o subcomando de `gh` e `git` pulando flags globais (`gh -R x pr merge`, `gh pr -R x merge`,
   `gh --paginate=true api`), em vez de olhar uma posição fixa;
3. reconhece `env`, `command`, `xargs` e subshell e analisa o comando de dentro; `sh -c`, variáveis e
   aliases continuam fora do alcance;
4. falha fechada: se não consegue interpretar um segmento de comando protegido (aspas abertas, `$(`,
   crase), o hook bloqueia.

"Comando protegido" é `gh pr merge`, `gh api` e `gh alias` (protect-merge), `git push` (protect-push) e os
comandos Bash que escrevem em arquivos protegidos (protect-files). As regras do ERR-003 para `gh pr merge`
(`$`, crase, `\` e `{`) continuam valendo até o plano decidir outra coisa, com teste. Os três hooks passam
a usar o divisor, um por vez, começando pelo `protect-merge`. Será feito em PR próprio, com plano e TDD:
nenhum teste atual muda de resultado; se mudar, a mudança é justificada.

## Alternativas
1. **Continuar remendando regra a regra** — prós: nenhum trabalho novo agora; cada remendo é pequeno ·
   contras: 8 revisões seguidas acharam uma brecha nova; o hook só cresce; a lógica fica duplicada.
2. **Divisor próprio em bash, compartilhado** (escolhida) — prós: um lugar só; fecha pela raiz `&`, `|&` e
   aspas; sem dependência nova; fácil de testar · contras: continua sendo uma aproximação do shell
   (variáveis, aliases e `sh -c` não são resolvidos, por isso a falha fechada); PR grande; migrar 3 hooks.
3. **Parser de shell de verdade (`shfmt`)** — prós: lê a gramática do bash, mais fiel · contras: dependência
   nova, não instalada aqui nem no CI (instalar no CI com versão fixa é um trabalho à parte, como o DEBT-001);
   mais uma ferramenta para o dono manter.
4. **Impor no GitHub e reduzir o hook** (fechar squash e rebase no repositório) — prós: `--squash` e
   `--rebase` falham no servidor, sem depender do texto; barato · contras: não cobre o destino (develop ou
   main), `gh api` nem quem pede (o `gh` usa o token do dono); a configuração fica fora do repositório e some
   sem aviso. **Descartada como substituta; recomendada como complemento**, em decisão separada.

## Consequências
**Positivas:** uma só lógica de corte nos três hooks; os achados do PR #8 que o divisor cobre (`&`, `|&`, flag
antes do subcomando) viram casos de teste.

**Negativas:** PR grande; o maior custo e risco é a migração, porque os três hooks tratam aspas e
redirecionamento de formas diferentes (o `protect-push` tira as aspas depois dos redirecionamentos; o
`protect-merge` marca o texto citado; o `protect-files` usa `grep` e `sed`) e um só contrato pode mudar
resultados; a falha fechada gera falsos bloqueios; o divisor continua sem enxergar variáveis, `sh -c` e
aliases, então o `ask` e a leitura do dono seguem necessários.

**Daqui para frente:**
- Escrever o plano em `docs/plans` e implementar em TDD, um hook por vez.
- O divisor **reduz** o DEBT-002, não o quita: o que sobra (variáveis, `sh -c`, aliases, `cd`, `GH_REPO`
  exportado, glob) continua limitação. O plano inclui reescrever o DEBT-002 e fechar o ERR-003 só se essa
  limitação for aceita de forma explícita.
- Atualizar `docs/help` (`merge-de-pr.md`, `testes-dos-hooks.md`).
- Avaliar, à parte, fechar squash e rebase no GitHub (alternativa 4) e registrar em `protecao-de-branches.md`.
