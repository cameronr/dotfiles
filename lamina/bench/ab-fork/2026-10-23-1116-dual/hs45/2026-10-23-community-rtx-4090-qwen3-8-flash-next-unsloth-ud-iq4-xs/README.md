# Community benchmark on NVIDIA GeForce RTX 4090

Measured on 2026-10-23 with `tools/strata_bench.py` (suite 1, 3 runs per test, medians with ranges). Speeds are the engine's own timings; first-token times are measured by the client over HTTP. Speed only: no correctness check was run.

## Hardware and software

- GPU and VRAM: NVIDIA GeForce RTX 4090, 24 GiB VRAM
- CPU: AMD Ryzen 7 9800X3D 8-Core Processor (8 cores, 16 threads); installed RAM: 93.9 GiB; storage: not measured
- OS: Linux 7.2.5-3-omarchy; GPU driver: 610.57.04; CUDA: not read
- Strata: project 0.1.43.1, commit a85301ca; engine 0.1.43.1
- Background workloads and power limits: not recorded

## Model and configuration

- Model and quantization: qwen3.8-flash-next-unsloth-ud-iq4_xs
- Context: 262144 tokens; parallel slots: 1
- Settings: the install's own configuration, unchanged; thinking off for the suite; temperature 0

## Method

Run by `python tools/strata_bench.py --long 32768 131072` against the HTTP API of a Strata server (already running); model loading is not timed. One warm-up chat and a 1K prompt are discarded first. Every prompt starts with a unique tag, so the conversation cache cannot help the fresh-prompt tests.

- short chat: the three questions of `tools/ab_engine.py`, up to 100 new tokens, 3 runs
- 4K / 16K / 32K / 128K prompts: generated word lists sized by a calibration request, 24 new tokens, 3 fresh prompts each
- agent session: system prompt and four tools, then 5 turns that each add about 1500 words of a project file and continue from the model's own earlier answers (the way agent clients resend a conversation), 64 new tokens per turn, 3 sessions; the cache numbers come from the answer's usage (`cached_tokens`) and timings (`prompt_n`)
- concurrency (when run): N requests sent at the same moment, total tokens over the wall time of the burst, latency over all requests

## Results

| Configuration | Actual prompt tokens | Reused tokens | Generated tokens | Runs | Prompt tok/s median and range | Decode tok/s median and range | TTFT seconds median and range |
| --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| short chat | 46 (43-51) | 0 | 100 (100-100) | 9 | not measured | 125.5 (98.5-145.0) | 0.20 (0.18-0.29) |
| 4K prompt, fresh | 4019 (4019-4019) | 0 (0-0) | 24 cap | 3 | 2287.3 (2220.7-2308.6) | not measured | 1.78 (1.77-1.83) |
| 16K prompt, fresh | 16058 (16058-16058) | 0 (0-0) | 24 cap | 3 | 2784.4 (2777.5-2790.6) | not measured | 5.80 (5.79-5.81) |
| 32K prompt, fresh | 32049 (32049-32049) | 0 (0-0) | 24 cap | 3 | 3964.0 (3925.8-4310.1) | not measured | 8.12 (7.78-8.20) |
| 128K prompt, fresh | 127975 (127975-127975) | 0 (0-0) | 24 cap | 3 | 5325.1 (5321.6-5406.9) | not measured | 24.12 (23.83-24.14) |
| agent session, follow-up turns | 14771 (14760-14785) at the last turn | see below | up to 64 | 3 | see below | 108.3 (76.7-121.4) | 1.38 (0.90-1.73) |

Ranges are the lowest and highest of the runs; `Runs` counts requests that returned a token.

### Agent session (conversation cache)

Cache hit over the follow-up turns: 69.5 % (69.5-69.5); earlier-turn tokens read again per session: 4 (4-4) (earlier turns that the cache did not hold; the 13928 (13928-13929) new tokens of the files are read once); first turn (nothing cached) first token: 0.96 s (0.34-1.08).

| Turn (run 1) | Prompt tokens | Reused | Read | Prompt tok/s | First token (s) | Decode tok/s |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 0 | 609 | 0 | 609 | 677.8 | 0.956 | 75.8 |
| 1 | 4109 | 623 | 3486 | 2121.6 | 1.727 | 101.6 |
| 2 | 5642 | 4172 | 1470 | 1556.5 | 1.013 | 108.3 |
| 3 | 9191 | 5705 | 3486 | 2325.9 | 1.583 | 82.7 |
| 4 | 11921 | 9238 | 2683 | 2033.0 | 1.404 | 76.7 |
| 5 | 14760 | 11953 | 2807 | 2159.2 | 1.384 | 100.0 |

Per-request data: `results.json`. Engine log lines from the start: `engine-log-excerpt.txt` (when this run started the server).

## Correctness and limitations

Not measured: this is a speed suite. The conversation uses the model's own replies, so token counts differ a little between runs. Machine details come from the server, `nvidia-smi`/`rocm-smi` and the OS; background load and power limits are not recorded. Total time of the suite: 163 s.
