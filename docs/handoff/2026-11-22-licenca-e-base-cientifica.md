---
titulo: Handoff — 2026-11-22 (licença e base científica)
proposito: Passar o contexto desta sessão para a próxima
status: vigente
atualizado: 2026-11-22
mantido-por: /handoff
relacionados: [../metodos/README.md, ../requisitos/anonimato-e-ligacao-de-respostas.md]
---

# Handoff — 2026-11-22 (licença e base científica)

## Onde estamos
Trabalho de documentação, fora do ciclo spec → plano → código: licença, citação e fichas dos 30 métodos. Nenhuma spec
nem plano foi tocado. A stack continua "a definir".

## Feito
- `LICENSE` (MIT, titular Adrian Pardal Caldeiras), `README.md` da raiz (bilíngue, com Base científica, Como citar e
  Licença) e `CITATION.cff` (cff-version 1.2.0, YAML válido).
- `docs/metodos/`: índice com os 30 métodos (nível, tema, etapa, status, versão, condição de uso) e as 30 fichas, em
  cinco commits, um por etapa do guia. Cada ficha: como funciona, regras para o código, teste de referência,
  fundamentação, condição de uso, versão em português, perguntas em aberto e referências em ABNT.
- DOIs conferidos no Crossref (um DOI do documento de origem estava errado e foi corrigido: Santos et al., 2013).
  Exemplos numéricos das Etapas 4 e 5 recalculados; todos batem com o documento.
- Termos de uso lidos nas páginas oficiais de: Bain (marca "NPS"), UEQ (só a página inicial), NASA-TLX, PHQ Screeners
  (página /terms) e do artigo de Weiner et al. (AIM/IAM/FIM, texto aberto no Europe PMC).
- `docs/requisitos/anonimato-e-ligacao-de-respostas.md`: decisão pendente registrada, com métodos afetados, três
  opções e perguntas derivadas. Fichas afetadas apontam para ele em `relacionados`.
- Branch `docs/licenca-e-base-cientifica`, criada a partir da `develop`, com 10 commits (9 de conteúdo e este handoff).

## Em andamento
- Push da branch e PR para a `develop`: é o passo seguinte desta sessão; confira com `gh pr list` se já foi aberto.
- Item 5 do pedido original ("a tela de resultado mostra a referência do método") não foi feito: é código e depende
  de spec e plano. As fichas já trazem a referência que a tela vai exibir.

## Próximo passo
Conferir o PR (CI verde, `/revisar` sem 🔴/🟡) e, quando você pedir, fazer o merge por merge commit na `develop`. Depois,
decidir a RN do anonimato antes da spec de qualquer método que liga respostas (pré e pós-teste, Delphi, 360°, IVC).

## Decisões
- Licença MIT (comparação com Apache-2.0 e AGPL-3.0 feita na sessão; escolha do dono). `LICENSE` só em inglês; o
  README é bilíngue e diz que o texto em inglês é o que vale.
- AIM/IAM/FIM numa ficha só; UEQ e UEQ-S numa ficha só; TAM e UTAUT numa ficha só.
- Nas fichas, a ficha não reproduz itens de questionário nem a redação de perguntas de instrumentos.
- A ficha de probabilidade de recomendação não usa o nome de marca; chama "marca registrada de terceiros".
- Nenhum ADR novo nesta sessão. A decisão do anonimato é uma pendência de RN (e ADR se mudar o modelo de dados).

## Problemas
- **Condição de uso "não verificada"** (vinda só do documento de métodos): SUS, TAM/UTAUT, UMUX-Lite, CSAT, CES, SEQ e os
  métodos gerais. Antes de reproduzir itens de qualquer questionário, conferir a licença na fonte.
- PHQ-9 e GAD-7: o site não menciona tradução nem nomeia o titular. Ler os Termos de Uso da Pfizer.
- UEQ: o Aviso Legal do site não foi lido; licença formal e instrução de citação não constam na página inicial.
- TFA: a licença CC BY 4.0 é do artigo; falta conferir se o questionário está no texto ou no material suplementar.
- Probabilidade de recomendação: a página da Bain não diz expressamente que o cálculo é livre.
- Avaliação 360°: a média dos outros permite recuperar a média do grupo oculto (pergunta em aberto na ficha).
- PHQ-9: alerta do item 9 em pesquisa anônima (pergunta em aberto na ficha).
- SUS em português: a página da revista registra o título em espanhol e o sobrenome como "Carmona Valentim"; a ficha
  usa "Valentim". Conferir no PDF em português.
- Buscas de versão em português foram feitas só no Crossref; "não encontrada" não equivale a "não existe".
- A aba "Catálogo de métodos" do guia não estava em disco; etapa veio da tabela do guia e as "perguntas em aberto" vêm
  das admissões do próprio documento de métodos.
- Dependências estatísticas citadas nas fichas (por exemplo, para Wilcoxon, Bradley-Terry, MaxDiff) precisam entrar no
  plano antes de uso (CLAUDE.md, seção 9).

## Estado da verificação
`scripts/verify.sh test`, em 2026-11-22 22:47:
- Resultado: passou (saída 0). Nenhum teste desativado ou isolado; 14 scripts de `scripts/tests/*.test.sh`
  rodaram, sem falhas. Aviso esperado: nenhuma stack detectada (Maven, Gradle ou npm), nada a executar.
- Hooks de commit (gitleaks, `verify-quick`, `conventional-commits`) passaram nos 9 commits de conteúdo.
- Testes desativados/dívidas abertas: ver docs/DEBT.md (sem mudança nesta sessão).
