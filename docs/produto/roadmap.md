---
titulo: Roadmap
proposito: Listar as features do MVP em ordem, com o que depende de quê e o status
status: rascunho
atualizado: 2026-11-24
mantido-por: /planejar
relacionados: [../specs/000-visao-mvp.md, ../metodos/README.md, visao.md]
---

# Roadmap

A divisão e a ordem são **propostas** e aguardam o ok do dono. Os números das specs são dados quando cada spec nasce.

| # | Feature | RF | Depende de | Status |
|---|---|---|---|---|
| 1 | Conta do pesquisador | RF-01 | — | sem spec |
| 1a | Recuperar senha (por link enviado ao e-mail) | a definir | 1 | sem spec |
| 2 | Montar pesquisa TFA (modelo, versão, adaptação limitada) | RF-02, RF-06 | 1 | sem spec |
| 3 | Publicar e responder (link, anônimo, limite leve, celular) | RF-03 | 2 | sem spec |
| 4 | Resultados do TFA e encerrar pesquisa | RF-04 | 3 | sem spec |
| 5 | Tipos de pergunta básicos (Likert, múltipla escolha, escala numérica, perguntas abertas) | RF-06 | 4 | sem spec |
| 6 | Pesquisa com várias seções | RF-05 | 5 | sem spec |
| 7 | AIM/IAM/FIM e SUS | RF-06 | 6 | sem spec |
| 8 | Exportar respostas | RF-07 | 4 | sem spec |
| 9 | Validação com pesquisa real (critério de pronto b) | — | 1 a 8 | sem spec |

**Depois do MVP:** os 23 métodos das etapas 2 a 5; modos de modelo travado e editável.

**Bloqueio conhecido:** a feature 2 depende de o dono conferir a licença dos itens do TFA; os itens serão traduzidos como tradução não validada (RN-08).
