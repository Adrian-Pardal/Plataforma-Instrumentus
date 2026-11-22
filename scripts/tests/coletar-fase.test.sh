#!/usr/bin/env bash
# coletar-fase.test.sh — testes de scripts/pesquisa/coletar-fase.sh (plano 006, ADR 0007).
# Cada caso monta um projeto temporário (repositório git com commits de data fixa, ERR, sessões e eventos de
# exemplo) e aponta COLETA_RAIZ para ele. O "gh" é falso e o "claude" também: nenhum caso usa a rede nem uma IA.
# Uso: scripts/tests/coletar-fase.test.sh   (sai com 1 se algum caso falhar)
set -uo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$RAIZ/scripts/pesquisa/coletar-fase.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
falhas=0

if ! command -v git >/dev/null || ! command -v jq >/dev/null; then
  echo "• git ou jq não instalado: testes pulados"
  exit 0
fi

confere() {   # confere <esperado> <obtido> <descrição>
  if [[ "$1" == "$2" ]]; then
    echo "  ok    $3"
  else
    echo "  FALHA $3 (esperado '$1', veio '$2')" >&2
    falhas=$((falhas + 1))
  fi
}

# --- Ferramentas falsas (vão na frente do PATH) ---------------------------------------------------------------
mkdir -p "$TMP/gh-ok" "$TMP/gh-falha" "$TMP/gh-lotado" "$TMP/claude-falso"
# gh que responde ao "gh run list --created 2026-10-25..2026-10-28": 2 success, 1 failure, 1 em andamento.
# Guarda a pasta de onde foi chamado em $GH_CWD_ARQ (o gh de verdade descobre o repositório pela pasta).
cat > "$TMP/gh-ok/gh" <<'FIM'
#!/usr/bin/env bash
pwd > "${GH_CWD_ARQ:-/dev/null}"
case "$*" in
  "run list "*"--created 2026-10-25..2026-10-28"*) ;;
  "run list "*"--created 2026-10-26..2026-10-26"*) echo '[]'; exit 0 ;;
  *) echo "gh falso: argumentos inesperados: $*" >&2; exit 1 ;;
esac
echo '[{"workflowName":"CI","conclusion":"success"},{"workflowName":"CI","conclusion":"success"},{"workflowName":"CI","conclusion":"failure"},{"workflowName":"CI","conclusion":""}]'
FIM
printf '%s\n' '#!/usr/bin/env bash' 'echo "HTTP 401: sem acesso" >&2' 'exit 1' > "$TMP/gh-falha/gh"
# gh que devolve 1000 execuções (o limite do "gh run list --limit 1000"): a contagem pode estar incompleta.
printf '%s\n' '#!/usr/bin/env bash' "jq -n '[range(1000) | {workflowName: \"CI\", conclusion: \"success\"}]'" > "$TMP/gh-lotado/gh"
# claude que marca que foi chamado: o script NUNCA pode chamar uma IA.
printf '%s\n' '#!/usr/bin/env bash' "touch \"$TMP/claude-chamado\"" 'exit 99' > "$TMP/claude-falso/claude"
chmod +x "$TMP/gh-ok/gh" "$TMP/gh-falha/gh" "$TMP/gh-lotado/gh" "$TMP/claude-falso/claude"
# Caso "gh não instalado": uma pasta só com links para as ferramentas que o script usa, SEM o gh. (Tirar a pasta
# do gh do PATH não serve: ele está em /usr/bin, junto com o env e o bash.)
mkdir -p "$TMP/bin-sem-gh"
for ferramenta in bash env git jq date tr sed awk grep sort uniq head tail cat mkdir mv rm basename dirname cut ls wc; do
  ln -s "$(command -v "$ferramenta")" "$TMP/bin-sem-gh/$ferramenta" 2>/dev/null
done

# --- Montagem do projeto de exemplo ---------------------------------------------------------------------------
commit_em() {   # commit_em <pasta> <data ISO UTC>: commit vazio com a data fixa (sem assinatura nem hooks do git)
  GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git -C "$1" -c user.name=teste -c user.email=teste@exemplo.com \
    -c commit.gpgsign=false -c core.hooksPath=/dev/null commit -q --allow-empty -m "c $2" || { echo "FALHA: commit" >&2; exit 1; }
}
# Projeto com 5 commits: 2 FORA do intervalo 2026-10-25..2026-10-28 (um segundo antes e um segundo depois) e 3 dentro,
# dois deles exatamente nas bordas.
projeto() {   # projeto <nome>; deixa o caminho em P
  P="$TMP/$1"; mkdir -p "$P"
  git init -q -b main "$P" || { echo "FALHA: git init" >&2; exit 1; }
  commit_em "$P" "2026-10-24T23:59:59Z"
  commit_em "$P" "2026-10-25T00:00:00Z"
  commit_em "$P" "2026-10-26T12:00:00Z"
  commit_em "$P" "2026-10-28T23:59:59Z"
  commit_em "$P" "2026-10-29T00:00:00Z"
}

# cria_err <id> <data> <categoria>: um ERR de exemplo em P (só o frontmatter importa para a coleta)
cria_err() {
  mkdir -p "$P/docs/erros"
  printf -- '---\nid: %s\ntitulo: erro de exemplo\nstatus: corrigido\ncategoria: %s\ndata: %s\n---\n\n# %s\n' "$1" "$3" "$2" "$1" > "$P/docs/erros/$1-exemplo.md"
}

# cria_sessao <arquivo> <tipo>...: registro de sessão de exemplo, no formato que a skill /handoff gera, com uma linha
# na tabela "Intervenções humanas" para cada tipo dado. Põe também uma tabela na seção "Bloqueios do harness", que
# NÃO pode ser contada como intervenção.
cria_sessao() {
  local arq="$P/docs/pesquisa/sessoes/$1" i=0 t; shift
  mkdir -p "${arq%/*}"
  {
    printf '# Sessão\n\n## Feito\n- a\n\n## Intervenções humanas\n| # | O que o dono fez | Tipo |\n|---|---|---|\n'
    for t in "$@"; do i=$((i + 1)); printf '| %s | fez algo | %s |\n' "$i" "$t"; done
    printf '\n## Bloqueios do harness\n| hook | motivo | Decisão |\n|---|---|---|\n| protect-files | x | Decisão |\n\n## Minha percepção\n_a preencher_\n'
  } > "$arq"
}

# cria_eventos <linha>...: escreve .claude/pesquisa/eventos.jsonl em P com as linhas dadas (ev_bloqueio e ev_sessao as montam)
cria_eventos() { mkdir -p "$P/.claude/pesquisa"; printf '%s\n' "$@" > "$P/.claude/pesquisa/eventos.jsonl"; }
ev_bloqueio() { printf '{"quando":"%s","tipo":"bloqueio","hook":"%s","motivo":"adr-aceito","alvo":"x"}' "$1" "$2"; }   # <quando> <hook>
ev_sessao() { printf '{"quando":"%s","tipo":"sessao","hook":"session-start","versao":"9.9.9","branch":"main"}' "$1"; }  # <quando>

# coleta <args...>: roda o script no projeto P, com o gh de FAKE_GH (ok ou falha) e o claude falso; guarda RC e ERR.
coleta() {
  local caminho="$TMP/gh-${FAKE_GH:-ok}:$TMP/claude-falso:$PATH"
  [[ "${FAKE_GH:-ok}" == ausente ]] && caminho="$TMP/claude-falso:$TMP/bin-sem-gh"   # FAKE_GH=ausente: nenhum gh no PATH
  ERR=$(cd / && GH_CWD_ARQ="$TMP/gh-cwd" COLETA_RAIZ="$P" PATH="$caminho" "$SCRIPT" "$@" 2>&1 >/dev/null); RC=$?
}
CSV() { echo "$P/docs/pesquisa/dados/$1.csv"; }
# celula <slug> <metrica> <detalhe> <valor|nota>: o conteúdo da célula (vazio se a linha não existe ou a célula está vazia)
celula() { awk -F, -v m="$2" -v d="$3" -v c="$4" '$4==m && $5==d { print (c=="valor" ? $6 : $7); exit }' "$(CSV "$1")"; }
tem_linha() { awk -F, -v m="$2" -v d="$3" '$4==m && $5==d { f=1 } END { print f ? "sim" : "nao" }' "$(CSV "$1")"; }

echo "▶ coletar-fase: argumentos inválidos (exit 2, mensagem de uso, nada gravado)"
projeto args
coleta;                                       confere 2 "$RC" "sem argumentos"
confere true "$([[ "$ERR" == *Uso:* ]] && echo true || echo false)" "sem argumentos: mostra a mensagem de uso"
confere false "$([[ -e "$P/docs/pesquisa/dados" ]] && echo true || echo false)" "sem argumentos: não grava nada"
coleta "Fase 1" 2026-10-25;                   confere 2 "$RC" "falta a data final"
coleta "Fase 1" 2026-10-25 2026-10-28 extra;  confere 2 "$RC" "argumento a mais"
coleta "Fase 1" 2026-13-45 2026-10-28;        confere 2 "$RC" "data inválida (mês 13)"
coleta "Fase 1" 2026-02-30 2026-10-28;        confere 2 "$RC" "data que não existe (30 de fevereiro)"
coleta "Fase 1" 26-10-25 2026-10-28;          confere 2 "$RC" "data fora do formato AAAA-MM-DD"
coleta "Fase 1" 2026-10-28 2026-10-25;        confere 2 "$RC" "início depois do fim"
coleta "" 2026-10-25 2026-10-28;              confere 2 "$RC" "nome da fase vazio"
coleta "!!!" 2026-10-25 2026-10-28;           confere 2 "$RC" "nome sem nenhuma letra ou número"
confere false "$([[ -e "$P/docs/pesquisa/dados" ]] && echo true || echo false)" "nenhum erro de uso gravou arquivo"

echo "▶ coletar-fase: csv, nome do arquivo e commits"
projeto basico
coleta "Fase 1" 2026-10-25 2026-10-28
confere 0 "$RC" "caso feliz: exit 0"
confere "fase,inicio,fim,metrica,detalhe,valor,nota" "$(head -1 "$(CSV fase-1)")" "cabeçalho do csv"
confere "Fase 1,2026-10-25,2026-10-28,commits,total,3," "$(grep ',commits,total,' "$(CSV fase-1)")" "commits: 3 (bordas dentro, 1 s fora não conta)"
coleta "Fase 1" 2026-10-26 2026-10-26
confere 1 "$(celula fase-1 commits total valor)" "commits: intervalo de um dia só"
cp "$(CSV fase-1)" "$TMP/antes.csv"; coleta "Fase 1" 2026-10-26 2026-10-26
confere true "$(cmp -s "$TMP/antes.csv" "$(CSV fase-1)" && echo true || echo false)" "rodar de novo dá o mesmo arquivo"
coleta "Fase de Testes!" 2026-10-25 2026-10-28
confere true "$([[ -f "$(CSV fase-de-testes)" ]] && echo true || echo false)" "nome vira fase-de-testes.csv"
coleta "Fase 1, teste" 2026-10-25 2026-10-28
confere "\"Fase 1, teste\",2026-10-25,2026-10-28,commits,total,3," "$(grep ',commits,total,' "$(CSV fase-1-teste)")" "nome com vírgula vai entre aspas"
P="$TMP/sem-git"; mkdir -p "$P"
coleta "Fase 1" 2026-10-25 2026-10-28
confere 0 "$RC" "fora de repositório git: exit 0"
confere "sim" "$(tem_linha fase-1 commits total)" "fora de repositório git: a linha existe"
confere "" "$(celula fase-1 commits total valor)" "fora de repositório git: valor vazio, nunca 0"
confere "não é um repositório git" "$(celula fase-1 commits total nota)" "fora de repositório git: a nota diz por quê"

echo "▶ coletar-fase: execuções de CI (gh)"
projeto ci
coleta "Fase 1" 2026-10-25 2026-10-28
confere 4 "$(celula fase-1 ci total valor)" "ci: total de execuções"
confere 2 "$(celula fase-1 ci CI/success valor)" "ci: CI/success"
confere 1 "$(celula fase-1 ci CI/failure valor)" "ci: CI/failure"
confere 1 "$(celula fase-1 ci CI/em-andamento valor)" "ci: sem conclusão vira em-andamento"
confere "$P" "$(cat "$TMP/gh-cwd")" "ci: o gh roda na pasta do projeto"
coleta "Fase 1" 2026-10-26 2026-10-26
confere "sim" "$(tem_linha fase-1 ci total)" "ci: nenhuma execução: a linha existe"
confere 0 "$(celula fase-1 ci total valor)" "ci: nenhuma execução é 0 de verdade (o gh respondeu)"
FAKE_GH=falha coleta "Fase 1" 2026-10-25 2026-10-28
confere 0 "$RC" "gh falhando: a coleta segue (exit 0)"
confere "" "$(celula fase-1 ci total valor)" "gh falhando: valor vazio, nunca 0"
confere "gh indisponível ou sem acesso" "$(celula fase-1 ci total nota)" "gh falhando: a nota diz por quê"
confere true "$([[ "$ERR" == *aviso* ]] && echo true || echo false)" "gh falhando: aviso no stderr"
confere 3 "$(celula fase-1 commits total valor)" "gh falhando: as outras métricas continuam"
FAKE_GH=ausente coleta "Fase 1" 2026-10-25 2026-10-28
confere 0 "$RC" "gh ausente: a coleta segue (exit 0)"
confere "" "$(celula fase-1 ci total valor)" "gh ausente: valor vazio"
confere "gh não instalado" "$(celula fase-1 ci total nota)" "gh ausente: a nota diz por quê"
FAKE_GH=lotado coleta "Fase 1" 2026-10-25 2026-10-28
confere 1000 "$(celula fase-1 ci total valor)" "limite: conta as 1000"
confere "limite de 1000 execuções atingido; contagem pode estar incompleta" "$(celula fase-1 ci total nota)" "limite: nota de contagem possivelmente incompleta"

echo "▶ coletar-fase: ERR por categoria"
projeto err
cria_err ERR-001 2026-10-25 bug           # dentro (borda inicial)
cria_err ERR-002 2026-10-27 erro-ia       # dentro
cria_err ERR-003 2026-10-27 erro-ia       # dentro
cria_err ERR-004 2026-10-29 bug           # fora (depois)
cria_err ERR-005 2026-10-24 ambiente      # fora (antes)
cria_err ERR-006 2026-10-28 processo      # dentro (borda final), categoria que o plano não listava
printf '# Registro de erros\n\nSem frontmatter: não é um ERR.\n' > "$P/docs/erros/README.md"
printf -- '---\nid: ERR-007\ncategoria: bug\n---\n' > "$P/docs/erros/ERR-007-sem-data.md"   # frontmatter incompleto
coleta "Fase 1" 2026-10-25 2026-10-28
confere 1 "$(celula fase-1 err bug valor)" "err: bug (a de 29/10 e a sem data ficam fora)"
confere 2 "$(celula fase-1 err erro-ia valor)" "err: erro-ia"
confere 0 "$(celula fase-1 err ambiente valor)" "err: ambiente fora do intervalo é 0 (a pasta existe)"
confere 0 "$(celula fase-1 err producao valor)" "err: producao aparece mesmo sem nenhum"
confere 1 "$(celula fase-1 err processo valor)" "err: categoria nova também aparece"
confere 1 "$(celula fase-1 err sem-data-ou-categoria valor)" "err: ERR com frontmatter incompleto não some em silêncio"
confere 0 "$(awk -F, '$4=="err" && $5=="README" {n++} END {print n+0}' "$(CSV fase-1)")" "err: o README.md da pasta não conta como ERR"
projeto err-sem-pasta
coleta "Fase 1" 2026-10-25 2026-10-28
confere "" "$(celula fase-1 err total valor)" "sem docs/erros: valor vazio, nunca 0"
confere "pasta docs/erros ausente" "$(celula fase-1 err total nota)" "sem docs/erros: a nota diz por quê"

echo "▶ coletar-fase: intervenções humanas dos registros de sessão"
projeto sessoes
cria_sessao 2026-10-26.md "Decisão" "Aprovação" "Correção" "?"                                   # dentro
cria_sessao 2026-10-27-2.md "decisão" "DECISÃO" "Operação manual" "Aprendizado" "Desbloqueio" "Foo"  # dentro (outro dia, sufixo -2)
cria_sessao 2026-10-30.md "Decisão" "Decisão" "Decisão"                                          # fora (depois)
cria_sessao 2026-10-24.md "Aprovação" "Aprovação"                                                # fora (antes)
printf '# Sessão sem a tabela\n\n## Feito\n- a\n' > "$P/docs/pesquisa/sessoes/2026-10-28.md"      # dentro, mas sem a tabela
printf '# Registro de sessões\n\n| a | b | Decisão |\n' > "$P/docs/pesquisa/sessoes/README.md"
coleta "Fase 1" 2026-10-25 2026-10-28
confere 0 "$RC" "sessões: exit 0"
confere 3 "$(celula fase-1 intervencoes decisao valor)" "sessões: decisao (minúscula, maiúscula e acento normalizados)"
confere 1 "$(celula fase-1 intervencoes aprovacao valor)" "sessões: aprovacao (a de 24/10 fica fora)"
confere 1 "$(celula fase-1 intervencoes correcao valor)" "sessões: correcao"
confere 1 "$(celula fase-1 intervencoes operacao-manual valor)" "sessões: operacao-manual"
confere 1 "$(celula fase-1 intervencoes desbloqueio valor)" "sessões: desbloqueio"
confere 1 "$(celula fase-1 intervencoes aprendizado valor)" "sessões: aprendizado"
confere 2 "$(celula fase-1 intervencoes indefinido valor)" "sessões: '?' e tipo desconhecido viram indefinido"
confere 10 "$(celula fase-1 intervencoes total valor)" "sessões: total (a tabela de bloqueios, o README e as de fora não contam)"
confere 2 "$(celula fase-1 intervencoes sessoes-lidas valor)" "sessões: 2 sessões lidas"
confere 1 "$(celula fase-1 intervencoes sessoes-sem-tabela valor)" "sessões: a sessão sem tabela aparece, não some"
projeto sessoes-tipo-em-branco
cria_sessao 2026-10-26.md ""
coleta "Fase 1" 2026-10-25 2026-10-28
confere 1 "$(celula fase-1 intervencoes indefinido valor)" "sessões: linha com o tipo em branco conta como indefinido"
confere 1 "$(celula fase-1 intervencoes total valor)" "sessões: linha com o tipo em branco entra no total"
projeto sessoes-so-sem-tabela
mkdir -p "$P/docs/pesquisa/sessoes"; printf '# Sessão\n\n## Feito\n- a\n' > "$P/docs/pesquisa/sessoes/2026-10-26.md"
coleta "Fase 1" 2026-10-25 2026-10-28
confere "" "$(celula fase-1 intervencoes total valor)" "só sessões sem tabela: total vazio, nunca 0"
confere "nenhuma sessão do período tem a tabela Intervenções humanas" "$(celula fase-1 intervencoes total nota)" "só sessões sem tabela: a nota diz por quê"
confere 1 "$(celula fase-1 intervencoes sessoes-sem-tabela valor)" "só sessões sem tabela: a linha de aviso existe"
projeto sessoes-fora
cria_sessao 2026-11-02.md "Decisão"
coleta "Fase 1" 2026-10-25 2026-10-28
confere "" "$(celula fase-1 intervencoes total valor)" "sessão só fora do intervalo: valor vazio"
confere "sem registros de sessão no período" "$(celula fase-1 intervencoes total nota)" "sessão só fora do intervalo: a nota diz por quê"
projeto sem-sessoes
coleta "Fase 1" 2026-10-25 2026-10-28
confere "" "$(celula fase-1 intervencoes total valor)" "sem a pasta de sessões: valor vazio, nunca 0"
confere "sem registros de sessão no período" "$(celula fase-1 intervencoes total nota)" "sem a pasta de sessões: a nota diz por quê"

echo "▶ coletar-fase: bloqueios por hook"
projeto bloqueios
cria_eventos \
  "$(ev_sessao 2026-10-24T09:00:00Z)" \
  "$(ev_bloqueio 2026-10-26T10:00:00Z protect-files)" "$(ev_bloqueio 2026-10-26T11:00:00Z protect-files)" \
  "$(ev_bloqueio 2026-10-27T10:00:00Z protect-push)" "$(ev_bloqueio 2026-10-28T23:59:59Z protect-push)" \
  "$(ev_bloqueio 2026-10-25T00:00:00Z protect-merge)" "$(ev_bloqueio 2026-10-24T23:59:59Z protect-merge)" \
  "$(ev_bloqueio 2026-10-29T00:00:00Z stop-verify)" \
  "$(ev_bloqueio 2026-10-26T12:00:00Z novo-hook)" \
  "isto não é json" "42"
coleta "Fase 1" 2026-10-25 2026-10-28
confere 0 "$RC" "bloqueios: exit 0 (linhas que não são JSON são ignoradas)"
confere 2 "$(celula fase-1 bloqueios protect-files valor)" "bloqueios: protect-files"
confere 2 "$(celula fase-1 bloqueios protect-push valor)" "bloqueios: protect-push (a borda final conta)"
confere 1 "$(celula fase-1 bloqueios protect-merge valor)" "bloqueios: protect-merge (a borda inicial conta, 1 s antes não)"
confere 0 "$(celula fase-1 bloqueios stop-verify valor)" "bloqueios: hook sem bloqueio no intervalo é 0 (há dados cobrindo o período)"
confere 1 "$(celula fase-1 bloqueios novo-hook valor)" "bloqueios: hook que o script não conhecia também aparece"
confere "nao" "$(tem_linha fase-1 bloqueios cobertura)" "bloqueios: eventos cobrem o intervalo todo, sem aviso de cobertura"
projeto bloqueios-parcial
cria_eventos "$(ev_sessao 2026-10-27T08:00:00Z)" "$(ev_bloqueio 2026-10-27T10:00:00Z protect-push)"
coleta "Fase 1" 2026-10-25 2026-10-28
confere 1 "$(celula fase-1 bloqueios protect-push valor)" "cobertura parcial: a contagem sai"
confere "eventos só existem desde 2026-10-27; contagens parciais" "$(celula fase-1 bloqueios cobertura nota)" "cobertura parcial: a nota avisa desde quando há dados"
confere "" "$(celula fase-1 bloqueios cobertura valor)" "cobertura parcial: a linha de aviso não tem valor"
projeto bloqueios-depois
cria_eventos "$(ev_sessao 2026-11-22T08:00:00Z)" "$(ev_bloqueio 2026-11-22T10:00:00Z protect-files)"
coleta "Fase 1" 2026-10-25 2026-10-28
for h in protect-files protect-push protect-merge stop-verify; do
  confere "" "$(celula fase-1 bloqueios "$h" valor)" "intervalo antes dos eventos: $h sem valor, nunca 0"
  confere "eventos só existem desde 2026-11-22" "$(celula fase-1 bloqueios "$h" nota)" "intervalo antes dos eventos: $h com a nota"
done
projeto bloqueios-sem-arquivo
coleta "Fase 1" 2026-10-25 2026-10-28
confere "" "$(celula fase-1 bloqueios total valor)" "sem o arquivo de eventos: valor vazio"
confere "arquivo de eventos ausente" "$(celula fase-1 bloqueios total nota)" "sem o arquivo de eventos: a nota diz por quê"
projeto bloqueios-vazio
cria_eventos "so lixo, nenhuma linha válida"
coleta "Fase 1" 2026-10-25 2026-10-28
confere "" "$(celula fase-1 bloqueios total valor)" "arquivo sem nenhum evento válido: valor vazio"
confere "arquivo de eventos vazio" "$(celula fase-1 bloqueios total nota)" "arquivo sem nenhum evento válido: a nota diz por quê"

echo "▶ coletar-fase: nenhuma IA é chamada"
confere false "$([[ -e "$TMP/claude-chamado" ]] && echo true || echo false)" "o claude falso, que estava no PATH em todas as coletas, nunca foi chamado"

if [[ $falhas -gt 0 ]]; then
  echo "✖ $falhas caso(s) de coletar-fase falharam" >&2
  exit 1
fi
echo "✔ todos os casos de coletar-fase passaram"
