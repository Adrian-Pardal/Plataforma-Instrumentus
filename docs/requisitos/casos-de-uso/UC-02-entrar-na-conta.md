---
titulo: UC-02 — Entrar na conta
proposito: Descrever como o Pesquisador entra na plataforma e vê as suas pesquisas
status: rascunho
atualizado: 2026-11-24
mantido-por: /casos-de-uso
relacionados: [../../specs/000-visao-mvp.md, ../regras-de-negocio.md, ../../produto/glossario.md, UC-01-cadastrar-se.md]
---

# UC-02 — Entrar na conta
- **Ator principal:** Pesquisador
- **Outros atores:** nenhum
- **Objetivo:** acessar a plataforma com a sua conta para trabalhar nas suas pesquisas.
- **Origem:** [spec 000](../../specs/000-visao-mvp.md), RF-01 (CA-1, CA-2)
- **Pré-condições:** o Pesquisador tem conta (UC-01) e ainda não entrou.
- **Pós-condições (sucesso):** o Pesquisador está dentro da plataforma e vê a lista só das suas pesquisas.
- **Pós-condições (falha):** o Pesquisador não entra e nada muda.

## Fluxo principal
1. O Pesquisador informa o seu e-mail e a sua senha.
2. A plataforma confere os dados.
3. A plataforma reconhece o Pesquisador e mostra a lista das pesquisas dele.

## Fluxos alternativos
- Nenhum decidido. "Esqueci a senha" está em aberto na spec 000.

## Exceções
- **E1 (passo 2).** E-mail ou senha incorretos, inclusive e-mail sem conta → o Pesquisador não entra, e a mensagem é a mesma nos dois casos, sem revelar se o e-mail existe (RF-01 CA-2).
- **E2 (passo 2).** Muitas tentativas seguidas erradas → **pergunta em aberto** (a spec não diz se há bloqueio).
- **E3 (passo 2).** A plataforma falha ao conferir os dados → o Pesquisador é informado e pode tentar de novo. *(proposta minha: confirme)*

## Regras de negócio envolvidas
- RN-02 — Acesso só às próprias pesquisas (passo 3)

## Inclui / estende
- Nenhum.

## Perguntas em aberto
- [ ] **E2:** deve haver limite de tentativas erradas? O que acontece depois dele?
- [ ] **Duração:** por quanto tempo o Pesquisador continua dentro sem entrar de novo? E há "sair da conta"? (a spec não diz)
- [ ] **Glossário:** "conta" é termo novo (já anotado no UC-01).
