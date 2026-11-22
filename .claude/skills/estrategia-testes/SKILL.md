---
name: estrategia-testes
description: Define e mantém docs/testes/estrategia.md (pirâmide: unitário, integração com Testcontainers, contrato, E2E, propriedades, mutação, segurança e carga; o que cada nível cobre, ferramentas e metas; TDD como método padrão; CI só com 100% dos testes passando; cobertura meta 100%) e docs/testes/qualidade.md (métricas atuais com data, lidas dos relatórios reais). Use ao decidir ou mudar a estratégia de testes, ao entrar uma ferramenta de teste nova, ou para atualizar as métricas depois de rodar os relatórios. Não use para escrever casos de teste (isso é /casos-de-teste), implementar testes nem para registrar métrica sem relatório.
disable-model-invocation: true
---

# Estratégia de testes

## Conceito (para você, dono do projeto)
A estratégia diz QUE tipos de teste existem, o que cada um protege, com que
ferramenta e até onde queremos chegar (a pirâmide: muitos testes rápidos na
base, poucos lentos no topo). A qualidade é o placar: números medidos,
com data e de onde vieram. Estratégia é intenção; qualidade é fato.

## Passos
1. Leia docs/testes/estrategia.md e qualidade.md (se existirem), o ADR 0002,
   o CLAUDE.md §3, docs/DEBT.md e a stack decidida (ADRs em docs/adr/). Sem
   stack decidida, as ferramentas ficam "a definir (ver ADR)"; não escolha
   ferramenta por conta própria.
2. **estrategia.md.** Cabeçalho de docs/templates/cabecalho.md
   (`mantido-por: /estrategia-testes`). Uma seção por nível: unitário,
   integração (Testcontainers), contrato, E2E, propriedades, mutação,
   segurança, carga. Em cada uma: o que cobre, o que NÃO cobre, ferramenta,
   quando roda (local, CI, periódico) e meta. Deixe explícito, no topo:
   - TDD é o método padrão ([ADR 0002](../adr/0002-tdd-como-metodo-padrao.md)).
   - O CI só aprova com 100% dos testes passando (CLAUDE.md §3).
   - A meta de cobertura é 100%, decidida pelo dono em 2026-11-22.
   - Teste desativado ou isolado só com entrada em docs/DEBT.md.
3. **Ferramentas e metas** são decisão do dono: para cada nível sem
   ferramenta ou meta definida, apresente 2–3 opções com prós e contras e
   espere a escolha. Escolha de ferramenta importante aciona `/registrar-adr`.
   Meta que o dono não definiu fica como "a definir"; nunca invente número.
   A única meta já definida é a cobertura de 100%. Ao documentá-la, deixe
   como pergunta em aberto o que a spec/ADR ainda não fixou (tipo: linha ou
   ramo; exclusões como código gerado), e sugira `/registrar-adr` para
   formalizá-la.
4. **qualidade.md.** Cabeçalho padrão (`mantido-por: /estrategia-testes`) e
   uma tabela: Métrica | Valor | Data | Fonte (caminho do relatório e comando
   que o gerou). Métricas: testes (total/passando), cobertura, mutação,
   complexidade, e as que a estratégia definir. Para atualizar, RODE o
   comando (`scripts/verify.sh full` ou o do relatório) e leia o relatório
   gerado; copie o valor exato. Relatório inexistente ou comando que não
   roda: a linha fica "sem medição (motivo)", sem valor.
5. Mantenha o histórico: ao atualizar, não apague a medição anterior; inclua a
   nova linha com data (a mais recente primeiro).
6. Atualize `atualizado` do cabeçalho e a tabela de docs/testes/README.md
   (Status de "a criar" para "vigente").
7. MOSTRE cada arquivo inteiro e espere aprovação antes de salvar.
8. Rode `scripts/verify.sh test` e mostre a saída.

## Proibido
- Registrar métrica sem fonte (relatório real, com caminho, data e comando).
- Estimar, arredondar a favor ou lembrar de memória um valor de métrica.
- Inventar ferramenta, versão ou meta; escolher ferramenta sem o dono.
- Enfraquecer a regra de 100% de testes passando, ou baixar a meta de
  cobertura de 100%, ou afrouxar qualquer meta para "caber" (CLAUDE.md §3).
  Mudar a meta só por decisão do dono, registrada em ADR novo.
- Escrever casos de teste (CT-xx): são da `/casos-de-teste`.
- Salvar sem mostrar o conteúdo e receber aprovação.
- Criar ou editar arquivos por Bash (cat, echo, sed, tee, redirecionamento).

## Como verificar
- estrategia.md tem os 8 níveis, cada um com cobre, ferramenta, quando roda
  e meta (ou "a definir"), e declara TDD padrão, CI com 100% dos testes e
  cobertura de 100%.
- Toda linha de qualidade.md tem valor, data e fonte que existe; sem fonte,
  está "sem medição".
- docs/testes/README.md lista os dois arquivos.
- `scripts/verify.sh test` mostrado, 100% verde.
