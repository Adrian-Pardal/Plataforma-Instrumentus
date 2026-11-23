---
titulo: Ficha do método PHQ-9 (depressão)
proposito: Dizer como o PHQ-9 funciona, como a plataforma calcula, o alerta do item 9 e os cuidados com dado de saúde
status: rascunho
atualizado: 2026-11-22
mantido-por: manual
relacionados: [README.md, gad-7.md, ../requisitos/anonimato-e-ligacao-de-respostas.md]
---

# PHQ-9 (depressão)

Nível 2 · Saúde e ciência da implementação · Etapa 3 · Status: não implementado.
Texto da fonte "Métodos de pesquisa da plataforma"; o site dos questionários foi lido em 2026-11-22 e as referências
foram conferidas no Crossref. Esta ficha não reproduz os itens.

**Cuidado:** coleta dado de saúde (sensível na LGPD) e traz alerta de risco. Pelo guia, só entra depois da Fase 9
(segurança e privacidade).

## Como funciona
São 9 itens sobre as últimas duas semanas, cada um de 0 (nenhuma vez) a 3 (quase todos os dias). O escore total vai de
0 a 27:

| Escore | Gravidade dos sintomas |
|---|---|
| 0–4 | Mínima |
| 5–9 | Leve |
| 10–14 | Moderada |
| 15–19 | Moderadamente grave |
| 20–27 | Grave |

É um instrumento de **rastreio**, não de diagnóstico. O item 9 pergunta sobre pensamentos de morte ou de se ferir.

## Regras para o código
- Se o item 9 tiver qualquer valor acima de 0, avisar o pesquisador e mostrar ao respondente uma mensagem de apoio
  com contatos de ajuda (segundo o documento, o CVV, telefone 188). O alerta funciona em tempo real, no momento do
  envio, e não só no relatório, e independe do escore total.
- O gatilho do item 9 é fixo: o pesquisador não pode desligá-lo nem mudá-lo.
- O ponto de corte configurável pelo pesquisador é só o do rastreio pelo escore total (por exemplo, 9 ou 10); ele não
  altera o alerta do item 9.
- Se faltar algum item, o escore total fica vazio.
- Guardar a resposta bruta.

## Teste de referência
Respostas aos 9 itens (0 a 3): 1, 2, 1, 0, 1, 2, 1, 0, 1.
- Escore = 9, faixa "leve" (5–9).
- Pelo corte ≥ 9 de Santos et al. (2013), o rastreio é positivo; pelo corte ≥ 10, mais usado internacionalmente, é
  negativo.
- Item 9 = 1 (maior que 0): dispara o alerta, independentemente do escore total.

## Fundamentação
Kroenke, Spitzer e Williams (2001) criaram o PHQ-9 a partir dos nove critérios de episódio depressivo maior do
DSM-IV, como parte do PRIME-MD, e mostraram, segundo o documento, boa validade frente a entrevistas clínicas. No
Brasil, Santos et al. (2013) testaram o instrumento na população geral de Pelotas (RS): o ponto de corte ≥ 9 teve
sensibilidade de 77,5% e especificidade de 86,7% (valores do documento, não conferidos no artigo).

## Condição de uso
Segundo o site dos questionários, o conteúdo é "free for download and use as stated within the PHQ Screeners site" e
está isento das restrições gerais de copyright da Pfizer. O site **não menciona tradução**, não nomeia o titular dos
direitos e não pede citação. O documento afirma que não é preciso pedir permissão para reproduzir ou traduzir; isso a
fonte lida não confirma.

## Versão em português
Santos et al. (2013) avaliaram a sensibilidade e a especificidade do PHQ-9 em adultos da população geral no Brasil.
O site dos questionários não cita versão em português. Não se sabe, pelas fontes lidas, qual redação dos itens usar.

## Perguntas em aberto
- A tradução e a reprodução dos itens são permitidas? O site não fala de tradução; ler os Termos de Uso da Pfizer e
  confirmar o titular.
- Como conciliar respostas anônimas com o alerta do item 9? A plataforma não tem como contatar a pessoa; o que o
  pesquisador faz ao receber o alerta é decisão de produto e de ética.
- O contato de apoio (CVV 188) continua vigente e é o adequado para o público da pesquisa? Conferir antes de usar.
- Quais são os requisitos de aprovação no CEP e da LGPD para dado de saúde? Cobertos na Fase 9, não nesta ficha.
- O uso do PHQ-9 na Pesquisa Nacional de Saúde (citado no documento) não foi conferido.
- Qual redação em português dos itens usar, e com que validação?

## Referências
- KROENKE, K.; SPITZER, R. L.; WILLIAMS, J. B. W. The PHQ-9: validity of a brief depression severity measure.
  *Journal of General Internal Medicine*, v. 16, n. 9, p. 606-613, 2001.
  DOI: 10.1046/j.1525-1497.2001.016009606.x.
- SANTOS, I. S. et al. Sensibilidade e especificidade do Patient Health Questionnaire-9 (PHQ-9) entre adultos da
  população geral. *Cadernos de Saúde Pública*, v. 29, n. 8, p. 1533-1543, 2013. DOI: 10.1590/S0102-311X2013001200006.
- PHQ SCREENERS. *Terms of use*. Disponível em: https://www.phqscreeners.com/terms. Acesso em: 22 nov. 2026.
