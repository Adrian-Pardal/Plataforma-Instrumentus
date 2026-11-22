# Telemetria da pesquisa
`docker compose up -d` — sobe um Collector OpenTelemetry local que grava as métricas e os logs do Claude Code em arquivos JSON.

Última verificação: 2026-11-22 · Testado com: Docker 29.7.2, imagem otel/opentelemetry-collector-contrib 0.165.0 (teste com dados sintéticos; sessão real do Claude Code ainda não conferida)

## PARA QUE SERVE
Alimenta as métricas M10 (tokens) e M11 (tempo) do protocolo da pesquisa
(docs/estudo-de-caso/protocolo.md). Sem isso, o custo em tokens e tempo só existe
nas transcrições locais, que podem ser apagadas.

## QUANDO FAZER
Uma vez, para ativar. Depois, sempre que for trabalhar: o Collector precisa
estar rodando (ele reinicia sozinho com o Docker). Se estiver parado, o Claude
Code segue funcionando, mas os dados daquele período se perdem.

## PRÉ-REQUISITOS
- Docker Desktop com a integração WSL ativa (Settings > Resources > WSL integration).
- A pasta `~/pesquisa-instrumentus/telemetria/` (fora do repositório) com
  `docker-compose.yml`, `otel-collector-config.yaml` e a subpasta `dados/`.
- `dados/` criada pelo seu usuário (uid 1000), não pelo Docker: o contêiner
  roda com esse uid e não grava numa pasta de root.

## PASSO A PASSO
1. Conferir que o Docker responde na distro WSL.
   ```bash
   docker --version
   ```
2. Subir o Collector.
   ```bash
   cd ~/pesquisa-instrumentus/telemetria
   docker compose up -d
   ```
3. Ver se ele iniciou: procure "Everything is ready".
   ```bash
   docker compose logs --tail 20 otel-collector
   ```
4. Ativar a telemetria no Claude Code: acrescente ao `env` do
   `~/.claude/settings.json` (nível de usuário, nunca o do projeto).
   NÃO ative OTEL_LOG_USER_PROMPTS nem OTEL_LOG_TOOL_DETAILS.
   ```json
   "env": {
     "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
     "OTEL_METRICS_EXPORTER": "otlp",
     "OTEL_LOGS_EXPORTER": "otlp",
     "OTEL_EXPORTER_OTLP_PROTOCOL": "grpc",
     "OTEL_EXPORTER_OTLP_ENDPOINT": "http://localhost:4317"
   }
   ```
5. Abrir uma sessão NOVA do Claude Code (as variáveis só valem para sessões
   novas), trabalhar um pouco e esperar pelo menos 1 minuto (as métricas são
   enviadas a cada 60 s).

## COMO CONFERIR QUE DEU CERTO
1. Os arquivos aparecem e crescem:
   ```bash
   ls -la ~/pesquisa-instrumentus/telemetria/dados
   ```
   Esperado: `metricas.json` e `logs.json`.
2. O e-mail não está nos dados (troque SEU_EMAIL pelo e-mail da sua conta):
   ```bash
   grep -c "SEU_EMAIL" ~/pesquisa-instrumentus/telemetria/dados/*.json
   ```
   Esperado: `0` em cada arquivo.
3. Teste sem o Claude Code (dados falsos): este comando manda um log
   de teste ao Collector. Espere `HTTP 200` e uma linha nova em `logs.json`.
   ```bash
   curl -s -o /dev/null -w "HTTP %{http_code}\n" -X POST http://localhost:4318/v1/logs \
     -H 'Content-Type: application/json' \
     -d '{"resourceLogs":[{"scopeLogs":[{"logRecords":[{"body":{"stringValue":"teste"}}]}]}]}'
   ```

## SE DER ERRADO
- **`docker` não encontrado:** a integração WSL não está ativa (pré-requisito).
- **Não aparece arquivo:** a sessão do Claude Code é anterior à mudança do `env`, ou
  passou menos de 1 minuto. Abra uma sessão nova e espere.
- **`permission denied` nos logs do Collector:** `dados/` pertence a outro usuário.
  `sudo chown -R 1000:1000 ~/pesquisa-instrumentus/telemetria/dados`.
- **Porta 4317 ou 4318 ocupada:** outro programa as usa; pare-o ou mude o mapeamento no compose.
- **E-mail aparece nos arquivos:** não envie nem commite os arquivos; pare o
  Collector e avise a IA para ajustar os processadores `sem-email`.
- **Parar de coletar:** `docker compose down` e remova o bloco `env` do settings.json.

## VER TAMBÉM
- docs/estudo-de-caso/protocolo.md (métricas M10 e M11)
- docs/adr/0007-registro-de-dados-para-pesquisa.md
- Rotação: cada arquivo vira `metricas-<data>-size.json` ao passar de 20 MB; acima de 500
  arquivos antigos o Collector apaga os mais velhos. Copie derivados para
  docs/estudo-de-caso/dados/ de tempos em tempos. Os arquivos brutos NUNCA vão ao repositório.
