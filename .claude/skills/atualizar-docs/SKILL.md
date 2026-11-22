---
name: atualizar-docs
description: Audita todo docs/ e o README da raiz: confere o cabeçalho completo (6 campos), compara "atualizado" com o último commit do código descrito, procura links e caminhos de código quebrados, lista documentos órfãos, confere os README.md de cada pasta, o docs/README.md e o README.md da raiz, e entrega uma tabela de pendências por prioridade ANTES de corrigir. Use quando quiser conferir a saúde da documentação (ao fim de uma fase ou feature, ou antes de um PR de docs). Não use para escrever ou mudar conteúdo técnico de um documento: isso é da skill dona dele.
disable-model-invocation: true
---

# Atualizar docs

## Conceito (para você, dono do projeto)
Documentação envelhece em silêncio: o código muda e o texto continua
afirmando o que já não vale. Esta skill é uma auditoria: ela encontra o que
está velho, quebrado ou solto e arruma a parte MECÂNICA (índices, datas,
cabeçalhos). O conteúdo técnico continua sendo da skill dona do documento.

## Passos
1. **Inventário (só leitura).** Liste todos os .md de docs/ e o README.md da
   raiz. Se o README.md da raiz não existir, registre como pendência (não crie
   ainda).
2. **Cabeçalho.** Para cada documento (exceto os anteriores à Fase 3, que
   entram como prioridade baixa "sem cabeçalho"), confira os 6 campos de
   docs/templates/cabecalho.md: titulo, proposito, status (rascunho, vigente
   ou obsoleto), atualizado (AAAA-MM-DD válido), mantido-por (uma /skill ou
   "manual") e relacionados (caminhos que existem; IDs que existem).
3. **Frescor.** Para cada documento vigente, ache o código que ele descreve
   (caminhos citados no texto e em `relacionados`) e compare `atualizado` com
   `git log -1 --format=%cs -- <caminho>`. Código mais novo que o documento =
   candidato a desatualizado. Sem caminho de código citado: "não verificável",
   nunca suponha.
4. **Links e caminhos.** Confira links relativos [texto](caminho) e âncoras, e
   caminhos de código citados em crases (arquivos, scripts, skills). Aponte os
   que não existem mais, com o arquivo e a linha.
5. **Índices.** Confira se cada pasta de docs/ tem README.md e se ele lista
   todos os arquivos da pasta (e nenhum que não exista). Confira se o
   docs/README.md cobre todas as pastas e se o README.md da raiz aponta para o
   mapa. Tabelas geradas (ex.: docs/erros/README.md) só se confere; quem
   atualiza é a skill dona.
6. **Órfãos.** Liste documentos que nenhum outro documento nem índice
   referencia.
7. **Tabela de pendências (ANTES de corrigir).** Entregue e PARE:
   | # | Prioridade | Documento | Problema | Correção proposta | Quem corrige |
   Prioridades: 🔴 link/caminho quebrado ou documento vigente contradizendo o
   código; 🟡 `atualizado` defasado, índice incompleto, órfão, campo de
   cabeçalho inválido; 🟢 sem cabeçalho (pré-Fase 3), estilo. "Quem corrige":
   esta skill (mecânico) ou a skill dona (pelo campo `mantido-por`).
8. **Corrigir só com ok do dono**, item a item ou por prioridade. Esta skill
   corrige apenas: README.md de pasta, docs/README.md, README.md da raiz,
   campos `atualizado`/`relacionados` do cabeçalho e links quebrados cujo
   destino correto é inequívoco. Para o resto, diga qual skill acionar
   (`/registrar-adr`, `/registrar-erro`, `/handoff`, `/planejar`...). Se
   `mantido-por` for "manual", devolva ao dono.
9. Mostre cada arquivo alterado e espere aprovação antes de salvar. Depois
   rode `scripts/verify.sh test` e mostre a saída.

## Proibido
- Mudar conteúdo técnico (regra, requisito, decisão, contrato, código de
  exemplo) de um documento sem acionar a skill dona dele.
- Editar ADR Aceito (crie outro que o substitua, via /registrar-adr).
- Corrigir antes de entregar a tabela de pendências e receber o ok.
- Atualizar `atualizado` sem o conteúdo ter sido de fato conferido.
- Adivinhar o destino de um link quebrado ambíguo: pergunte.
- Migrar em massa documentos pré-Fase 3 (só listar como 🟢).
- Criar ou editar arquivos por Bash (cat, echo, sed, tee, redirecionamento).
- Salvar sem mostrar o conteúdo e receber aprovação.

## Como verificar
- A tabela de pendências foi entregue antes de qualquer edição.
- Nenhum arquivo fora do escopo do passo 8 foi alterado (`git diff --stat`).
- Todo README de pasta lista exatamente os arquivos da pasta.
- Links e caminhos reportados como quebrados passaram a existir ou foram
  removidos.
- `scripts/verify.sh test` mostrado, 100% verde.
