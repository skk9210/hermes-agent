#!/usr/bin/env bash
set -e

echo "=== Hermes Agent startup ==="

# ------------------------------------------------------------------
# 1. Auto-configure the model from environment variables.
#    This runs on every start so no shell access is needed.
#    HERMES_MODEL defaults to a cheap, capable OpenRouter model.
# ------------------------------------------------------------------
PROVIDER="${HERMES_PROVIDER:-openrouter}"
MODEL="${HERMES_MODEL:-deepseek/deepseek-chat}"

echo ">>> Configuring provider: $PROVIDER / model: $MODEL"

# Try the Hermes CLI config command — tolerate failure on first boot
# (config dir may not exist yet before first run)
hermes model set "$PROVIDER" \
  --model "$MODEL" \
  --api-key "${OPENROUTER_API_KEY:-}" \
  2>&1 || echo ">>> Note: 'hermes model set' failed (may be first boot) — continuing anyway"

# ------------------------------------------------------------------
# 2. Ensure the data directory exists (important if disk not mounted)
# ------------------------------------------------------------------
mkdir -p "${HERMES_HOME:-/data/.hermes}"

# ------------------------------------------------------------------
# 3. Start the gateway API server
# ------------------------------------------------------------------
PORT="${PORT:-8000}"
echo ">>> Starting Hermes gateway on 0.0.0.0:$PORT"
exec hermes gateway --host 0.0.0.0 --port "$PORT"
