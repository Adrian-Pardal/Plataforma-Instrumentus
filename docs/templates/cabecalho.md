---
titulo: Cabeçalho padrão dos documentos
proposito: Definir os 6 campos com que todo documento de docs/ começa
status: vigente
atualizado: 2026-11-22
mantido-por: manual
relacionados: [README.md, ../README.md]
---

# Cabeçalho padrão

Todo documento de docs/ começa com este bloco, com os 6 campos preenchidos.

```
---
titulo: <título do documento>
proposito: <uma frase: que dúvida este documento responde>
status: rascunho | vigente | obsoleto
atualizado: AAAA-MM-DD
mantido-por: </skill que mantém, ou "manual">
relacionados: [<caminho relativo ao documento, ou ID: RN-03, ADR-0004>]
---
```

- `rascunho`: ainda não é confiável. `vigente`: confere com o código e as decisões de hoje. `obsoleto`: só pela
  história; aponte quem o substituiu em `relacionados`.
- Spec, plano, ADR e erro têm também o status do SEU ciclo (Aprovada, Aceito, corrigido...), que fica no corpo do
  documento. No erro.md esse campo próprio já existe (`status:`) e o do cabeçalho se chama `status-doc`.
- Atualize `atualizado` sempre que o conteúdo mudar, no mesmo PR.
- Ligue em vez de repetir: cite o ID (RN-03) e aponte o arquivo.
- Documentos anteriores à Fase 3 podem não ter cabeçalho; não precisam ser migrados em massa. Quem mexer neles por
  outro motivo pode aproveitar para colocar.
