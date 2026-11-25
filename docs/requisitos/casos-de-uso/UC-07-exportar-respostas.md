---
titulo: UC-07 — Exportar respostas
proposito: Descrever como o Pesquisador baixa as respostas de uma pesquisa em planilha, sem dado que identifique o respondente
status: rascunho
atualizado: 2026-11-24
mantido-por: /casos-de-uso
relacionados: [../../specs/000-visao-mvp.md, ../regras-de-negocio.md, ../../produto/glossario.md, UC-06-ver-resultados.md]
---

# UC-07 — Exportar respostas
- **Ator principal:** Pesquisador
- **Outros atores:** nenhum
- **Objetivo:** levar as respostas de uma pesquisa para uma planilha, para analisá-las fora da plataforma.
- **Origem:** [spec 000](../../specs/000-visao-mvp.md), RF-07; resposta do dono (pergunta 7)
- **Pré-condições:** o Pesquisador entrou (UC-02) e tem uma pesquisa sua com respostas.
- **Pós-condições (sucesso):** o Pesquisador tem um arquivo em planilha com todas as respostas da pesquisa, sem dado que identifique os Respondentes (RN-01). Nenhum dado da plataforma foi alterado.
- **Pós-condições (falha):** nenhum arquivo é entregue.

## Fluxo principal
1. O Pesquisador escolhe uma das suas pesquisas e pede para exportar as respostas.
2. A plataforma reúne todas as respostas da pesquisa, sem dado que identifique os Respondentes (RN-01).
3. A plataforma entrega ao Pesquisador o arquivo em planilha.

## Fluxos alternativos
- Nenhum decidido.

## Exceções
- **E1 (passo 2).** A pesquisa não tem respostas → **pergunta em aberto**.
- **E2 (passo 1).** A pesquisa é de outro Pesquisador → acesso negado (RF-07 CA-2, RN-02).
- **E3 (passo 1).** Quem pede ainda não entrou → precisa entrar antes (UC-02). *(proposta minha)*
- **E4 (passo 3).** A plataforma falha ao gerar o arquivo → o Pesquisador é informado e nenhum arquivo incompleto é entregue. *(proposta minha)*

## Regras de negócio envolvidas
- RN-01 — Resposta anônima (passo 2; RF-07 CA-3)
- RN-02 — Acesso só às próprias pesquisas (passo 1 e E2)

## Inclui / estende
- Nenhum.

## Perguntas em aberto
- [ ] **E1:** arquivo vazio ou aviso "sem respostas"?
- [ ] Formato (CSV ou outro) e conteúdo (valores brutos, resultados, ou os dois)? (já na spec 000)
- [ ] Pode exportar com a pesquisa ainda aberta?
