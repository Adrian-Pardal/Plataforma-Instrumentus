---
titulo: Ficha do método GAD-7 (ansiedade)
proposito: Dizer como o GAD-7 funciona, como a plataforma calcula e os cuidados com dado de saúde
status: rascunho
atualizado: 2026-11-22
mantido-por: manual
relacionados: [README.md, phq-9.md]
---

# GAD-7 (ansiedade)

Nível 2 · Saúde e ciência da implementação · Etapa 3 · Status: não implementado.
Texto da fonte "Métodos de pesquisa da plataforma"; o site dos questionários foi lido em 2026-11-22 e as referências
foram conferidas no Crossref. Esta ficha não reproduz os itens.

**Cuidado:** coleta dado de saúde (sensível na LGPD). Pelo guia, só entra depois da Fase 9 (segurança e privacidade).

## Como funciona
São 7 itens sobre as últimas duas semanas, cada um de 0 a 3, com escore total de 0 a 21. Faixas: 0–4 mínima, 5–9
leve, 10–14 moderada e 15–21 grave. O ponto de corte 10 é o mais usado para indicar provável transtorno de ansiedade
generalizada. Também é um instrumento de rastreio, e não de diagnóstico.

## Regras para o código
- Escore total = soma dos 7 itens; se faltar item, o escore fica vazio (como no PHQ-9; confirmar, ver Perguntas em aberto).
- No relatório do grupo: média do escore e porcentagem de pessoas em cada faixa.
- Se o pesquisador aplicar GAD-7 e PHQ-9 juntos, os escores são calculados e exibidos separadamente.
- Guardar a resposta bruta.

## Teste de referência
Respostas aos 7 itens (0 a 3): 2, 2, 1, 2, 1, 2, 1.
- Escore = 11, faixa "moderada" (10–14).
- Pelo corte ≥ 10, o rastreio é positivo.

## Fundamentação
Spitzer et al. (2006) partiram de 13 itens baseados nos critérios do DSM-IV e em escalas existentes, e ficaram com os
7 que melhor identificavam o transtorno em pacientes da atenção primária. No Brasil, Moreno et al. (2016)
confirmaram, segundo o documento, a estrutura de um fator só e a boa confiabilidade da versão em português.

## Condição de uso
Segundo o site dos questionários, o conteúdo é "free for download and use as stated within the PHQ Screeners site" e
está isento das restrições gerais de copyright da Pfizer. O site **não menciona tradução**, não nomeia o titular dos
direitos e não pede citação. O documento diz que o GAD-7, assim como o PHQ-9, é de uso livre; a fonte lida confirma o
uso gratuito, mas não a tradução.

## Versão em português
Há uma versão brasileira estudada por Moreno et al. (2016), cujo título registra "Brazilian-Portuguese version of the
GAD-7". O site dos questionários não cita versão em português.

## Perguntas em aberto
- A tradução e a reprodução dos itens são permitidas? Ler os Termos de Uso da Pfizer e confirmar o titular.
- Qual é a regra para item em branco? O documento só a define para o PHQ-9.
- Como tratar respostas anônimas de saúde mental (LGPD, aprovação no CEP)? Coberto na Fase 9, não nesta ficha.
- A estrutura de um fator e a confiabilidade da versão brasileira vêm do documento; não foram conferidas no artigo.
- Qual redação em português dos itens usar?

## Referências
- SPITZER, R. L. et al. A brief measure for assessing generalized anxiety disorder: the GAD-7. *Archives of Internal
  Medicine*, v. 166, n. 10, p. 1092-1097, 2006. DOI: 10.1001/archinte.166.10.1092.
- MORENO, A. L. et al. Factor structure, reliability, and item parameters of the Brazilian-Portuguese version of the
  GAD-7 questionnaire. *Temas em Psicologia*, v. 24, n. 1, p. 367-376, 2016. DOI: 10.9788/TP2016.1-25.
- PHQ SCREENERS. *Terms of use*. Disponível em: https://www.phqscreeners.com/terms. Acesso em: 22 nov. 2026.
