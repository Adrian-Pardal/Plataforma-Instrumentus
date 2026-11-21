# shellcheck shell=bash
# shellcheck disable=SC2034  # SEGMENTOS é lida pelos hooks que carregam este arquivo
# divisor.sh — divisor de comandos compartilhado pelos hooks (ADR 0005, plano 001).
# Carregado por "source"; não tem shebang e não roda sozinho.

# Divide um comando do shell em segmentos (um por comando) e deixa o resultado em SEGMENTOS.
# T1 🎓: esqueleto vazio; o corpo é do dono.
dividir_comando() {   # $1 = o texto do comando
  SEGMENTOS=()
}
