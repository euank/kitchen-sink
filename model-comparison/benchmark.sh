#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

MODELS=(
  # OpenAI 2025+
  "gpt-4.5-preview"
  "gpt-4.1"
  "gpt-4.1-mini"
  "gpt-4.1-nano"
  "o3-mini"
  "o3"
  "o4-mini"
  "gpt-5"
  "gpt-5-mini"
  "gpt-5-nano"
  "gpt-5.1"
  "gpt-5.2"
  "gpt-5.4"
  "gpt-5.4-mini"
  "gpt-5.4-nano"
  # Gemini 2025+
  "gemini/gemini-2.5-pro"
  "gemini/gemini-2.5-flash"
  "gemini/gemini-2.5-flash-lite"
  "gemini/gemini-3-pro-preview"
  "gemini/gemini-3-flash-preview"
  "gemini/gemini-3.1-pro-preview"
  # Anthropic 2025+
  "anthropic/claude-3-7-sonnet-latest"
  "anthropic/claude-opus-4-0"
  "anthropic/claude-sonnet-4-0"
  "anthropic/claude-opus-4-1-20250805"
  "anthropic/claude-sonnet-4-5"
  "anthropic/claude-haiku-4-5-20251001"
  "anthropic/claude-opus-4-5-20251101"
  "anthropic/claude-opus-4-6"
  "anthropic/claude-sonnet-4-6"
)

RUNS=10
PROMPT="Please output your best guess at the Japanese characters in this image. Do not output any other text."
EXPECTED="一度言ってしまったら、もう後には退けなかった。"
CSV="results.csv"

echo "model,run,output,correct,duration_s" > "$CSV"

for model in "${MODELS[@]}"; do
  echo "=== Benchmarking: $model ==="
  for run in $(seq 1 $RUNS); do
    echo "  Run $run/$RUNS..."
    start=$(date +%s%N)
    output=$(llm -m "$model" -a sample2.jpg "$PROMPT" 2>/dev/null || echo "ERROR")
    end=$(date +%s%N)
    duration=$(echo "scale=3; ($end - $start) / 1000000000" | bc)

    # Trim whitespace
    trimmed=$(echo "$output" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    if [ "$trimmed" = "$EXPECTED" ]; then
      correct="correct"
    else
      correct="incorrect"
    fi

    # Escape output for CSV (replace quotes, newlines)
    csv_output=$(echo "$output" | tr '\n' ' ' | sed 's/"/""/g')

    echo "$model,$run,\"$csv_output\",$correct,$duration" >> "$CSV"
    echo "    Output: $trimmed"
    echo "    Correct: $correct | Duration: ${duration}s"
  done
done

echo ""
echo "Results saved to $CSV"
