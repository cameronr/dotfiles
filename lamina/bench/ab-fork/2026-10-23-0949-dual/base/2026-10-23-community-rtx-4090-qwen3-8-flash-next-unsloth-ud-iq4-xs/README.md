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
| short chat | 46 (43-51) | 0 | 100 (100-100) | 9 | not measured | 122.9 (95.1-143.0) | 0.20 (0.19-0.29) |
| 4K prompt, fresh | 4019 (4019-4019) | 0 (0-0) | 24 cap | 3 | 2293.2 (2224.9-2313.8) | not measured | 1.78 (1.76-1.83) |
| 16K prompt, fresh | 16058 (16058-16058) | 0 (0-0) | 24 cap | 3 | 2773.6 (2763.7-2773.7) | not measured | 5.82 (5.82-5.84) |
| 32K prompt, fresh | 32049 (32049-32049) | 0 (0-0) | 24 cap | 3 | 3974.8 (3929.2-4296.9) | not measured | 8.10 (7.79-8.20) |
| 128K prompt, fresh | 127975 (127975-127975) | 0 (0-0) | 24 cap | 3 | 5316.2 (5305.4-5431.8) | not measured | 24.16 (23.72-24.21) |
| agent session, follow-up turns | 14780 (14753-14792) at the last turn | see below | up to 64 | 3 | see below | 105.5 (80.7-126.6) | 1.39 (0.90-1.64) |

Ranges are the lowest and highest of the runs; `Runs` counts requests that returned a token.

### Agent session (conversation cache)

Cache hit over the follow-up turns: 69.5 % (69.5-69.5); earlier-turn tokens read again per session: 4 (4-4) (earlier turns that the cache did not hold; the 13928 (13928-13928) new tokens of the files are read once); first turn (nothing cached) first token: 0.96 s (0.36-1.08).

| Turn (run 1) | Prompt tokens | Reused | Read | Prompt tok/s | First token (s) | Decode tok/s |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 0 | 609 | 0 | 609 | 671.2 | 0.964 | 88.8 |
| 1 | 4120 | 634 | 3486 | 2243.1 | 1.638 | 108.2 |
| 2 | 5653 | 4183 | 1470 | 1589.9 | 0.993 | 110.6 |
| 3 | 9202 | 5716 | 3486 | 2340.2 | 1.573 | 89.4 |
| 4 | 11928 | 9245 | 2683 | 2057.2 | 1.388 | 81.8 |
| 5 | 14780 | 11973 | 2807 | 2146.7 | 1.39 | 115.5 |

Per-request data: `results.json`. Engine log lines from the start: `engine-log-excerpt.txt` (when this run started the server).

## Correctness and limitations

Not measured: this is a speed suite. The conversation uses the model's own replies, so token counts differ a little between runs. Machine details come from the server, `nvidia-smi`/`rocm-smi` and the OS; background load and power limits are not recorded. Total time of the suite: 163 s.
