# ADR 0007: Registro de dados para pesquisa

- **Status:** Aceito
- **Data:** 2026-11-22
- **Substitui:** nenhum

## Contexto
O desenvolvimento da plataforma é feito quase todo com IA, e o dono quer
usá-lo como estudo de caso para um artigo (docs/pesquisa/protocolo.md).
O protocolo tem 5 questões: proporção do trabalho da IA, erros e qual peça do
harness os pegou, qualidade por fase, custo em tokens e tempo, e aprendizado do operador.
Fatos que limitam a coleta:
- O Git registra commits no nome do dono: não separa o que foi escrito pela IA do que foi escrito por ele.
- O Git também não guarda tokens, duração das sessões nem as intervenções do operador.
- As transcrições do Claude Code têm `usage` e `timestamp`, mas ficam só na máquina do operador e podem ser apagadas.
- A coleta sistemática começa em 2026-11-22; antes disso só existe o que o Git e docs/ já guardam.

## Decisão
Registraremos os dados da pesquisa por três vias combinadas: Git e CI como
fonte automática; um arquivo por sessão em `docs/pesquisa/sessoes/` com
tempo, tokens e as intervenções do operador classificadas pela taxonomia do
protocolo; e um registro de autoria (humano ou IA) nos commits. Dados
derivados ficam em `docs/pesquisa/dados/`. Transcrições brutas, segredos e
dados pessoais não entram no repositório.

## Alternativas
1. **Não registrar** — prós: custo zero, nenhum passo novo no fim da sessão ·
   contras: o artigo vira memória e opinião; as questões sobre proporção do
   trabalho, erros e custo ficam sem dado, e o que não foi anotado não pode
   ser reconstruído depois.
2. **Registrar só pelo Git** — prós: automático, sem esforço do operador,
   cobre linha do tempo, PRs e tasks · contras: não distingue autoria humana e
   de IA, não mostra tokens nem tempo, não mostra intervenções; deixa as
   questões 1, 4 e 5 sem resposta.
3. **Git + registro por sessão (escolhida)** — prós: cobre as 5 questões,
   dados com fonte rastreável, privacidade controlada (só contagens no repositório) ·
   contras: alguns minutos de esforço a cada sessão; a classificação das
   intervenções é manual e pode variar com o tempo.

## Consequências
- O fim de cada sessão ganha um passo: registrar as intervenções e o uso. O
  `/handoff` pode alimentar esse registro, mas a mudança da skill é outra tarefa.
- Será preciso definir como a autoria entra no commit (por exemplo, um
  trailer); isso vai para um plano, não para este ADR.
- O template de erro pode ganhar um campo para "peça que pegou o erro" (pergunta em aberto no protocolo).
- Quem quiser reproduzir os números precisa guardar as transcrições fora do repositório, por conta própria.
- Dados anteriores a 2026-11-22 são só retrospectivos e incompletos; o artigo
  deve dizer isso.
