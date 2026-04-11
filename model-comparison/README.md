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

I picked a grab-bag of recent models. These numbers are from 4 samples x 10 runs per model.

![Benchmark Results](benchmark_results.png)

| Model | Accuracy | Avg Time |
|-------|----------|----------|
| gpt-4.1 | 85% | 2.7s |
| gpt-4.1-mini | 90% | 2.3s |
| gpt-4.1-nano | 38% | 2.2s |
| o3 | 82% | 9.9s |
| o4-mini | 90% | 6.3s |
| gpt-5 | 70% | 13.4s |
| gpt-5-mini | 52% | 9.0s |
| gpt-5-nano | 57% | 14.2s |
| gpt-5.1 | 75% | 2.7s |
| gpt-5.2 | 100% | 1.9s |
| gpt-5.4 | 90% | 2.3s |
| gpt-5.4-mini | 62% | 1.9s |
| gpt-5.4-nano | 28% | 1.9s |
| gemini-2.5-pro | 72% | 11.7s |
| gemini-2.5-flash | 60% | 5.0s |
| gemini-2.5-flash-lite | 50% | 3.2s |
| gemini-3-pro-preview | 90% | 11.2s |
| gemini-3-flash-preview | 75% | 6.4s |
| gemini-3.1-pro-preview | 80% | 11.8s |
| claude-opus-4-0 | 50% | 4.2s |
| claude-sonnet-4-0 | 60% | 4.1s |
| claude-opus-4-1-20250805 | 50% | 4.4s |
| claude-sonnet-4-5 | 42% | 3.5s |
| claude-haiku-4-5-20251001 | 32% | 2.2s |
| claude-opus-4-5-20251101 | 50% | 4.3s |
| claude-opus-4-6 | 50% | 4.1s |
| claude-sonnet-4-6 | 75% | 3.0s |

## Raw Data

See [results.csv](results.csv) for full per-run data.

## Reproduction

```bash
bash benchmark.sh
nix-shell -p python3Packages.matplotlib python3Packages.numpy --run "python3 graph.py"
```
