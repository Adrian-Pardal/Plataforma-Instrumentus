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
- **Definição:** o conceito que um instrumento mede; no TFA, cada uma das 7 faces da aceitabilidade.
- **Exemplo:** "Carga" é um construto do TFA.
- **Sinônimos proibidos:** dimensão, fator, categoria
- **Nome no código:** `Construct` (a confirmar)
- **Origem:** [ficha do TFA](../metodos/tfa.md); CLAUDE.md §1

### Escala
- **Definição:** o conjunto ordenado de opções em que o respondente indica a sua resposta a um item, cada opção com um valor numérico.
- **Exemplo:** a escala de 5 pontos do TFA, de "discordo totalmente" a "concordo totalmente".
- **Sinônimos proibidos:** nenhum conhecido
- **Nome no código:** `Scale` (a confirmar)
- **Origem:** [ficha do Likert](../metodos/likert.md); [ficha do TFA](../metodos/tfa.md)

### Escore
- **Definição:** o número calculado, pelo método, a partir das respostas a um grupo de itens.
- **Exemplo:** a média de "Atitude afetiva" no TFA (4,2 no teste de referência da ficha).
- **Sinônimos proibidos:** pontuação
- **Nome no código:** `Score` (a confirmar)
- **Origem:** [ficha do Likert](../metodos/likert.md); [ficha do TFA](../metodos/tfa.md); [ficha do alfa de Cronbach](../metodos/alfa-de-cronbach.md); resposta do dono em 2026-11-24

### Instrumento
- **Definição:** o questionário concreto de um método, com os seus itens e a sua escala, numa versão; um método pode ter mais de um instrumento.
- **Exemplo:** o questionário genérico do TFA (2022); o UEQ e o UEQ-S.
- **Sinônimos proibidos:** questionário (a confirmar: as fichas usam as duas palavras)
- **Nome no código:** `Instrument` (a confirmar)
- **Origem:** tabela de [docs/metodos](../metodos/README.md), coluna "Versão do instrumento"; resposta do dono em 2026-11-24

### Item
- **Definição:** cada afirmação ou pergunta de um instrumento que o respondente responde, com uma resposta dentro da escala.
- **Exemplo:** cada um dos 8 itens do questionário do TFA.
- **Sinônimos proibidos:** pergunta (exceto no nome do método "Perguntas abertas")
- **Nome no código:** `Item` (a confirmar)
- **Origem:** [ficha do Likert](../metodos/likert.md); [ficha do TFA](../metodos/tfa.md); resposta do dono em 2026-11-24

### Item invertido
- **Definição:** item cuja pontuação é invertida antes do cálculo, porque nota alta nele significa o contrário do que o resultado mede; a resposta bruta é sempre guardada e a inversão só acontece na análise.
- **Exemplo:** no TFA, "Carga" e "Custo de oportunidade": o valor passa a ser 6 − resposta.
- **Sinônimos proibidos:** nenhum conhecido
- **Nome no código:** `ReversedItem` (a confirmar)
- **Origem:** [ficha do Likert](../metodos/likert.md); [ficha do TFA](../metodos/tfa.md)

### Juiz
- **Definição:** quem dá a nota de cada item, com sugestões em texto livre, no método IVC. Fora do MVP (etapa 4).
- **Exemplo:** um especialista que avalia, item a item, um instrumento em construção.
- **Sinônimos proibidos:** nenhum conhecido. O Delphi usa "especialista"; se é o mesmo papel, é pergunta em aberto.
- **Nome no código:** `Judge` (a confirmar)
- **Origem:** [ficha do IVC](../metodos/ivc.md)

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

### Resultado
- **Definição:** tudo que uma seção mostra ao pesquisador a partir das respostas: os escores e o que o método define (como o % favorável), ou o aviso "sem respostas".
- **Exemplo:** no TFA, a média e o % favorável de cada construto.
- **Sinônimos proibidos:** nenhum conhecido
- **Nome no código:** `SectionResult` (a confirmar)
- **Origem:** [spec 000](../specs/000-visao-mvp.md), RF-04; RN-03; [ficha do TFA](../metodos/tfa.md); resposta do dono em 2026-11-24

### Rodada
- **Definição:** cada passada de todo o painel pelo mesmo questionário no método Delphi; costumam ser 2 a 4. Fora do MVP (etapa 5).
- **Exemplo:** a rodada 1 levanta ou avalia itens; as seguintes reavaliam os que não tiveram consenso.
- **Sinônimos proibidos:** nenhum conhecido
- **Nome no código:** `Round` (a confirmar)
- **Origem:** [ficha do Delphi](../metodos/delphi.md)

### Seção
- **Definição:** parte de uma pesquisa que usa um modelo de um método e calcula o seu próprio resultado.
- **Exemplo:** a seção TFA de uma pesquisa que também tem uma seção SUS.
- **Sinônimos proibidos:** bloco, bloco de pergunta, módulo
- **Nome no código:** `Section` (a confirmar)
- **Origem:** [spec 000](../specs/000-visao-mvp.md), resposta do dono (pergunta 2) e RF-05

### Subescala
- **Definição:** o grupo de itens de um instrumento que mede um mesmo construto e tem o seu próprio escore.
- **Exemplo:** no TFA, cada construto tem uma subescala de um único item.
- **Sinônimos proibidos:** nenhum conhecido
- **Nome no código:** `Subscale` (a confirmar)
- **Origem:** [ficha do alfa de Cronbach](../metodos/alfa-de-cronbach.md); [ficha do TFA](../metodos/tfa.md); resposta do dono em 2026-11-24

### Versão do instrumento
- **Definição:** cada variante publicada de um instrumento, que muda os itens ou o momento de aplicação; a versão usada fica guardada em cada resposta.
- **Exemplo:** a versão prospectiva ou a retrospectiva do TFA; o CES 1.0 ou 2.0.
- **Sinônimos proibidos:** nenhum conhecido
- **Nome no código:** `InstrumentVersion` (a confirmar)
- **Origem:** [ficha do TFA](../metodos/tfa.md) ("guardar a versão do instrumento em cada resposta"); [docs/metodos](../metodos/README.md)

## Perguntas em aberto
Conflitos de nome que o dono ainda não decidiu. Cada um vira termo (ou sinônimo proibido) quando for respondido.

- [x] 1. **Método × instrumento:** decidido em 2026-11-24: são coisas diferentes (ver "Método" e "Instrumento").
- [ ] 2. **Resposta × envio:** um termo para o valor de um item e outro para o conjunto enviado?
- [ ] 3. **Respondente × participante:** proibir "participante"? (17 usos, inclusive na ficha do TFA). Os papéis das fichas 360° e Delphi (avaliador, especialista) seriam termos à parte.
- [x] 4. **Item × pergunta:** decidido em 2026-11-24: "item" é o termo oficial (ver "Item").
- [x] 5. **Escore × resultado:** decidido em 2026-11-24: são dois termos (ver "Escore" e "Resultado").
- [ ] 6. **Fluxo de coleta:** adiado em 2026-11-24. O termo não aparece nos docs nem no MVP; definir quando uma spec precisar.
