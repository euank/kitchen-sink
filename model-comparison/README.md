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
| gpt-4.1 | 84% | 3.0s |
| gpt-4.1-mini | 96% | 2.6s |
| gpt-4.1-nano | 62% | 2.2s |
| o3 | 80% | 7.9s |
| o4-mini | 92% | 6.2s |
| gpt-5 | 50% | 16.5s |
| gpt-5-mini | 52% | 9.0s |
| gpt-5-nano | 54% | 10.6s |
| gpt-5.1 | 68% | 2.9s |
| gpt-5.2 | 100% | 2.7s |
| gpt-5.4 | 82% | 2.4s |
| gpt-5.4-mini | 58% | 2.5s |
| gpt-5.4-nano | 24% | 3.0s |
| gemini-2.5-pro | 66% | 13.1s |
| gemini-2.5-flash | 52% | 6.2s |
| gemini-2.5-flash-lite | 44% | 4.1s |
| gemini-3-pro-preview | 70% | 56.6s |
| gemini-3-flash-preview | 70% | 5.8s |
| gemini-3.1-pro-preview | 70% | 32.3s |
| claude-opus-4-0 | 44% | 4.6s |
| claude-sonnet-4-0 | 58% | 4.1s |
| claude-opus-4-1-20250805 | 42% | 4.7s |
| claude-sonnet-4-5 | 36% | 4.0s |
| claude-haiku-4-5-20251001 | 24% | 2.6s |
| claude-opus-4-5-20251101 | 62% | 4.3s |
| claude-opus-4-6 | 60% | 4.1s |
| claude-opus-4-7 | 84% | 3.9s |
| claude-sonnet-4-6 | 80% | 4.5s |

## Raw Data

See [results.csv](results.csv) for full per-run data.

## Reproduction

```bash
bash benchmark.sh
nix-shell -p python3Packages.matplotlib python3Packages.numpy --run "python3 graph.py"
```
