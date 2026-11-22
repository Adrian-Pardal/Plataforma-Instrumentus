---
titulo: Segurança
proposito: Indexar as ameaças, a proteção de dados pessoais e as regras de segurança do projeto
status: vigente
atualizado: 2026-11-22
mantido-por: /modelagem-ameacas
relacionados: [../README.md, agente.md]
---

# Segurança

**Esta pasta responde:** quais ameaças e dados pessoais existem e como o projeto se protege?

| Arquivo | Do que trata | Status |
|---|---|---|
| [agente.md](agente.md) | riscos do agente de IA, regras de confirmação e servidores MCP aprovados | vigente |
| modelo-de-ameacas.md | STRIDE por componente | a criar |
| lgpd.md | inventário de dados pessoais | a criar |
| checklist-owasp.md | OWASP Top 10 no projeto | a criar |

**Para o `lgpd.md`:** a telemetria do estudo de caso envia o e-mail da conta ao Collector local; ele é removido por um
processador antes de gravar (ver [help/ferramentas/telemetria.md](../help/ferramentas/telemetria.md)) e a remoção ainda
precisa ser conferida numa sessão real.

**Mantida por:** `/modelagem-ameacas`, `/lgpd` e `/revisao-seguranca` (a criar); `agente.md` é manual.
