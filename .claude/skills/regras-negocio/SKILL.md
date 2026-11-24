---
name: regras-negocio
description: Mantém docs/requisitos/regras-de-negocio.md, o catálogo único das regras RN-xx (enunciado, motivo, exemplos que valem e que não valem, exceções, onde é aplicada no código, testes que a cobrem) e atualiza a rastreabilidade das RN. Use quando uma spec for aprovada (a entrevista-spec a aciona), quando uma regra nascer, mudar ou for revogada, ou quando surgir código ou teste que a aplique. Não use para inventar regra que a spec não tem, para escrever requisito funcional (é da spec) nem para escrever código de validação.
argument-hint: "[<RN-xx> | <spec>]"
---

# Regras de negócio

## Conceito (para você, dono do projeto)
Três coisas que se confundem o tempo todo:

| | O que é | Exemplo | Onde mora |
|---|---|---|---|
| **Regra de negócio (RN)** | Verdade do domínio, vale em qualquer tela ou método | "A nota Likert vai de 1 a 5" | docs/requisitos/regras-de-negocio.md (uma vez só) |
| **Requisito funcional (RF)** | O que o sistema faz para alguém | "O respondente envia suas notas" | na spec de cada feature |
| **Validação** | O código que faz a RN ser cumprida | `if (nota < 1 \|\| nota > 5) rejeitar` | no código, ligado à RN |

A RN é o "o quê vale"; a validação é o "como se garante"; o RF é "quem faz o
quê com isso". A spec e o código apontam para o RN-xx em vez de repetir o
texto (docs/README, "ligar em vez de repetir"). Assim a IA não reinterpreta a
regra de um jeito em cada feature.

## Formato de cada regra
Em docs/requisitos/regras-de-negocio.md, em ordem de número, uma seção por regra:

```
### RN-01 — <título curto>
- **Enunciado:** <uma frase, testável: dá para dizer se foi cumprida>
- **Motivo:** <por que a regra existe>
- **Valem:** <exemplos concretos que cumprem a regra>
- **Não valem:** <exemplos concretos que a violam>
- **Exceções:** <nenhuma | caso e quem decidiu>
- **Origem:** <spec, RF ou ADR; ou "resposta do dono em AAAA-MM-DD">
- **Aplicada em:** <arquivo:símbolo, ou "a preencher na implementação">
- **Testes:** <CT-<feature>-NN, ou "a preencher">
- **Status:** Vigente | Revogada por RN-yy
```

## Passos
1. Argumento: `RN-xx` (revisar uma) ou spec (extrair as regras dela). Sem
   argumento, pergunte. Leia docs/requisitos/regras-de-negocio.md (se não
   existir, o primeiro uso o cria com o cabeçalho de
   docs/templates/cabecalho.md), a spec Aprovada e docs/requisitos/ à procura
   de decisões pendentes que viram RN. Sem spec Aprovada, PARE (CLAUDE.md §2),
   exceto para registrar uma RN já decidida pelo dono no chat.
2. Para cada regra candidata, na spec ou na resposta do dono:
   - **É RN?** Teste: vale em qualquer tela, método ou API? Se só descreve um
     fluxo ("o respondente clica em enviar"), é RF e fica na spec. Se descreve
     a checagem em si ("campo vazio mostra erro"), é validação e entra em
     "Aplicada em".
   - **Já existe?** Procure no catálogo regra de mesmo sentido, mesmo com
     palavras diferentes. Se existir, NÃO crie outra: ligue a spec à RN
     existente. Se houver conflito (duas regras que não podem valer juntas),
     vira pergunta ao dono.
   - **Tem base?** Só entra regra dita na spec, em ADR ou pelo dono. Falta
     enunciado, motivo ou exemplo que não valha? Vira PERGUNTA ao dono; nunca
     invente (CLAUDE.md §5).
3. Numere com o próximo RN-NN (2 dígitos; 3 se passar de 99). Número nunca é
   reutilizado nem renumerado. Regra que deixa de valer não some: vira
   `Revogada por RN-yy` (ou "Revogada, sem substituta") com o motivo.
4. MOSTRE o diff do catálogo e espere aprovação antes de salvar (CLAUDE.md §6).
   Só então grave com Write/Edit e atualize `atualizado` no cabeçalho.
5. **Spec:** a spec deve citar só "RN-xx — <título>" com link para o catálogo.
   Se ela repete o texto da regra, proponha o texto de troca e acione a
   `/entrevista-spec` para gravá-lo; esta skill não edita spec.
6. **Rastreabilidade:** atualize em docs/requisitos/rastreabilidade.md as
   linhas das RN tocadas (RN ↔ RF ↔ código ↔ CT), com o mesmo conteúdo dos
   campos "Aplicada em" e "Testes". Só preencha o que existe de verdade
   (arquivo e símbolo conferidos com grep; CT que consta no arquivo). O que
   não existe fica "a preencher". Se o arquivo não existir, avise e peça ao
   dono para acionar a `/rastreabilidade`; não improvise a matriz.
7. Lembre o dono de que RN nova ou alterada pede (i) `/glossario` se trouxer
   termo novo, (ii) `/casos-de-borda` e `/casos-de-teste` para derivar os
   testes, e (iii) uma task no plano se o código existente precisar mudar.
8. Atualize docs/requisitos/README.md se a tabela mudar.
9. Termine com 3–5 linhas explicando o que mudou e por quê (CLAUDE.md §7).

## Proibido
- Duplicar RN: duas regras com o mesmo sentido, ou o texto da regra copiado
  em spec, caso de uso ou teste em vez do RN-xx.
- Inventar regra, motivo, exemplo ou exceção que a spec, um ADR ou o dono
  não disseram.
- Misturar RF ou validação dentro da RN (a RN diz o que vale, não a tela nem
  o `if`).
- Reutilizar, renumerar ou apagar um RN-xx (revogue).
- Editar spec, código ou testes; a spec só muda pela `/entrevista-spec`.
- Salvar sem aprovação do dono.
- Preencher "Aplicada em" ou "Testes" com algo que não foi conferido.
- Criar ou editar arquivos por Bash (cat, echo, sed, tee, redirecionamento).

## Como verificar
- Cada RN tem os 9 campos, número único e crescente, e enunciado testável.
- Nenhum enunciado repete o sentido de outro (leia o catálogo inteiro).
- Toda RN tem "Origem" que existe e confere.
- Todo caminho de "Aplicada em" e todo CT de "Testes" existe
  (`grep`/ls), ou está "a preencher".
- `git diff --stat` mostra só o catálogo, a rastreabilidade (se existir) e
  os índices.
