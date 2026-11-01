# Community benchmark on NVIDIA GeForce RTX 3090

Measured on 2026-10-23 with `tools/strata_bench.py` (suite 1, 3 runs per test, medians with ranges). Speeds are the engine's own timings; first-token times are measured by the client over HTTP. Speed only: no correctness check was run.

## Hardware and software

- GPU and VRAM: NVIDIA GeForce RTX 3090, 24 GiB VRAM
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
| short chat | 46 (43-51) | 0 | 100 (100-100) | 9 | not measured | 64.7 (51.4-79.5) | 0.44 (0.37-0.60) |
| 4K prompt, fresh | 4019 (4019-4019) | 0 (0-0) | 24 cap | 3 | 536.4 (534.6-540.8) | not measured | 7.55 (7.47-7.56) |
| 16K prompt, fresh | 16058 (16058-16058) | 0 (0-0) | 24 cap | 3 | 1369.0 (1364.7-1369.7) | not measured | 11.78 (11.77-11.81) |
| 32K prompt, fresh | 32049 (32049-32049) | 0 (0-0) | 24 cap | 3 | 1397.9 (1395.0-1448.3) | not measured | 22.99 (22.23-23.05) |
| 128K prompt, fresh | 127975 (127975-127975) | 0 (0-0) | 24 cap | 3 | 1396.8 (1395.9-1402.9) | not measured | 91.72 (91.48-91.79) |
| agent session, follow-up turns | 14820 (14784-14823) at the last turn | see below | up to 64 | 3 | see below | 85.4 (64.3-115.4) | 10.99 (9.64-11.74) |

Ranges are the lowest and highest of the runs; `Runs` counts requests that returned a token.

### Agent session (conversation cache)

Cache hit over the follow-up turns: 69.5 % (69.5-69.5); earlier-turn tokens read again per session: 4 (4-4) (earlier turns that the cache did not hold; the 13930 (13928-13930) new tokens of the files are read once); first turn (nothing cached) first token: 10.26 s (0.68-10.45).

| Turn (run 1) | Prompt tokens | Reused | Read | Prompt tok/s | First token (s) | Decode tok/s |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 0 | 609 | 0 | 609 | 59.6 | 10.263 | 57.8 |
| 1 | 4123 | 637 | 3486 | 298.4 | 11.737 | 64.3 |
| 2 | 5656 | 4186 | 1470 | 149.5 | 9.884 | 76.5 |
| 3 | 9205 | 5719 | 3486 | 309.0 | 11.336 | 65.6 |
| 4 | 11952 | 9268 | 2684 | 247.8 | 10.88 | 77.2 |
| 5 | 14823 | 12015 | 2808 | 256.6 | 10.993 | 86.1 |

Per-request data: `results.json`. Engine log lines from the start: `engine-log-excerpt.txt` (when this run started the server).

## Correctness and limitations

Not measured: this is a speed suite. The conversation uses the model's own replies, so token counts differ a little between runs. Machine details come from the server, `nvidia-smi`/`rocm-smi` and the OS; background load and power limits are not recorded. Total time of the suite: 635 s.
