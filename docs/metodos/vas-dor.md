---
titulo: Ficha do método VAS de dor
proposito: Dizer como a VAS aplicada à dor funciona, quais faixas usa e como a plataforma calcula a variação
status: rascunho
atualizado: 2026-11-22
mantido-por: manual
relacionados: [README.md, vas.md]
---

# Escala visual analógica (VAS) de dor

Nível 1 · Saúde e ciência da implementação · Etapa 2 · Status: não implementado.
Texto da fonte "Métodos de pesquisa da plataforma"; as referências foram conferidas no Crossref.

## Como funciona
É a VAS genérica ([vas.md](vas.md)) aplicada à intensidade da dor. A linha de 100 mm vai de "sem dor" (0) a "pior
dor imaginável" (100), e o paciente marca onde está a sua dor. Na plataforma, é um *slider* de 0 a 100 sem números
visíveis. Segundo o documento, uma referência comum para interpretar é: 0–4 mm sem dor, 5–44 mm dor leve, 45–74 mm
dor moderada e 75–100 mm dor intensa (atribuída a Hawker et al., 2011).

## Regras para o código
- Valem as regras da VAS (valor de 0 a 100, sem posição inicial, vazio se não tocar).
- Variação absoluta = antes − depois; variação relativa = (antes − depois) / antes × 100.
- Faixas com limites sem ambiguidade (por exemplo, "leve" = 5 ≤ valor < 45), para que valores com casa decimal, como
  44,5, caiam sempre na mesma faixa.
- Dado de saúde: sensível na LGPD; aprovação no CEP quando a pesquisa envolver pessoas (ver [README.md](README.md)).

## Teste de referência
Um paciente marcou 72 antes do tratamento e 38 depois:
- Antes: 72, faixa moderada (45–74)
- Depois: 38, faixa leve (5–44)
- Redução absoluta = 72 − 38 = 34 pontos
- Redução relativa = 34 / 72 × 100 = 47,2%

## Fundamentação
Huskisson (1974) popularizou a VAS para medir dor, argumentando que uma linha contínua capta diferenças que escalas
verbais ("leve", "moderada", "forte") perdem. Hawker et al. (2011) revisaram as medidas de dor em adultos: a VAS é
confiável, válida e sensível a mudanças, mas é unidimensional (só mede intensidade) e pode ser difícil para idosos
ou pessoas com dificuldade motora. A escala numérica de 0 a 10 é a alternativa mais usada nesses casos.

## Condição de uso
Uso livre, citando a fonte (segundo o documento de métodos; não verificado na fonte).

## Versão em português
Não encontrada na busca de 2026-11-22 (Crossref). Não equivale a "não existe"; conferir no PubMed e SciELO antes de
publicar.

## Perguntas em aberto
- De onde vêm as faixas 0–4, 5–44, 45–74 e 75–100? O documento as atribui a Hawker et al. (2011), mas isso não foi
  conferido no artigo.
- Como ficam os limites das faixas para valores com decimais (por exemplo, 74,5)? As faixas do documento têm um
  intervalo entre 74 e 75.
- A plataforma mostra a faixa ou só o número? Sem consenso do documento sobre rotular.
- A plataforma oferece a escala numérica de 0 a 10 como alternativa?

## Referências
- HUSKISSON, E. C. Measurement of pain. *The Lancet*, v. 304, n. 7889, p. 1127-1131, 1974.
  DOI: 10.1016/S0140-6736(74)90884-8.
- HAWKER, G. A. et al. Measures of adult pain: Visual Analog Scale for Pain (VAS Pain), Numeric Rating Scale for
  Pain (NRS Pain), McGill Pain Questionnaire (MPQ), Short-Form McGill Pain Questionnaire (SF-MPQ), Chronic Pain
  Grade Scale (CPGS), Short Form-36 Bodily Pain Scale (SF-36 BPS), and Measure of Intermittent and Constant
  Osteoarthritis Pain (ICOAP). *Arthritis Care & Research*, v. 63, supl. 11, p. S240-S252, 2011.
  DOI: 10.1002/acr.20543.
