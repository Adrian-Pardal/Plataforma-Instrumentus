---
titulo: UC-05 — Responder pesquisa
proposito: Descrever como o Respondente responde uma pesquisa pelo link público, sem se identificar
status: rascunho
atualizado: 2026-11-24
mantido-por: /casos-de-uso
relacionados: [../../specs/000-visao-mvp.md, ../regras-de-negocio.md, ../../produto/glossario.md, UC-04-publicar-pesquisa.md]
---

# UC-05 — Responder pesquisa
- **Ator principal:** Respondente
- **Outros atores:** nenhum
- **Objetivo:** enviar as suas respostas a uma pesquisa, sem se identificar.
- **Origem:** [spec 000](../../specs/000-visao-mvp.md), RF-03; resposta do dono (perguntas 8 e 9)
- **Pré-condições:** o Respondente recebeu o link público de uma pesquisa.
- **Pós-condições (sucesso):** a resposta está guardada sem dado que identifique o Respondente (RN-01), e a pesquisa conta como respondida por aquele navegador (RN-05).
- **Pós-condições (falha):** nenhuma resposta é guardada.

## Fluxo principal
1. O Respondente abre o link público.
2. A plataforma confere que a pesquisa está publicada e não encerrada (RN-06) e que aquele navegador ainda não respondeu (RN-05).
3. A plataforma mostra as seções da pesquisa, em celular ou computador.
4. O Respondente responde os itens de cada seção, sem se identificar.
5. O Respondente envia as respostas.
6. A plataforma guarda a resposta sem dado que o identifique (RN-01) e informa que o envio foi concluído.

## Fluxos alternativos
- Nenhum decidido. "Salvar e continuar depois" não está na spec (ver perguntas em aberto).

## Exceções
- **E1 (passo 2).** A pesquisa não está publicada ou já foi encerrada → o Respondente não consegue responder (RF-03 CA-2, RN-06).
- **E2 (passo 2).** Aquele navegador já respondeu → a plataforma avisa e não conta nova resposta (RF-03 CA-3, RN-05).
- **E3 (passo 5).** O Respondente envia duas vezes quase ao mesmo tempo → só o primeiro envio conta (RN-05).
- **E4 (passo 5).** A pesquisa é encerrada enquanto o Respondente responde → **pergunta em aberto**.
- **E5 (passo 5).** Itens sem resposta ou valor fora da escala → **pergunta em aberto**.
- **E6 (passo 6).** A plataforma falha ao guardar → nenhuma resposta fica guardada, o Respondente é informado e pode tentar de novo. *(proposta minha)*

## Regras de negócio envolvidas
- RN-01 — Resposta anônima (passos 4 e 6)
- RN-05 — Limite leve de respostas por navegador (passo 2, E2 e E3)
- RN-06 — Só pesquisa publicada recebe respostas (passo 2 e E1)

## Inclui / estende
- Nenhum.

## Perguntas em aberto
- [ ] **E4:** o envio feito na hora do encerramento vale ou é recusado?
- [ ] **E5:** todos os itens são obrigatórios? Pode enviar resposta parcial? (a ficha do Likert fala em mínimo de itens para calcular)
- [ ] O Respondente pode salvar e continuar depois?
- [ ] O que o Respondente vê depois de enviar?
