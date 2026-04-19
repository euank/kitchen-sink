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
| gpt-4.1 | 78% | 2.7s |
| gpt-4.1-mini | 92% | 2.1s |
| gpt-4.1-nano | 42% | 2.1s |
| o3 | 74% | 9.2s |
| o4-mini | 96% | 5.1s |
| gpt-5 | 56% | 13.9s |
| gpt-5-mini | 56% | 7.6s |
| gpt-5-nano | 50% | 13.9s |
| gpt-5.1 | 62% | 2.5s |
| gpt-5.2 | 94% | 2.2s |
| gpt-5.4 | 84% | 2.5s |
| gpt-5.4-mini | 58% | 2.0s |
| gpt-5.4-nano | 20% | 1.9s |
| gemini-2.5-pro | 68% | 11.6s |
| gemini-2.5-flash | 52% | 5.0s |
| gemini-2.5-flash-lite | 48% | 3.8s |
| gemini-3-pro-preview | 70% | 14.2s |
| gemini-3-flash-preview | 64% | 5.6s |
| gemini-3.1-pro-preview | 70% | 12.3s |
| claude-opus-4-0 | 40% | 4.5s |
| claude-sonnet-4-0 | 56% | 3.8s |
| claude-opus-4-1-20250805 | 40% | 4.8s |
| claude-sonnet-4-5 | 40% | 4.5s |
| claude-haiku-4-5-20251001 | 20% | 2.9s |
| claude-opus-4-5-20251101 | 60% | 3.7s |
| claude-opus-4-6 | 62% | 4.4s |
| claude-sonnet-4-6 | 80% | 3.5s |

## Raw Data

See [results.csv](results.csv) for full per-run data.

## Reproduction

```bash
bash benchmark.sh
nix-shell -p python3Packages.matplotlib python3Packages.numpy --run "python3 graph.py"
```
