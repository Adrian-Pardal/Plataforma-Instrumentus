---
name: rastreabilidade
description: Monta e audita docs/requisitos/rastreabilidade.md, a matriz RF/CA ↔ RN ↔ UC ↔ classe/rota ↔ CT ↔ teste automatizado, e destaca requisito sem teste, teste sem requisito e regra sem implementação. Só marca "coberto" quando aponta o teste real (arquivo e nome conferidos). Use sob demanda (/rastreabilidade [feature]), antes da /revisar de uma feature e ao fim de cada fase. Não use para escrever spec, RN, UC, caso de teste ou teste, nem para afirmar que um teste passa sem mostrar a saída do verify.sh.
argument-hint: "[<feature>]"
disable-model-invocation: true
---

# Rastreabilidade

## Conceito (para você, dono do projeto)
Rastreabilidade é poder seguir um fio do pedido até a prova: do requisito
(RF/CA) passando pela regra (RN) e pelo caso de uso (UC) até o código e o teste
que o protege. Se o fio quebra, há um problema:
- **Requisito sem teste:** ninguém avisa se ele quebrar.
- **Teste sem requisito:** teste que protege algo que ninguém pediu (ou
  requisito que ficou esquecido na spec).
- **Regra sem implementação:** a RN existe no papel e o código não a aplica.

Para a IA isso é um freio: "feito" só vale com o teste real apontado.

## Quem escreve o quê
Esta skill é dona da ESTRUTURA do arquivo e da auditoria. Células específicas
são preenchidas por outras skills, cada uma só na sua parte:
- `/regras-negocio`: as linhas de RN, com "Aplicada em" e "Testes".
- `/casos-de-teste`: a coluna CT e o teste automatizado dos casos.
- `/casos-de-uso`: a coluna UC (esta skill a lê e confere).
Esta skill lê as fontes, confere cada ponteiro e escreve a matriz e a situação.

## Formato de docs/requisitos/rastreabilidade.md
Cabeçalho de docs/templates/cabecalho.md e, por feature, uma tabela
com uma linha por critério de aceite (CA):

```
## <feature> (docs/specs/NNN-<feature>.md)

| RF/CA | RN | UC | Classe / rota | CT | Teste automatizado | Situação |
|---|---|---|---|---|---|---|
| RF-01/CA-1 | RN-01 | UC-02 | <arquivo:símbolo> | CT-<feature>-01 | <arquivo>::<nome do teste> | Coberto |
```

Situação (valores fixos):
- **Coberto:** CT existe, o teste existe em <arquivo>::<nome> (conferido) e
  a classe/rota existe (ou "n/a" para regra puramente de dados).
- **Pendente (T<n>):** o plano prevê task e teste, mas ainda não existem.
- **Sem teste:** RF/CA sem CT, ou CT sem teste previsto nem existente.
- **Sem implementação:** teste ou RN sem classe/rota que a aplique.

Fora da tabela, seções fixas: **Requisitos sem teste**, **Testes sem
requisito** e **Regras sem implementação**, cada uma com a lista ou "nenhum".

## Passos
1. Argumento: uma feature (padrão: todas as specs Aprovadas ou Implementadas).
   Se não houver nenhuma spec Aprovada, PARE (CLAUDE.md §2) e avise.
2. Leia: a spec (RF, CA), docs/requisitos/regras-de-negocio.md,
   docs/requisitos/casos-de-uso/, o plano, docs/testes/casos-de-teste/CT-<feature>.md
   e a matriz atual (se existir). Se faltar uma dessas fontes, a coluna
   correspondente fica "—" e o fato é dito no relatório; não é inventada.
3. Monte uma linha por RF/CA e preencha cada coluna SÓ com o que a fonte diz.
4. **Confira cada ponteiro de verdade**, no disco:
   - classe/rota: o arquivo e o símbolo existem (`grep` ou leitura);
   - teste automatizado: o arquivo existe e contém o nome do teste citado;
   - CT: o ID existe em CT-<feature>.md.
   Ponteiro que não confere NÃO vira "Coberto": a linha vira "Sem teste" ou
   "Sem implementação", com o erro explicado.
5. **Procure o sentido contrário:**
   - testes de produto (a pasta de testes da stack, depois de decidida; o que
     for) que não aparecem na coluna "Teste automatizado" de nenhuma linha são
     "testes sem requisito";
   - toda RN do catálogo sem "Aplicada em" conferido é "regra sem
     implementação";
   - RF/CA sem CT ou sem teste é "requisito sem teste".
   Escopo: testes dos scripts e hooks (`scripts/tests/*.test.sh`) pertencem ao
   harness e ficam fora desta matriz (estão em
   docs/help/ferramentas/testes-dos-hooks.md).
6. MOSTRE o diff da matriz e a lista dos três destaques; espere aprovação antes
   de salvar (CLAUDE.md §6). Grave com Write/Edit e atualize `atualizado`.
7. "Coberto" diz que o teste EXISTE e está apontado, não que PASSA. Para dizer
   que passa, rode `scripts/verify.sh test` e MOSTRE a saída (CLAUDE.md §3 e
   §5). Sem stack detectada, diga isso: nenhum teste de produto roda.
8. Atualize docs/requisitos/README.md se a tabela mudar. Termine com 3–5 linhas
   explicando o que mudou e por quê (CLAUDE.md §7), e aponte as lacunas para a
   skill dona: RN sem implementação → plano; sem CT → `/casos-de-teste`; UC
   sem exceção → `/casos-de-uso`.

## Proibido
- Marcar "Coberto" sem apontar o teste real (arquivo e nome conferidos).
- Preencher classe, rota, CT ou teste "por dedução" ou por convenção de nome.
- Dizer que um teste passa sem mostrar a saída do `verify.sh test`.
- Esconder lacuna: as três seções de destaque existem sempre, mesmo vazias.
- Editar spec, RN, UC, CT, plano ou código; só aponta.
- Apagar linha de RF/CA que sumiu da spec sem avisar o dono.
- Salvar sem aprovação do dono.
- Criar ou editar arquivos por Bash (cat, echo, sed, tee, redirecionamento).

## Como verificar
- Toda linha "Coberto" tem teste cujo arquivo existe e contém o nome
  (`grep -rn "<nome do teste>" <arquivo>`).
- Todo RF/CA das specs Aprovadas aparece na matriz.
- As seções "Requisitos sem teste", "Testes sem requisito" e "Regras sem
  implementação" existem.
- `git diff --stat` mostra só rastreabilidade.md e índices.
