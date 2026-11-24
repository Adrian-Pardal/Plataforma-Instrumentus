---
titulo: UC-01 — Cadastrar-se
proposito: Descrever como o Pesquisador cria a sua conta
status: rascunho
atualizado: 2026-11-24
mantido-por: /casos-de-uso
relacionados: [../../specs/000-visao-mvp.md, ../regras-de-negocio.md, ../../produto/glossario.md]
---

# UC-01 — Cadastrar-se
- **Ator principal:** Pesquisador
- **Outros atores:** nenhum
- **Objetivo:** criar uma conta para poder montar e publicar pesquisas.
- **Origem:** [spec 000](../../specs/000-visao-mvp.md), RF-01; resposta do dono (pergunta 6: com conta, e-mail e senha)
- **Pré-condições:** a pessoa ainda não entrou na plataforma.
- **Pós-condições (sucesso):** existe uma conta com o e-mail informado, e o Pesquisador pode entrar com ela (UC-02).
- **Pós-condições (falha):** nenhuma conta é criada.

## Fluxo principal
1. O Pesquisador informa o seu e-mail e uma senha.
2. A plataforma confere que o e-mail e a senha são válidos e que o e-mail ainda não tem conta.
3. A plataforma cria a conta.
4. A plataforma informa que o cadastro foi concluído.

## Fluxos alternativos
- Nenhum decidido. A confirmação do e-mail está em aberto (ver abaixo).

## Exceções
- **E1 (passo 2).** O e-mail não tem formato válido → o cadastro é recusado e a plataforma indica que o e-mail é inválido; nenhuma conta é criada.
- **E2 (passo 2).** O e-mail já tem conta → nenhuma conta nova é criada. **O que a plataforma diz é pergunta em aberto.**
- **E3 (passo 2).** A senha não atende às regras de senha → o cadastro é recusado. **As regras de senha são pergunta em aberto.**
- **E4 (passo 3).** A plataforma falha ao criar a conta → nenhuma conta parcial fica criada, o Pesquisador é informado e pode tentar de novo. *(proposta minha: confirme)*

## Regras de negócio envolvidas
- Nenhuma do catálogo se aplica diretamente. Se "um e-mail, uma conta" ou as regras de senha forem decididas, viram RN novas pela `/regras-negocio`.

## Inclui / estende
- Nenhum.

## Perguntas em aberto
- [ ] **E2:** se o e-mail já tem conta, a plataforma avisa isso (mais claro para quem se cadastra) ou responde de forma neutra (não revela quem tem conta)? No login (RF-01 CA-2), a spec já escolheu não revelar.
- [ ] **E3:** quais são as regras de senha (tamanho mínimo, outros)?
- [ ] **Passo 4:** depois do cadastro, o Pesquisador entra direto ou precisa fazer o UC-02?
- [ ] **Confirmação do e-mail:** existe? (já está nas perguntas em aberto da spec 000)
- [ ] **Glossário:** "conta" é termo novo; a `/glossario` precisa defini-lo.
