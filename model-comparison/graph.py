#!/usr/bin/env python3
import csv
import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict
from matplotlib.patches import Patch

results = defaultdict(lambda: {"correct": 0, "total": 0, "durations": []})
sample_ids = set()

with open("results.csv") as f:
    reader = csv.DictReader(f)
    for row in reader:
        model = row["model"]
        sample_id = row.get("sample") or "sample-1"
        sample_ids.add(sample_id)
        results[model]["total"] += 1
        if row["correct"] == "correct":
            results[model]["correct"] += 1
        results[model]["durations"].append(float(row["duration_s"]))

# Filter out models that errored on every run (no vision support / not available)
error_models = []
valid_models = []
for m in results:
    outputs = []
    with open("results.csv") as f:
        reader = csv.DictReader(f)
        for row in reader:
            if row["model"] == m:
                outputs.append(row["output"].strip())
    if all(o == "ERROR" for o in outputs):
        error_models.append(m)
    else:
        valid_models.append(m)

models = valid_models
accuracy = [results[m]["correct"] / results[m]["total"] * 100 for m in models]
avg_time = [np.mean(results[m]["durations"]) for m in models]
runs_per_sample = max((results[m]["total"] // max(len(sample_ids), 1)) for m in models) if models else 0

# Short labels
labels = [m.split("/")[-1] for m in models]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(22, 8))

# Color by provider
def get_color(m):
    if "gpt" in m or m.startswith("o3") or m.startswith("o4"):
        return "#74aa9c"
    elif "gemini" in m:
        return "#4285f4"
    elif "claude" in m or "anthropic" in m:
        return "#d4a574"
    return "#888888"

colors = [get_color(m) for m in models]
x = np.arange(len(models))

bars1 = ax1.bar(x, accuracy, color=colors)
ax1.set_ylabel("Accuracy (%)", fontsize=12)
ax1.set_title(
    f"OCR Accuracy (Japanese Text) — {runs_per_sample} runs x {len(sample_ids)} samples per model",
    fontsize=14,
)
ax1.set_xticks(x)
ax1.set_xticklabels(labels, rotation=55, ha="right", fontsize=8)
ax1.set_ylim(0, 115)
for bar, val in zip(bars1, accuracy):
    ax1.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 1,
             f"{val:.0f}%", ha="center", va="bottom", fontsize=7)

bars2 = ax2.bar(x, avg_time, color=colors)
ax2.set_ylabel("Avg Duration (seconds)", fontsize=12)
ax2.set_title("Average Response Time", fontsize=14)
ax2.set_xticks(x)
ax2.set_xticklabels(labels, rotation=55, ha="right", fontsize=8)
for bar, val in zip(bars2, avg_time):
    ax2.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.1,
             f"{val:.1f}s", ha="center", va="bottom", fontsize=7)

legend_elements = [
    Patch(facecolor="#74aa9c", label="OpenAI"),
    Patch(facecolor="#4285f4", label="Google"),
    Patch(facecolor="#d4a574", label="Anthropic"),
]
fig.legend(handles=legend_elements, loc="upper center", ncol=3, fontsize=11,
           bbox_to_anchor=(0.5, 0.98))

plt.tight_layout(rect=[0, 0, 1, 0.93])
plt.savefig("benchmark_results.png", dpi=150, bbox_inches="tight")
print("Graph saved to benchmark_results.png")

# Print summary for README
print("\n## Summary\n")
print("| Model | Accuracy | Avg Time |")
print("|-------|----------|----------|")
for m, acc, t in zip(models, accuracy, avg_time):
    label = m.split("/")[-1]
    print(f"| {label} | {acc:.0f}% | {t:.1f}s |")

if error_models:
    print("\n### Models excluded (errored on all runs)\n")
    for m in error_models:
        print(f"- {m.split('/')[-1]}")
