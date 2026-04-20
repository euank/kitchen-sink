## LLM OCR benchmark

It's interesting to try different models on things that they fail on to see which ones fail.

The benchmark uses the labeled images in [`samples/`](./samples/) to compare OCR performance across models.

Note: copyright steins;gate I guess? This isn't a substitute for the visual novel, so I'm hoping it's fair use.

### Task

Each model is given every image in [`samples/`](./samples/) and asked:

> "Please output your best guess at the Japanese characters in this image. Do not output any other text."

Each sample's `.txt` file contains newline-delimited acceptable exact answers. An output is scored as "correct" if it exactly matches any line in that sample's `.txt`.

Each model is run 10 times per sample, and the reported accuracy is across all runs for all samples.

## Results

I picked a grab-bag of recent models. These numbers are from 5 samples x 10 runs per model.

![Benchmark Results](benchmark_results.png)

| Model | Accuracy | Avg Time |
|-------|----------|----------|
| gpt-4.1 | 80% | 3.0s |
| gpt-4.1-mini | 98% | 2.3s |
| gpt-4.1-nano | 48% | 2.0s |
| o3 | 76% | 6.4s |
| o4-mini | 86% | 4.9s |
| gpt-5 | 52% | 14.0s |
| gpt-5-mini | 54% | 7.8s |
| gpt-5-nano | 48% | 10.9s |
| gpt-5.1 | 62% | 2.8s |
| gpt-5.2 | 98% | 2.2s |
| gpt-5.4 | 90% | 2.4s |
| gpt-5.4-mini | 62% | 2.3s |
| gpt-5.4-nano | 24% | 2.1s |
| gemini-2.5-pro | 66% | 11.0s |
| gemini-2.5-flash | 46% | 4.3s |
| gemini-2.5-flash-lite | 46% | 2.8s |
| gemini-3-pro-preview | 68% | 12.6s |
| gemini-3-flash-preview | 64% | 5.6s |
| gemini-3.1-pro-preview | 74% | 11.0s |
| claude-opus-4-0 | 40% | 4.5s |
| claude-sonnet-4-0 | 66% | 4.0s |
| claude-opus-4-1-20250805 | 38% | 4.6s |
| claude-sonnet-4-5 | 46% | 3.8s |
| claude-haiku-4-5-20251001 | 24% | 2.3s |
| claude-opus-4-5-20251101 | 60% | 3.8s |
| claude-opus-4-6 | 62% | 5.0s |
| claude-sonnet-4-6 | 80% | 3.8s |

`claude-opus-4-7` was attempted but errored on all runs, so it is excluded from the chart and summary table.

## Raw Data

See [results.csv](results.csv) for full per-run data.

## Reproduction

```bash
bash benchmark.sh
nix-shell -p python3Packages.matplotlib python3Packages.numpy --run "python3 graph.py"
```
