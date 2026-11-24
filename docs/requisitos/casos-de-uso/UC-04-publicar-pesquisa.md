---
titulo: UC-04 — Publicar pesquisa
proposito: Descrever como o Pesquisador publica uma pesquisa e obtém o link público
status: rascunho
atualizado: 2026-11-24
mantido-por: /casos-de-uso
relacionados: [../../specs/000-visao-mvp.md, ../regras-de-negocio.md, ../../produto/glossario.md, UC-03-montar-pesquisa.md]
---

# UC-04 — Publicar pesquisa
- **Ator principal:** Pesquisador
- **Outros atores:** nenhum
- **Objetivo:** abrir a pesquisa para respostas e obter o link público para compartilhar.
- **Origem:** [spec 000](../../specs/000-visao-mvp.md), RF-02 CA-3 e RF-03
- **Pré-condições:** o Pesquisador entrou (UC-02) e tem uma pesquisa montada (UC-03) que ainda não foi publicada nem encerrada.
- **Pós-condições (sucesso):** a pesquisa está publicada e aceita respostas (RN-06); existe um link público que o Pesquisador pode compartilhar.
- **Pós-condições (falha):** a pesquisa continua não publicada e não aceita respostas.

## Fluxo principal
1. O Pesquisador pede para publicar uma das suas pesquisas.
2. A plataforma confere que a pesquisa tem pelo menos uma seção (RN-07).
3. A plataforma publica a pesquisa e gera o link público.
4. A plataforma mostra o link ao Pesquisador, que o compartilha com os respondentes.

## Fluxos alternativos
- Nenhum decidido.

## Exceções
- **E1 (passo 2).** A pesquisa não tem nenhuma seção → a publicação é recusada e a pesquisa continua não publicada (RF-02 CA-3, RN-07).
- **E2 (passo 1).** A pesquisa já está publicada → **pergunta em aberto**.
- **E3 (passo 1).** A pesquisa já está encerrada → **pergunta em aberto**.
- **E4 (passo 1).** A pesquisa é de outro Pesquisador → acesso negado (RN-02).
- **E5 (passo 3).** A plataforma falha ao publicar → a pesquisa continua não publicada, o Pesquisador é informado e pode tentar de novo. *(proposta minha)*

## Regras de negócio envolvidas
- RN-02 — Acesso só às próprias pesquisas (E4)
- RN-06 — Só pesquisa publicada recebe respostas (passo 3)
- RN-07 — Pesquisa sem seção não se publica (passo 2 e E1)

## Inclui / estende
- Nenhum.

## Perguntas em aberto
- [ ] **E2:** publicar uma pesquisa já publicada mostra o mesmo link ou recusa?
- [ ] **E3:** uma pesquisa encerrada pode ser publicada de novo (reaberta)?
- [ ] O Pesquisador pode despublicar sem encerrar?
