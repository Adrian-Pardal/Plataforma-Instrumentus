# NOME
complexidade — ver quais funções de scripts bash têm decisões demais

Última verificação: 2026-11-21 · Testado com: bash 5.2, awk (gawk)

## PARA QUE SERVE
O `scripts/complexidade.sh` lê arquivos `.sh` e, para cada função, mostra
1 + o número de pontos de decisão: `if`, `elif`, `while`, `until`, `for`,
`&&`, `||` e cada ramo de um `case`. Quanto maior o número, mais caminhos a
função tem e mais difícil é entendê-la e testá-la.

É uma **aproximação por texto**, não a complexidade ciclomática oficial, e não
calcula complexidade cognitiva. Serve para apontar suspeitas e acompanhar uma
refatoração (T7f do plano 001, meta: abaixo de 10). Não faz parte do
`scripts/verify.sh`: só mede.

## QUANDO FAZER
- Antes e depois de refatorar uma função de bash.
- Antes de pedir a `/revisar` de uma branch que mexe em scripts ou hooks.

## PRÉ-REQUISITOS
- `awk` e `sort` (já vêm no sistema).

## PASSO A PASSO
1. Meça um arquivo (limite padrão: 10 pontos).
   ```bash
   scripts/complexidade.sh .claude/hooks/lib/divisor.sh
   ```
2. Para outro limite, ou vários arquivos de uma vez:
   ```bash
   scripts/complexidade.sh -l 15 .claude/hooks/*.sh scripts/*.sh
   ```
3. A saída é `pontos função (arquivo)`, da maior para a menor.

## COMO CONFERIR QUE DEU CERTO
- Sai com 0 se nenhuma função passou do limite; com 1 se alguma passou (a
  lista mostra quais); com 2 se faltou o arquivo.
- Os testes da própria ferramenta: `scripts/tests/complexidade.test.sh`.

## SE DER ERRADO
- **Número que parece errado:** a contagem é por texto. Pode errar num `case`
  com o ramo escrito em várias linhas, ou num `if` dentro de `$( )`. Nesses
  casos vale a leitura humana; o script só aponta suspeitas.
- **Função não aparece:** só entram funções declaradas como `nome() {` no
  começo da linha, fechadas por `}` no começo da linha.
- **Voltar atrás:** a ferramenta não altera nada, não há o que desfazer.

## VER TAMBÉM
- `docs/plans/001-divisor-de-comandos.md` (T7f)
- `docs/help/ferramentas/testes-dos-hooks.md`
