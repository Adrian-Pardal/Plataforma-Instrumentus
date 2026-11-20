# ADR 0004: Plataforma multi-método chamada Instrumentus, com o TFA como primeiro método

- **Status:** Aceito
- **Data:** 2026-11-20
- **Substitui:** nenhum

## Contexto
- O projeto nasceu como "Plataforma de Aceitabilidade TFA": uma plataforma para
  um único método (7 construtos do TFA, escala Likert, médias por construto).
- O dono quer que a plataforma comporte vários métodos de pesquisa, não só o TFA.
- O nome, o repositório e o CLAUDE.md ainda dizem "TFA", o que passa a ideia
  de produto de um método só.
- A stack ainda não foi decidida; este ADR não a escolhe.

## Decisão
O produto passa a se chamar **Instrumentus** (pasta e repositório
`Plataforma-Instrumentus`). Ele é uma plataforma que hospeda vários métodos
de pesquisa; o TFA é o primeiro método, não o produto. Cada método novo exige
sua própria spec em `docs/specs`.

## Alternativas
1. **Manter o nome e o escopo "TFA"**
   - Prós: nenhuma mudança; escopo menor e mais simples.
   - Contras: o nome engana quando surgir o segundo método; renomear depois
     custa mais (mais links, mais código).
   - **Descartada** porque o dono já planeja outros métodos.
2. **Plataforma única, multi-método, com o TFA como primeiro método** (escolhida)
   - Prós: um só lugar para pesquisadores e respostas; o que for comum
     (publicar link, coletar respostas, ver resultados) pode ser reaproveitado.
   - Contras: exige cuidado para o modelo de dados não ficar preso ao TFA;
     risco de abstrair cedo demais, antes de existir um segundo método.
3. **Um repositório por método**
   - Prós: cada método evolui isolado; menos acoplamento.
   - Contras: duplica CI, hooks, docs e código comum; mais manutenção para
     uma pessoa só.
   - **Descartada** pelo custo de manutenção.

## Consequências
**Positivas:** o nome e a documentação refletem o objetivo real do produto.

**Negativas:** a abstração "método de pesquisa" é uma decisão em aberto;
se for feita antes de existir um segundo método, pode sair errada.

**Daqui para frente:**
- Decidir a stack em ADR próprio (`CLAUDE.md` ainda diz "a definir").
- A spec do TFA deve tratar "método" como conceito, mas sem generalizar além
  do necessário (começar pelo TFA, extrair o que for comum quando surgir o
  segundo método).
- Perguntas em aberto para o dono: quais outros métodos virão? Cada método
  terá escala e relatório próprios, ou compartilham o mesmo formato?
- Aceitar este ADR só com o seu ok; depois disso ele não se edita.
