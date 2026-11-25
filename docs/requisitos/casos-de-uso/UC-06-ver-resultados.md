---
titulo: UC-06 — Ver resultados
proposito: Descrever como o Pesquisador vê o resultado calculado de cada seção da sua pesquisa
status: rascunho
atualizado: 2026-11-24
mantido-por: /casos-de-uso
relacionados: [../../specs/000-visao-mvp.md, ../regras-de-negocio.md, ../../produto/glossario.md, UC-05-responder-pesquisa.md]
---

# UC-06 — Ver resultados
- **Ator principal:** Pesquisador
- **Outros atores:** nenhum
- **Objetivo:** ver o resultado de cada seção da sua pesquisa, calculado pelo método dela.
- **Origem:** [spec 000](../../specs/000-visao-mvp.md), RF-04 e RF-05
- **Pré-condições:** o Pesquisador entrou (UC-02) e tem uma pesquisa sua.
- **Pós-condições (sucesso):** o Pesquisador viu o resultado de cada seção. Nenhum dado foi alterado.
- **Pós-condições (falha):** nenhum resultado é mostrado e nenhum dado muda.

## Fluxo principal
1. O Pesquisador escolhe uma das suas pesquisas e pede os resultados.
2. A plataforma calcula, para cada seção, o resultado pelo método da seção (RN-03).
3. A plataforma mostra o resultado de cada seção, separado dos das outras.

## Fluxos alternativos
- Nenhum decidido.

## Exceções
- **E1 (passo 2).** A pesquisa ainda não tem respostas → a plataforma mostra o aviso "sem respostas" e nenhum cálculo quebra (RF-04 CA-2).
- **E2 (passo 1).** A pesquisa é de outro Pesquisador → acesso negado (RN-02).
- **E3 (passo 1).** Quem pede ainda não entrou → precisa entrar antes (UC-02). *(proposta minha)*
- **E4 (passo 2).** A plataforma falha ao calcular → o Pesquisador é informado e nenhum resultado parcial é mostrado como se fosse completo. *(proposta minha)*
- **E5 (passo 2).** Uma seção tem respostas insuficientes para o cálculo do método → **pergunta em aberto**.

## Regras de negócio envolvidas
- RN-02 — Acesso só às próprias pesquisas (passo 1 e E2)
- RN-03 — Seção calcula só pelo seu método (passos 2 e 3)

## Inclui / estende
- Nenhum.

## Perguntas em aberto
- [ ] Os resultados podem ser vistos com a pesquisa ainda aberta (parciais) ou só depois de encerrada?
- [ ] **E5:** o que o método faz com respostas incompletas (cada ficha tem um mínimo, a definir)?
- [ ] **Glossário:** "resultado" × "escore" (já nas perguntas do glossário).
