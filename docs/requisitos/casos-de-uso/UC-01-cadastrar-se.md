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
- **Pós-condições (sucesso):** existe uma conta com o e-mail informado e confirmado, e o Pesquisador pode entrar com ela (UC-02).
- **Pós-condições (falha):** nenhuma conta é criada. Se o link de confirmação não for aberto, a conta existe sem confirmação e não permite entrar (RN-09).

## Fluxo principal
1. O Pesquisador informa o seu e-mail e uma senha.
2. A plataforma confere que o e-mail e a senha são válidos e que o e-mail ainda não tem conta.
3. A plataforma cria a conta.
4. A plataforma envia ao e-mail informado um link de confirmação e avisa o Pesquisador para abri-lo.
5. O Pesquisador abre o link.
6. A plataforma confirma o e-mail e informa que o cadastro foi concluído.

## Fluxos alternativos
- Nenhum decidido. O reenvio do link está em aberto (ver abaixo).

## Exceções
- **E1 (passo 2).** O e-mail não tem formato válido → o cadastro é recusado e a plataforma indica que o e-mail é inválido; nenhuma conta é criada.
- **E2 (passo 2).** O e-mail já tem conta → nenhuma conta nova é criada. **O que a plataforma diz é pergunta em aberto.**
- **E3 (passo 2).** A senha não atende às regras de senha → o cadastro é recusado. **As regras de senha são pergunta em aberto.**
- **E4 (passo 3).** A plataforma falha ao criar a conta → nenhuma conta parcial fica criada, o Pesquisador é informado e pode tentar de novo. *(proposta minha: confirme)*
- **E5 (passo 5).** O link é inválido ou expirou → o e-mail não é confirmado e a conta continua sem permitir entrar. **O que acontece depois (reenviar, validade) é pergunta em aberto.**
- **E6 (passo 4).** A plataforma falha ao enviar o e-mail → o Pesquisador é informado e pode pedir o envio de novo. *(proposta minha: confirme)*

## Regras de negócio envolvidas
- RN-09 — Só entra na conta quem confirmou o e-mail (passos 4 a 6)
- Se "um e-mail, uma conta" ou as regras de senha forem decididas, viram RN novas pela `/regras-negocio`.

## Inclui / estende
- Nenhum.

## Perguntas em aberto
- [ ] **E2:** se o e-mail já tem conta, a plataforma avisa isso (mais claro para quem se cadastra) ou responde de forma neutra (não revela quem tem conta)? No login (RF-01 CA-2), a spec já escolheu não revelar.
- [ ] **E3:** quais são as regras de senha (tamanho mínimo, outros)?
- [ ] **Passo 6:** depois de confirmar o e-mail, o Pesquisador entra direto ou precisa fazer o UC-02?
- [x] **Confirmação do e-mail:** decidido em 2026-11-24 (RN-09).
- [ ] **E5 e RN-09:** por quanto tempo o link vale, e como o Pesquisador pede um novo?
- [ ] **E2 e RN-09:** se o e-mail já tem uma conta ainda não confirmada, o que acontece?
- [ ] **Glossário:** "conta" é termo novo; a `/glossario` precisa defini-lo.
