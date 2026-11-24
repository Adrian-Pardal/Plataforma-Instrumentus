---
titulo: Regras de negócio
proposito: Catalogar cada regra RN-xx do produto uma só vez, com motivo, exemplos, onde é aplicada e que testes a cobrem
status: rascunho
atualizado: 2026-11-24
mantido-por: /regras-negocio
relacionados: [../specs/000-visao-mvp.md, ../produto/glossario.md, README.md]
---

# Regras de negócio

Regras que valem em qualquer tela ou método. Regras de um método só ficam na ficha dele ([docs/metodos](../metodos/README.md)).
Spec, caso de uso e teste citam "RN-xx" em vez de repetir o texto.

### RN-01 — Resposta anônima
- **Enunciado:** a resposta de um respondente não guarda nenhum dado que o identifique, e nenhuma exportação o revela.
- **Motivo:** a plataforma promete respostas anônimas (CLAUDE.md §1); sem isso o respondente pode não responder com sinceridade.
- **Valem:** uma resposta guardada só com os valores dos itens e a seção a que pertencem.
- **Não valem:** uma resposta guardada junto com o nome ou o e-mail do respondente.
- **Exceções:** nenhuma decidida. Métodos que ligam respostas da mesma pessoa (pré e pós, Delphi) estão fora do MVP; a decisão está em [anonimato-e-ligacao-de-respostas.md](anonimato-e-ligacao-de-respostas.md).
- **Origem:** [spec 000](../specs/000-visao-mvp.md), RF-03 CA-1 e RF-07 CA-3; CLAUDE.md §1
- **Aplicada em:** a preencher na implementação
- **Testes:** a preencher
- **Status:** Vigente

### RN-02 — Acesso só às próprias pesquisas
- **Enunciado:** um pesquisador só vê, altera e exporta as pesquisas que ele criou.
- **Motivo:** cada pesquisador é dono das suas pesquisas e dos dados delas.
- **Valem:** o pesquisador A abre a sua própria lista de pesquisas.
- **Não valem:** o pesquisador A abre, altera ou exporta uma pesquisa do pesquisador B.
- **Exceções:** nenhuma no MVP (várias pessoas na mesma pesquisa está fora de escopo).
- **Origem:** [spec 000](../specs/000-visao-mvp.md), RF-01 CA-3 e RF-07 CA-2; resposta do dono (pergunta 6)
- **Aplicada em:** a preencher na implementação
- **Testes:** a preencher
- **Status:** Vigente

### RN-03 — Seção calcula só pelo seu método
- **Enunciado:** o resultado de uma seção é calculado só com os itens dessa seção e pelo método dela; resultados de seções diferentes não se somam nem se misturam.
- **Motivo:** cada método tem cálculo e validade próprios; misturar escores de métodos diferentes não tem significado.
- **Valem:** uma pesquisa com uma seção TFA e uma seção Likert mostra um resultado para cada.
- **Não valem:** um escore único que soma itens da seção TFA e da seção SUS.
- **Exceções:** nenhuma decidida.
- **Origem:** [spec 000](../specs/000-visao-mvp.md), RF-05 CA-1; resposta do dono (pergunta 2)
- **Aplicada em:** a preencher na implementação
- **Testes:** a preencher
- **Status:** Vigente

### RN-04 — Adaptação limitada do modelo
- **Enunciado:** no modo limitado, o pesquisador só altera os campos que o método do modelo permite; itens, escala e cálculo não mudam.
- **Motivo:** preservar a validade do instrumento e garantir que o cálculo confira com o teste de referência da ficha.
- **Valem:** trocar o nome da intervenção no enunciado de um item do TFA, ou o título da seção.
- **Não valem:** trocar a escala de 1 a 5 do TFA, remover um item ou mudar o cálculo.
- **Exceções:** nenhuma no MVP. Os modos travado e editável estão fora de escopo.
- **Origem:** [spec 000](../specs/000-visao-mvp.md), RF-02 CA-2; resposta do dono (pergunta 4)
- **Aplicada em:** a preencher na implementação
- **Testes:** a preencher
- **Status:** Vigente

### RN-05 — Limite leve de respostas por navegador
- **Enunciado:** um navegador que já enviou resposta a uma pesquisa não gera nova resposta contada nessa pesquisa; o respondente é avisado.
- **Motivo:** reduzir o envio repetido, por erro ou de propósito, sem identificar ninguém.
- **Valem:** o mesmo navegador abre o link de novo e vê o aviso, sem nova resposta contada.
- **Não valem:** o mesmo navegador envia a mesma pesquisa duas vezes e as duas contam.
- **Exceções:** limitação conhecida e aceita: outro navegador ou aba anônima contorna a regra. A proteção não é à prova de fraude.
- **Origem:** [spec 000](../specs/000-visao-mvp.md), RF-03 CA-3; resposta do dono (pergunta 8)
- **Aplicada em:** a preencher na implementação
- **Testes:** a preencher
- **Status:** Vigente

### RN-06 — Só pesquisa publicada recebe respostas
- **Enunciado:** só uma pesquisa publicada e não encerrada aceita respostas.
- **Motivo:** o pesquisador controla quando a coleta começa e termina.
- **Valem:** enviar uma resposta a uma pesquisa publicada.
- **Não valem:** enviar resposta a uma pesquisa ainda não publicada ou já encerrada.
- **Exceções:** nenhuma decidida.
- **Origem:** [spec 000](../specs/000-visao-mvp.md), RF-03 CA-2
- **Aplicada em:** a preencher na implementação
- **Testes:** a preencher
- **Status:** Vigente

### RN-07 — Pesquisa sem seção não se publica
- **Enunciado:** uma pesquisa precisa ter pelo menos uma seção para ser publicada.
- **Motivo:** uma pesquisa sem seção não tem nada a responder nem a calcular.
- **Valem:** publicar uma pesquisa com uma ou mais seções.
- **Não valem:** publicar uma pesquisa com zero seções.
- **Exceções:** nenhuma decidida.
- **Origem:** [spec 000](../specs/000-visao-mvp.md), RF-02 CA-3
- **Aplicada em:** a preencher na implementação
- **Testes:** a preencher
- **Status:** Vigente

## Perguntas em aberto
- [ ] **RN-01:** o que conta como "dado que identifica"? Nome e e-mail, claro. E o endereço de rede (IP)?
- [ ] **RN-05:** o limite leve pode usar algum dado do respondente (como o IP) ou só um marcador guardado no próprio navegador? Isso afeta a RN-01.
- [ ] **RN-04:** para cada método, quais campos são adaptáveis? (já está nas perguntas em aberto da spec 000; decidir por método)
- [ ] **Termos:** as RN-01 e RN-05 usam "resposta" para o envio completo. A decisão sobre "resposta × envio" está nas perguntas do [glossário](../produto/glossario.md).
