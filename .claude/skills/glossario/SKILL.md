---
name: glossario
description: Mantém docs/produto/glossario.md, com cada termo do domínio (definição única, exemplo, sinônimos proibidos, nome usado no código, ex.: construto = Construct). Com o argumento "conferir", procura no código e nos docs termos fora do glossário e sinônimos proibidos. Use ao surgir um conceito novo numa spec, regra ou caso de uso (a entrevista-spec a aciona), ao aprovar uma spec, ou com "conferir" antes da revisão. Não use para definir termo sem a aprovação do dono, para renomear código (isso é uma task do plano) nem para documentar tecnologia.
argument-hint: "[conferir | <termo>]"
---

# Glossário

## Conceito (para você, dono do projeto)
Na linguagem ubíqua (DDD, *Domain-Driven Design*), o mesmo vocabulário vale na
conversa, nas specs, nos testes e no código. Se você diz "construto", a spec diz
"dimensão" e o código tem `Category`, ninguém (nem a IA) sabe se são a mesma
coisa. O glossário é a lista oficial: um termo, uma definição, um nome no
código. Termo que não está nele não deve aparecer no código.

## Formato de cada termo
Em docs/produto/glossario.md, ordem alfabética, uma seção por termo:

```
### Construto
- **Definição:** <uma frase; sem usar outro termo ainda não definido>
- **Exemplo:** <caso concreto do domínio>
- **Sinônimos proibidos:** dimensão, categoria, fator
- **Nome no código:** `Construct`
- **Origem:** <spec, RN ou ADR onde nasceu>
```

## Passos
1. Leia docs/produto/glossario.md (se não existir, o primeiro uso o cria com o
   cabeçalho de docs/templates/cabecalho.md), a spec Aprovada e
   docs/requisitos/regras-de-negocio.md.
2. **Sem argumento ou com `<termo>`:** identifique os termos novos ou
   alterados e, para cada um, proponha o bloco acima.
   - Definição só com base em spec, RN, ADR ou na sua resposta. Se não houver
     base, vira PERGUNTA ao dono; nunca invente definição (CLAUDE.md §5).
   - Antes de propor, procure se o conceito já existe com outro nome (mesmo
     significado, palavra diferente). Se existir, não crie termo novo: o outro
     nome entra em "Sinônimos proibidos".
   - Nome no código em inglês, no singular, em PascalCase para tipo (`Construct`)
     e o mesmo radical para variáveis e colunas. Se a stack ainda não foi
     decidida, marque "a confirmar" e registre.
3. MOSTRE ao dono os blocos propostos (diff do glossário) e espere aprovação
   antes de salvar (CLAUDE.md §6). Só então grave com Write/Edit, atualizando
   `atualizado` no cabeçalho.
4. **Com `conferir`** (só lê, não edita nada):
   a. Sinônimos proibidos: procure cada um (com variações de plural e
      maiúscula) em docs/, no código e nos testes. Cada ocorrência é achado.
   b. Termos fora do glossário, procurando em:
      - nomes de tipos, classes, tabelas, colunas, rotas e enums no código;
      - títulos (`#`) e termos em **negrito** das specs, RN e casos de uso;
      - rótulos de tela visíveis ao usuário.
      Descarte vocabulário técnico genérico (Controller, Repository, Service,
      Test) e nomes de bibliotecas. O que sobrar e não estiver no glossário
      é candidato.
   c. Termos do glossário sem uso em nenhum lugar (possível sobra).
   d. Entregue a tabela: # | Tipo (sinônimo proibido / fora do glossário / sem
      uso) | Termo | Onde (arquivo:linha) | Sugestão. A busca é uma
      heurística: diga isso e deixe a decisão com o dono.
5. Para cada achado, a sugestão é uma destas: (i) incluir no glossário
   (volta ao passo 2); (ii) trocar pelo termo oficial, o que é uma task do
   plano e não é feita aqui; (iii) falso positivo. Se o glossário mudar,
   lembre o dono de atualizar docs/produto/README.md se for o caso.
6. Termine com 3–5 linhas explicando o que mudou e por quê (CLAUDE.md §7).

## Proibido
- Dois nomes para o mesmo conceito, no glossário, nos docs ou no código.
- Um termo com duas definições ou duas definições na mesma entrada.
- Inventar definição, exemplo ou origem sem base; vira pergunta ao dono.
- Salvar o glossário sem aprovação do dono.
- Renomear código ou editar spec, RN, caso de uso ou testes: o `conferir`
  só aponta.
- Alterar termo já usado no código sem avisar que isso gera uma task de
  renomeação.
- Criar ou editar arquivos por Bash (cat, echo, sed, tee, redirecionamento).

## Como verificar
- Cada termo tem os 5 campos e aparece uma só vez (ordem alfabética).
- Nenhum sinônimo proibido é também termo oficial de outra entrada.
- `conferir` listou achados com arquivo:linha ou disse explicitamente
  "nenhum achado", mostrando as buscas feitas.
- `git diff --stat` mostra só docs/produto/glossario.md (e o índice, se
  necessário).
