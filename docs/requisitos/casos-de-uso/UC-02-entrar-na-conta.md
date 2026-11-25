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
- **Pré-condições:** o Pesquisador tem conta com e-mail confirmado (UC-01) e ainda não entrou.
- **Pós-condições (sucesso):** o Pesquisador está dentro da plataforma e vê a lista só das suas pesquisas.
- **Pós-condições (falha):** o Pesquisador não entra e nada muda.

## Fluxo principal
1. O Pesquisador informa o seu e-mail e a sua senha.
2. A plataforma confere os dados.
3. A plataforma reconhece o Pesquisador e mostra a lista das pesquisas dele.

## Fluxos alternativos
- Nenhum decidido. "Esqueci a senha" é a feature 1a do roadmap; vira UC próprio quando tiver spec.

## Exceções
- **E1 (passo 2).** E-mail ou senha incorretos, inclusive e-mail sem conta → o Pesquisador não entra, e a mensagem é a mesma nos dois casos, sem revelar se o e-mail existe (RF-01 CA-2).
- **E2 (passo 2).** Muitas tentativas seguidas erradas → **pergunta em aberto** (a spec não diz se há bloqueio).
- **E3 (passo 2).** A plataforma falha ao conferir os dados → o Pesquisador é informado e pode tentar de novo. *(proposta minha: confirme)*
- **E4 (passo 2).** O e-mail da conta ainda não foi confirmado → o Pesquisador não entra (RN-09). **O que a plataforma diz é pergunta em aberto (ver abaixo).**

## Regras de negócio envolvidas
- RN-02 — Acesso só às próprias pesquisas (passo 3)
- RN-09 — Só entra na conta quem confirmou o e-mail (E4)

## Inclui / estende
- Nenhum.

## Perguntas em aberto
- [ ] **E2:** deve haver limite de tentativas erradas? O que acontece depois dele?
- [ ] **E4:** a RF-01 CA-2 manda não revelar se o e-mail existe, mas dizer "confirme o seu e-mail" revela que a conta existe. A plataforma revela isso ou responde de forma neutra?
- [ ] **Duração:** por quanto tempo o Pesquisador continua dentro sem entrar de novo? E há "sair da conta"? (a spec não diz)
- [ ] **Glossário:** "conta" é termo novo (já anotado no UC-01).
