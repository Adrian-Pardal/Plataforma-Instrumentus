---
titulo: Glossário
proposito: Dizer o nome oficial de cada conceito do domínio, com definição única e o nome usado no código
status: rascunho
atualizado: 2026-11-24
mantido-por: /glossario
relacionados: [../specs/000-visao-mvp.md, ../adr/0004-plataforma-multi-metodo-instrumentus.md, README.md]
---

# Glossário

Um termo, uma definição, um nome no código. Termo fora desta lista não deve aparecer no código nem nos docs do produto.
Nomes no código: a confirmar quando a stack for decidida.

### Construto
- **Definição:** cada uma das 7 faces da aceitabilidade que o método TFA mede.
- **Exemplo:** "Carga" é um construto do TFA.
- **Sinônimos proibidos:** dimensão, fator, categoria
- **Nome no código:** `Construct` (a confirmar)
- **Origem:** [ficha do TFA](../metodos/tfa.md); CLAUDE.md §1

### Link público
- **Definição:** o endereço que o pesquisador compartilha e que o respondente abre para responder; só funciona com a pesquisa publicada.
- **Exemplo:** o link enviado por WhatsApp aos participantes de uma avaliação.
- **Sinônimos proibidos:** URL da pesquisa, endereço de coleta
- **Nome no código:** `PublicLink` (a confirmar)
- **Origem:** [spec 000](../specs/000-visao-mvp.md), RF-03

### Método
- **Definição:** forma estabelecida de medir algo, com itens, escala e cálculo próprios; a plataforma o oferece como modelo.
- **Exemplo:** TFA, SUS, Likert.
- **Sinônimos proibidos:** técnica
- **Nome no código:** `Method` (a confirmar)
- **Origem:** [ADR 0004](../adr/0004-plataforma-multi-metodo-instrumentus.md); [docs/metodos](../metodos/README.md)

### Modelo
- **Definição:** o ponto de partida de uma seção: um método com itens e cálculo já estabelecidos.
- **Exemplo:** o modelo do TFA, em que o pesquisador só adapta o nome da intervenção.
- **Sinônimos proibidos:** nenhum conhecido. "Template" só se usa para modelos de documento, em docs/templates.
- **Nome no código:** `MethodTemplate` (a confirmar)
- **Origem:** [spec 000](../specs/000-visao-mvp.md), resposta do dono (pergunta 2)

### Modo do modelo
- **Definição:** quanto o pesquisador pode alterar o modelo: travado, limitado ou editável. O MVP só tem o limitado.
- **Exemplo:** no modo limitado do TFA, só o nome da intervenção muda.
- **Sinônimos proibidos:** nível de edição, permissão do modelo
- **Nome no código:** `TemplateMode` (a confirmar)
- **Origem:** [spec 000](../specs/000-visao-mvp.md), resposta do dono (pergunta 4)

### Pesquisa
- **Definição:** o que o pesquisador cria e publica: uma ou mais seções, com um link público. Não confundir com "método de pesquisa", que é o Método.
- **Exemplo:** uma pesquisa com uma seção TFA e uma seção Likert.
- **Sinônimos proibidos:** formulário, enquete
- **Nome no código:** `Survey` (a confirmar)
- **Origem:** [spec 000](../specs/000-visao-mvp.md), RF-02 e RF-05

### Pesquisador
- **Definição:** quem tem conta e cria, publica, encerra e analisa pesquisas; vê só as suas.
- **Exemplo:** uma estudante de mestrado que avalia uma intervenção.
- **Sinônimos proibidos:** usuário, autor
- **Nome no código:** `Researcher` (a confirmar)
- **Origem:** [spec 000](../specs/000-visao-mvp.md); [personas](personas.md)

### Respondente
- **Definição:** quem responde uma pesquisa pelo link público, sem se identificar.
- **Exemplo:** alguém que recebe o link e responde pelo celular.
- **Sinônimos proibidos:** participante (ver pergunta 3 em "Perguntas em aberto")
- **Nome no código:** `Respondent` (a confirmar)
- **Origem:** [spec 000](../specs/000-visao-mvp.md); CLAUDE.md §1

### Seção
- **Definição:** parte de uma pesquisa que usa um modelo de um método e calcula o seu próprio resultado.
- **Exemplo:** a seção TFA de uma pesquisa que também tem uma seção SUS.
- **Sinônimos proibidos:** bloco, módulo
- **Nome no código:** `Section` (a confirmar)
- **Origem:** [spec 000](../specs/000-visao-mvp.md), resposta do dono (pergunta 2) e RF-05

## Perguntas em aberto
Conflitos de nome que o dono ainda não decidiu. Cada um vira termo (ou sinônimo proibido) quando for respondido.

- [ ] 1. **Método × instrumento:** são a mesma coisa? Hoje: "método" (174 usos) e "instrumento" (24).
- [ ] 2. **Resposta × envio:** um termo para o valor de um item e outro para o conjunto enviado?
- [ ] 3. **Respondente × participante:** proibir "participante"? (17 usos, inclusive na ficha do TFA). Os papéis das fichas 360° e Delphi (avaliador, especialista) seriam termos à parte.
- [ ] 4. **Item × pergunta:** qual fica? ("perguntas abertas" é nome de método.)
- [ ] 5. **Escore × resultado:** escore = número calculado de um grupo de itens e resultado = tudo que a seção mostra?
