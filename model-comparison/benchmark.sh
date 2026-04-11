#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

MODELS=(
  # OpenAI 2025+
  "gpt-4.1"
  "gpt-4.1-mini"
  "gpt-4.1-nano"
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
CSV="results.csv"

declare -a SAMPLE_IDS=()
declare -a SAMPLE_IMAGES=()
declare -a SAMPLE_ANSWER_FILES=()

is_correct_output() {
  local output="$1"
  local answer_file="$2"
  local candidate

  while IFS= read -r candidate || [ -n "$candidate" ]; do
    if [ "$output" = "$candidate" ]; then
      return 0
    fi
  done < <(tr -d '\r' < "$answer_file")

  return 1
}

for answer_file in samples/*.txt; do
  sample_id="${answer_file%.txt}"
  sample_id="${sample_id#samples/}"
  image_file=""

  for ext in jpg jpeg png webp; do
    candidate="samples/${sample_id}.${ext}"
    if [ -f "$candidate" ]; then
      image_file="$candidate"
      break
    fi
  done

  if [ -z "$image_file" ]; then
    echo "Skipping sample '$sample_id': no matching image file found." >&2
    continue
  fi

  SAMPLE_IDS+=("$sample_id")
  SAMPLE_IMAGES+=("$image_file")
  SAMPLE_ANSWER_FILES+=("$answer_file")
done

if [ "${#SAMPLE_IDS[@]}" -eq 0 ]; then
  echo "No valid samples found in samples/." >&2
  exit 1
fi

echo "model,sample,run,output,correct,duration_s" > "$CSV"
echo "Found ${#SAMPLE_IDS[@]} samples. Running $RUNS attempts per sample."

for model in "${MODELS[@]}"; do
  echo "=== Benchmarking: $model ==="
  for i in "${!SAMPLE_IDS[@]}"; do
    sample_id="${SAMPLE_IDS[$i]}"
    image_file="${SAMPLE_IMAGES[$i]}"
    answer_file="${SAMPLE_ANSWER_FILES[$i]}"
    echo "  Sample $sample_id: $image_file"

    for run in $(seq 1 $RUNS); do
      echo "    Run $run/$RUNS..."
      start=$(date +%s%N)
      output=$(llm -m "$model" -a "$image_file" "$PROMPT" 2>/dev/null || echo "ERROR")
      end=$(date +%s%N)
      duration=$(echo "scale=3; ($end - $start) / 1000000000" | bc)

      # Trim whitespace before exact-match grading.
      trimmed=$(echo "$output" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

      if is_correct_output "$trimmed" "$answer_file"; then
        correct="correct"
      else
        correct="incorrect"
      fi

      # Escape output for CSV (replace quotes, newlines)
      csv_output=$(echo "$output" | tr '\n' ' ' | sed 's/"/""/g')

      echo "$model,$sample_id,$run,\"$csv_output\",$correct,$duration" >> "$CSV"
      echo "      Output: $trimmed"
      echo "      Correct: $correct | Duration: ${duration}s"
    done
  done
done

echo ""
echo "Results saved to $CSV"
