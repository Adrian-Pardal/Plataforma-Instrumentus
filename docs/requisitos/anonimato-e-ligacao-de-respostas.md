---
titulo: Decisão pendente — anonimato e ligação de respostas
proposito: Registrar a pergunta de negócio sobre o que "resposta anônima" significa quando um método precisa ligar respostas da mesma pessoa
status: rascunho
atualizado: 2026-11-22
mantido-por: manual
relacionados: [README.md, ../metodos/pre-e-pos-teste.md, ../metodos/avaliacao-360.md, ../metodos/ivc.md, ../metodos/phq-9.md, ../metodos/delphi.md]
---

# Decisão pendente: anonimato e ligação de respostas

**Situação:** em aberto. Para ser decidida como regra de negócio (RN, a numerar pela `/regras-negocio`) antes da spec
do primeiro método que liga respostas.

## A pergunta
O projeto parte de "respostas anônimas" (CLAUDE.md, seção 1). Alguns métodos só funcionam se as respostas da mesma
pessoa puderem ser ligadas entre si. **O que a plataforma entende por "anônimo", e como esses métodos convivem com isso?**

## Nenhum método exige o nome da pessoa
O que alguns exigem é **ligar respostas** por um código, sem nome:

| Método | O que precisa ser ligado | Fonte |
|---|---|---|
| Pré e pós-teste | A resposta de antes e a de depois da mesma pessoa, por código anônimo | [pre-e-pos-teste.md](../metodos/pre-e-pos-teste.md) |
| Delphi | A resposta de cada especialista entre as rodadas; quem não respondeu é registrado | [delphi.md](../metodos/delphi.md) |
| Avaliação 360° | O grupo de cada avaliador e a pessoa avaliada (identificada por natureza); o gestor é identificável pelo papel | [avaliacao-360.md](../metodos/avaliacao-360.md) |
| IVC | O papel de "juiz"; o documento não diz se o juiz é identificado | [ivc.md](../metodos/ivc.md) |
| SEQ | A nota ligada ao tempo e ao sucesso da tarefa (dentro da sessão) | [seq.md](../metodos/seq.md) |

O PHQ-9 vai no sentido contrário: não exige identificar, mas o alerta do item 9 só ajudaria alguém se houvesse como
contatar a pessoa ([phq-9.md](../metodos/phq-9.md)).

## Por que não é só um detalhe técnico
Pelo entendimento da IA (não é parecer jurídico), dado ligado por código é, em geral, "pseudonimizado" na LGPD, e
continua sendo dado pessoal se alguém puder reidentificar. "Anônimo para o pesquisador" e "anônimo de verdade" são
coisas diferentes. A confirmação cabe à Fase 9 (segurança e privacidade).

## Opções levantadas (sem recomendação ainda)
1. **Anônimo estrito:** nenhuma ligação entre respostas.
   - Prós: menos risco e menos texto de consentimento.
   - Contras: pré e pós-teste, Delphi e 360° ficam inviáveis, ou degradados (grupos independentes).
2. **Pseudonimizado por código:** a plataforma gera um código, sem nome; só o código liga as respostas.
   - Prós: viabiliza pré e pós-teste, Delphi e 360° sem coletar nome.
   - Contras: não é anonimato pleno; quem perde o código perde a ligação; exige aviso claro ao respondente.
3. **Identificação com consentimento, só nos métodos que precisam:** e-mail ou nome, por método.
   - Prós: facilita convites e lembretes (rodadas do Delphi, avaliadores da 360°).
   - Contras: mais dado pessoal, mais risco, e quebra a premissa "anônimo".

## Perguntas derivadas
- Anônimo para quem: para o pesquisador, para a plataforma, ou para ambos?
- Quem guarda o código e por quanto tempo? O que acontece quando o respondente pede para apagar os dados?
- Como o respondente é informado de que as respostas são ligadas?
- Na 360°: como proteger o grupo oculto (ver pergunta em aberto em [avaliacao-360.md](../metodos/avaliacao-360.md))?
- No PHQ-9: o que o pesquisador pode fazer com o alerta do item 9 numa pesquisa anônima?

## Quando decidir
Antes de começar a spec do primeiro método que liga respostas (Etapa 4 do guia) e antes da Fase 9. Os métodos da
Etapa 1 (MVP) não ligam respostas e não dependem desta decisão.

## Onde a decisão vai
Uma RN no catálogo de regras de negócio ([README.md](README.md)); se mudar o modelo de dados, também um ADR.
