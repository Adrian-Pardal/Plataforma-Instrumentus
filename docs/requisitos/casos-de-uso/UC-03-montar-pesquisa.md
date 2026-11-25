---
titulo: UC-03 — Montar pesquisa
proposito: Descrever como o Pesquisador cria uma pesquisa com seções a partir de modelos de métodos
status: rascunho
atualizado: 2026-11-24
mantido-por: /casos-de-uso
relacionados: [../../specs/000-visao-mvp.md, ../regras-de-negocio.md, ../../produto/glossario.md, UC-02-entrar-na-conta.md]
---

# UC-03 — Montar pesquisa
- **Ator principal:** Pesquisador
- **Outros atores:** nenhum
- **Objetivo:** montar uma pesquisa com uma ou mais seções, cada uma a partir do modelo de um método.
- **Origem:** [spec 000](../../specs/000-visao-mvp.md), RF-02 e RF-05; resposta do dono (perguntas 2 e 4)
- **Pré-condições:** o Pesquisador entrou na plataforma (UC-02).
- **Pós-condições (sucesso):** existe uma pesquisa do Pesquisador, ainda não publicada, com as seções escolhidas, cada uma com os itens e o cálculo do seu método.
- **Pós-condições (falha):** a pesquisa não fica com seção incompleta ou fora das regras do método.

## Fluxo principal
1. O Pesquisador cria uma pesquisa nova.
2. Escolhe o modelo de um método para uma seção.
3. A plataforma adiciona a seção com os itens e o cálculo do método (RF-02 CA-1).
4. O Pesquisador adapta os campos que o método permite (RN-04).
5. O Pesquisador repete os passos 2 a 4 para cada outra seção que quiser, mesmo de métodos diferentes (RN-03).
6. A plataforma guarda a pesquisa como ainda não publicada.

## Fluxos alternativos
- **4a.** O Pesquisador não adapta nada → a seção fica com o modelo como está → segue para o passo 5.

## Exceções
- **E1 (passo 4).** O Pesquisador tenta alterar algo que o método não permite (itens, escala, cálculo) → a alteração é recusada e a seção segue como estava (RF-02 CA-2, RN-04).
- **E2 (qualquer passo).** O Pesquisador tenta mexer numa pesquisa de outro Pesquisador → acesso negado (RN-02).
- **E3 (passo 4).** O valor de um campo adaptável é vazio ou inválido → **pergunta em aberto**.
- **E4 (passo 6).** A plataforma falha ao guardar → nenhuma seção parcial é guardada, o Pesquisador é informado e pode tentar de novo. *(proposta minha)*

## Regras de negócio envolvidas
- RN-02 — Acesso só às próprias pesquisas (E2)
- RN-03 — Seção calcula só pelo seu método (passo 5)
- RN-04 — Adaptação limitada do modelo (passo 4 e E1)

## Inclui / estende
- Nenhum.

## Perguntas em aberto
- [ ] A pesquisa tem dados próprios além das seções (título, descrição)?
- [ ] Depois de montada, o Pesquisador pode remover, reordenar ou editar seções? E depois de publicada?
- [ ] Há limite de seções por pesquisa?
- [ ] **E3:** o que se faz com campo adaptável vazio, ou muito longo?
- [ ] Quais campos cada método permite adaptar? (decisão por método, já na spec 000)
