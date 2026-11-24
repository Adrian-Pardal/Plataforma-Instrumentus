---
titulo: UC-08 — Encerrar pesquisa
proposito: Descrever como o Pesquisador encerra a coleta de uma pesquisa
status: rascunho
atualizado: 2026-11-24
mantido-por: /casos-de-uso
relacionados: [../../specs/000-visao-mvp.md, ../regras-de-negocio.md, ../../produto/glossario.md, UC-04-publicar-pesquisa.md]
---

# UC-08 — Encerrar pesquisa
- **Ator principal:** Pesquisador
- **Outros atores:** nenhum
- **Objetivo:** parar de receber respostas numa pesquisa publicada.
- **Origem:** [spec 000](../../specs/000-visao-mvp.md), RF-04 (encerramento) e RF-03 CA-2
- **Pré-condições:** o Pesquisador entrou (UC-02) e tem uma pesquisa sua publicada (UC-04).
- **Pós-condições (sucesso):** a pesquisa está encerrada e não aceita novas respostas (RN-06).
- **Pós-condições (falha):** a pesquisa continua como estava.

## Fluxo principal
1. O Pesquisador pede para encerrar uma das suas pesquisas publicadas.
2. A plataforma confere que a pesquisa é do Pesquisador e está publicada.
3. A plataforma encerra a pesquisa.
4. A plataforma informa que a pesquisa foi encerrada.

## Fluxos alternativos
- Nenhum decidido.

## Exceções
- **E1 (passo 2).** A pesquisa não está publicada → **pergunta em aberto**.
- **E2 (passo 2).** A pesquisa já está encerrada → **pergunta em aberto**.
- **E3 (passo 2).** A pesquisa é de outro Pesquisador → acesso negado (RN-02).
- **E4 (passo 3).** A plataforma falha ao encerrar → a pesquisa continua publicada, o Pesquisador é informado e pode tentar de novo. *(proposta minha)*

## Regras de negócio envolvidas
- RN-02 — Acesso só às próprias pesquisas (E3)
- RN-06 — Só pesquisa publicada recebe respostas (passo 3)

## Inclui / estende
- Nenhum.

## Perguntas em aberto
- [ ] Depois de encerrada, o Pesquisador continua vendo resultados (UC-06) e exportando respostas (UC-07)?
- [ ] O encerramento pode ser desfeito (reabrir)? (liga-se à pergunta do UC-04, E3)
- [ ] **E1 e E2:** encerrar uma pesquisa não publicada ou já encerrada é recusado ou não faz nada?
