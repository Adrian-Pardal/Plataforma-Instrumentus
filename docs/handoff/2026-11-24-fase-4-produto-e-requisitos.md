---
titulo: Handoff — 2026-11-24 (fase 4: produto e requisitos)
proposito: Passar o contexto desta sessão para a próxima
status: vigente
atualizado: 2026-11-24
mantido-por: /handoff
relacionados: [../specs/000-visao-mvp.md, ../produto/roadmap.md, ../requisitos/regras-de-negocio.md, ../requisitos/casos-de-uso/README.md]
---

# Handoff — 2026-11-24 (fase 4: produto e requisitos)

## Onde estamos
Fase 4 (produto e requisitos), antes de qualquer código. Branch `docs/skills-fase-4`, sem upstream: os 16 commits
estão sem push. Sem commit: roadmap.md (feature 1a), spec 000 (recuperar senha decidido) e UC-02 (esqueci a senha).

## Feito
- 4 skills: glossario, regras-negocio, casos-de-uso e rastreabilidade (`92db093` a `c04b03e`).
- Spec 000 aprovada (`702a869`), com visão, personas e roadmap (`172f317`).
- Catálogo RN-01 a RN-09 (`3f6787b`, `3efb6d1`, `2c998e3`, `2489fce`).
- 8 casos de uso e diagrama PlantUML (`785f79d`, `b92ef3d`); glossário de 19 termos (`6150566`, `464db87`).
- Exceção de PlantUML para casos de uso no CLAUDE.md §10.6 (`0a87a81`).

## Em andamento
- Commit das 3 alterações pendentes. Sugestão: `docs(produto): inclui recuperar senha como feature 1a do roadmap`.
- Cerca de 45 perguntas em aberto na spec 000, glossário, catálogo de regras e UC-01 a UC-08.

## Próximo passo
Commitar as 3 alterações pendentes. Depois, responder (uma por vez) "editar ou excluir uma pesquisa", que afeta
UC-03, UC-04 e UC-08.

## Decisões
- Sem ADR novo. Decisões do dono: PlantUML nos casos de uso; IP é dado que identifica e o limite leve usa só um
  marcador no navegador (RN-01, RN-05); TFA em português é tradução não validada, com aviso (RN-08); e-mail
  confirmado antes de entrar (RN-09); recuperar senha é a feature 1a.
- Como enviar e-mail vira ADR quando a stack for decidida (o guia já foi atualizado pelo dono).

## Problemas
- A licença dos itens do TFA ainda não foi conferida (o dono confere); bloqueia a feature 2.
- UC-02 E4: dizer "confirme o e-mail" revela que a conta existe, o que a RF-01 CA-2 proíbe. Sem decisão.
- Glossário: faltam "resposta × envio", "respondente × participante" e o termo "conta". O roadmap usa "tipos de pergunta".
- Faltam: requisitos-nao-funcionais.md, rastreabilidade.md (`/rastreabilidade`, manual), a stack e o PR.
- Nenhum ERR novo e nenhum bloqueio de hook registrado hoje.

## Estado da verificação
`scripts/verify.sh test` em 2026-11-24 23:35:
- Resultado: passou (testes dos scripts ok; nenhuma stack detectada, então nenhum teste de código rodou).
- Dívidas abertas: ver docs/DEBT.md
