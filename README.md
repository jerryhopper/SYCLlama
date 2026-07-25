# start_modelv2.sh — Universal llama-server Launcher

A single script that maps **all** llama-server CLI parameters to environment variables. Drop-in replacement for the old `start_model.sh` with full parameter coverage.

## Quick Start

```bash
# Minimal — just set model and port
export MODEL=/models/Qwen3-Embedding-0.6B-Q8_0.gguf
export PORT=8080
./src/start_modelv2.sh
```

That's it. All other parameters are optional.

## Environment Variables Reference

Variables are organized by feature group. Set any via `docker-compose.yml` `environment:` or directly in your shell.

### Core (required)

| Variable | Description | Default |
|---|---|---|
| `MODEL` | Path to GGUF model file | *(required)* |
| `EMBEDDING` | Enable embedding mode | off |
| `NOMMAP` | Disable memory-mapped file loading | off |

### Server

| Variable | Description | Default |
|---|---|---|
| `PORT` | HTTP listen port | *(user set)* |
| `HOST` | HTTP listen host | *(user set)* |
| `API_KEY` | OpenAI-compatible API key | none |
| `CORIS_BASE` | Coris base URL | none |
| `CORIS_MODEL` | Coris model name | none |
| `CORIS_EXTRA_PARAMS` | Coris extra JSON params | none |
| `TOML_CONFIG_PATH` | Load config from TOML file | none |

### Context & Batching

| Variable | Description | Default |
|---|---|---|
| `CTX_SIZE` | Prompt context size | model default |
| `CTX_CHECKPOINTS` | Max context checkpoints | 32 |
| `BATCH_SIZE` | Logical max batch size | 2048 |
| `UBATCH_SIZE` | Physical max batch size | 512 |
| `KEEP` | Tokens to keep from initial prompt | 0 |
| `N_PREDICT` | Tokens to predict (-1 = infinity) | -1 |

### Threading

| Variable | Description | Default |
|---|---|---|
| `THREADS` | CPU threads for generation | -1 (auto) |
| `THREADS_BATCH` | Threads for batch processing | same as THREADS |
| `CPU_MASK` | Hex CPU affinity mask | "" |
| `CPU_RANGE` | CPU range for affinity | "" |
| `CPU_STRICT` | Strict CPU placement (0/1) | 0 |
| `PRIO` | Process/thread priority (-1..3) | 0 |
| `POLL` | Polling level (0..100) | 50 |
| `CPU_MASK_BATCH` | Batch CPU affinity mask | same as CPU_MASK |
| `CPU_RANGE_BATCH` | Batch CPU range | same as CPU_RANGE |
| `CPU_STRICT_BATCH` | Batch strict placement | same as CPU_STRICT |
| `PRIO_BATCH` | Batch priority | 0 |
| `POLL_BATCH` | Batch polling | same as POLL |

### GPU / Offload

| Variable | Description | Default |
|---|---|---|
| `N_GPU_LAYERS` | Layers to offload to VRAM | auto |
| `SPLIT_MODE` | Multi-GPU split: none/layer/row/tensor | layer |
| `TENSOR_SPLIT` | Proportions per GPU (comma-separated) | none |
| `MAIN_GPU` | Main GPU index | 0 |
| `DEVICE` | Device list (comma-separated) | auto |
| `KV_OFFLOAD` | KV cache offload | enabled |
| `OP_OFFLOAD` | Host tensor op offload | enabled |
| `FIT` | Auto-fit to device memory (on/off) | on |
| `FIT_TARGET` | Target margin per device (MiB) | 1024 |
| `FIT_CTX` | Min ctx size for --fit | 4096 |
| `OVERRIDE_TENSOR` | Tensor buffer override | none |
| `CPU_MOE` | Keep all MoE weights on CPU | off |
| `N_CPU_MOE` | Keep first N MoE layers on CPU | 0 |
| `NUMA` | NUMA optimization: distribute/isolate/numactl | off |
| `MLOCK` | Keep model in RAM (force) | off |
| `MMAP` | Memory-map model file | enabled |
| `DIRECT_IO` | Use DirectIO | disabled |
| `REPACK` | Enable weight repacking | enabled |
| `NO_HOST` | Bypass host buffer | off |

### KV Cache

| Variable | Description | Default |
|---|---|---|
| `CACHE_TYPE_K` | K cache type: f32/f16/bf16/q8_0/q4_0/q4_1/iq4_nl/q5_0/q5_1 | f16 |
| `CACHE_TYPE_V` | V cache type: f32/f16/bf16/q8_0/q4_0/q4_1/iq4_nl/q5_0/q5_1 | f16 |
| `CACHE_RAM` | Max cache RAM in MiB | 8192 |
| `DEFRAG_THOLD` | KV cache defrag threshold (deprecated) | off |

### Attention / Context

| Variable | Description | Default |
|---|---|---|
| `FLASH_ATTN` | Flash Attention: on/off/auto | auto |
| `SWA_FULL` | Full SWA cache | false |
| `CONTEXT_SHIFT` | Context shift on infinite generation | disabled |

### RoPE / Scaling

| Variable | Description | Default |
|---|---|---|
| `ROPE_SCALING` | RoPE method: none/linear/yarn | model default |
| `ROPE_SCALE` | RoPE context scaling factor | 1.0 |
| `ROPE_FREQ_BASE` | RoPE base frequency | model default |
| `ROPE_FREQ_SCALE` | RoPE frequency scaling factor | 1.0 |
| `YARN_ORIG_CTX` | YaRN original context size | model training ctx |
| `YARN_EXT_FACTOR` | YaRN extrapolation factor | -1.0 |
| `YARN_ATTN_FACTOR` | YaRN attention magnitude factor | -1.0 |
| `YARN_BETA_SLOW` | YaRN high correction dim (alpha) | -1.0 |
| `YARN_BETA_FAST` | YaRN low correction dim (beta) | -1.0 |

### Parallel Decoding

| Variable | Description | Default |
|---|---|---|
| `PARALLEL` | Parallel sequences to decode | 1 |

### Sampling

| Variable | Description | Default |
|---|---|---|
| `TEMPERATURE` | Sampling temperature | 0.8 |
| `TOP_K` | Top-k sampling (0 = disabled) | 40 |
| `TOP_P` | Top-p sampling (1.0 = disabled) | 0.95 |
| `MIN_P` | Min-p sampling (0.0 = disabled) | 0.05 |
| `TOP_N_SIGMA` | Top-n-sigma (-1 = disabled) | -1 |
| `XTC_PROBABILITY` | XTC probability (0.0 = disabled) | 0.0 |
| `XTC_THRESHOLD` | XTC threshold (1.0 = disabled) | 0.1 |
| `TYPICAL_P` | Locally typical sampling p (1.0 = disabled) | 1.0 |
| `REPEAT_LAST_N` | Last N tokens for penalize (0 = disabled) | 64 |
| `REPEAT_PENALTY` | Repeat penalty (1.0 = disabled) | 1.0 |
| `PRESENCE_PENALTY` | Presence penalty (0.0 = disabled) | 0.0 |
| `FREQUENCY_PENALTY` | Frequency penalty (0.0 = disabled) | 0.0 |
| `DRY_MULTIPLIER` | DRY multiplier (0.0 = disabled) | 0.0 |
| `DRY_BASE` | DRY base value | 1.75 |
| `DRY_ALLOWED_LENGTH` | DRY allowed length | 2 |
| `DRY_PENALTY_LAST_N` | DRY penalty last N (-1 = ctx_size) | -1 |
| `DRY_SEQUENCE_BREAKER` | DRY sequence breaker | default: \n : " * |
| `ADAPTIVE_TARGET` | Adaptive-p target probability | -1.0 |
| `ADAPTIVE_DECAY` | Adaptive-p decay rate (0.0-0.99) | 0.9 |
| `DYNA_TEMP_RANGE` | Dynamic temperature range (0.0 = disabled) | 0.0 |
| `DYNA_TEMP_EXP` | Dynamic temperature exponent | 1.0 |
| `MIROSTAT` | Mirostat (0=off, 1=Mirostat, 2=Mirostat 2.0) | 0 |
| `MIROSTAT_LR` | Mirostat learning rate (eta) | 0.1 |
| `MIROSTAT_ENT` | Mirostat target entropy (tau) | 5.0 |
| `SEED` | RNG seed (-1 = random) | -1 |
| `IGNORE_EOS` | Ignore end-of-stream token | off |
| `SAMPLERS` | Sampler order (; separated) | penalties;dry;top_n_sigma;top_k;typ_p;top_p;min_p;xtc;temperature |
| `SAMPLER_SEQ` | Simplified sampler sequence | edskypmxt |
| `GRAMMAR` | BNF grammar for constrained generation | none |
| `GRAMMAR_FILE` | Grammar file path | none |
| `JSON_SCHEMA` | JSON schema object string | none |
| `JSON_SCHEMA_FILE` | JSON schema file path | none |
| `LOGIT_BIAS` | Token bias (ID+/-bias) | none |
| `BACKEND_SAMPLING` | Enable backend sampling (experimental) | disabled |

### Speculative Decoding

| Variable | Description | Default |
|---|---|---|
| `SPEC_DRAFT_MODEL` | Draft model path | none |
| `SPEC_DRAFT` | Draft tokens max (--spec-draft-n-max) | 3 |
| `SPEC_DRAFT_N_MIN` | Min draft tokens | 0 |
| `SPEC_DRAFT_P_SPLIT` | Split probability | 0.1 |
| `SPEC_DRAFT_P_MIN` | Min prob (greedy) | 0.0 |
| `SPEC_DRAFT_THREADS` | Draft threads | same as THREADS |
| `SPEC_DRAFT_THREADS_BATCH` | Draft batch threads | same as THREADS_BATCH |
| `SPEC_DRAFT_CPU_MASK` | Draft CPU mask | same as CPU_MASK |
| `SPEC_DRAFT_CPU_RANGE` | Draft CPU range | same as CPU_RANGE |
| `SPEC_DRAFT_CPU_STRICT` | Draft strict placement | same as CPU_STRICT |
| `SPEC_DRAFT_PRIO` | Draft priority | 0 |
| `SPEC_DRAFT_POLL` | Draft polling | same as POLL |
| `SPEC_DRAFT_CACHE_TYPE_K` | Draft K cache type | f16 |
| `SPEC_DRAFT_CACHE_TYPE_V` | Draft V cache type | f16 |
| `SPEC_TYPE` | Speculative type: none/draft-simple/draft-eagle3/draft-mtp/ngram-* | none |
| `SPEC_NGRAM_MOD_N_MIN` | ngram-mod min N | 48 |
| `SPEC_NGRAM_MOD_N_MAX` | ngram-mod max N | 64 |
| `SPEC_NGRAM_MOD_N_MATCH` | ngram-mod lookup length | 24 |
| `SPEC_NGRAM_SIMPLE_SIZE_N` | ngram-simple N size | 12 |
| `SPEC_NGRAM_SIMPLE_SIZE_M` | ngram-simple M size | 48 |
| `SPEC_NGRAM_SIMPLE_MIN_HITS` | ngram-simple min hits | 1 |
| `SPEC_NGRAM_MAP_K_SIZE_N` | ngram-map-k N size | 12 |
| `SPEC_NGRAM_MAP_K_SIZE_M` | ngram-map-k M size | 48 |
| `SPEC_NGRAM_MAP_K_MIN_HITS` | ngram-map-k min hits | 1 |
| `SPEC_NGRAM_MAP_K4V_SIZE_N` | ngram-map-k4v N size | 12 |
| `SPEC_NGRAM_MAP_K4V_SIZE_M` | ngram-map-k4v M size | 48 |
| `SPEC_NGRAM_MAP_K4V_MIN_HITS` | ngram-map-k4v min hits | 1 |

### LoRA / Control Vectors

| Variable | Description | Default |
|---|---|---|
| `LORA` | LoRA adapter path (comma-sep for multiple) | none |
| `LORA_SCALED` | LoRA with scaling (path:scale,...) | none |
| `CONTROL_VECTOR` | Control vector path (comma-sep) | none |
| `CONTROL_VECTOR_SCALED` | Control vector with scale (path:scale,...) | none |
| `CONTROL_VECTOR_LAYER_RANGE` | Control vector layer range (START END) | none |

### Multimodal

| Variable | Description | Default |
|---|---|---|
| `MMPOJ` | mmproj file path | none |
| `MMPOJ_URL` | mmproj URL | none |
| `MMPOJ_AUTO` | Auto-use mmproj if available | enabled |
| `MMPOJ_OFFLOAD` | GPU offload for mmproj | enabled |
| `IMAGE` | Image file path (comma-sep) | none |
| `AUDIO` | Audio file path (comma-sep) | none |
| `VIDEO` | Video file path (comma-sep) | none |
| `IMAGE_MIN_TOKENS` | Min tokens per image | model default |
| `IMAGE_MAX_TOKENS` | Max tokens per image | model default |

### Chat / Prompt

| Variable | Description | Default |
|---|---|---|
| `PROMPT` | Initial prompt | none |
| `SYSTEM_PROMPT` | System prompt | none |
| `SYSTEM_PROMPT_FILE` | System prompt file | none |
| `FILE` | Prompt file path | none |
| `BINARY_FILE` | Binary prompt file | none |
| `REVERSE_PROMPT` | Halt on prompt match | none |
| `CHAT_TEMPLATE` | Jinja chat template name | model default |
| `CHAT_TEMPLATE_FILE` | Custom Jinja template file | none |
| `JINJA` | Use Jinja template (on/off) | enabled |
| `SKIP_CHAT_PARSING` | Pure content parser | disabled |
| `CHAT_TEMPLATE_KWARGS` | JSON template parser kwargs | none |
| `REASONING` | Reasoning/thinking: on/off/auto | auto |
| `REASONING_FORMAT` | Thought tag format: none/deepseek/deepseek-legacy | auto |
| `REASONING_BUDGET` | Thinking token budget (-1=unrestricted) | -1 |
| `REASONING_BUDGET_MESSAGE` | Budget exhausted message | none |

### Output / Display

| Variable | Description | Default |
|---|---|---|
| `CONVERSATION` | Conversation mode (auto enabled) | auto |
| `SINGLE_TURN` | Single turn only | false |
| `MULTILINE_INPUT` | Multi-line input mode | false |
| `DISPLAY_PROMPT` | Display prompt at generation | true |
| `COLOR` | Colorize output: on/off/auto | auto |
| `ESCAPE` | Process escape sequences | true |
| `SIMPLE_IO` | Basic IO for subprocesses | false |
| `SPECIAL` | Enable special tokens output | false |
| `VERBOSE_PROMPT` | Print verbose prompt before generation | false |
| `WARMUP` | Warmup with empty run | enabled |
| `SHOW_TIMINGS` | Show timing after response | enabled |

### Logging

| Variable | Description | Default |
|---|---|---|
| `LOG_DISABLE` | Disable all logging | off |
| `LOG_FILE` | Log to file path | none |
| `LOG_COLORS` | Colored logging: on/off/auto | auto |
| `LOG_VERBOSITY` | Verbosity threshold (0-5) | 3 (info) |
| `LOG_PREFIX` | Enable log prefixes | enabled |
| `LOG_TIMESTAMPS` | Enable timestamps | enabled |
| `VERBOSE` | Infinite verbosity (debug all) | false |
| `PERF` | Internal libllama performance timings | false |
| `LOG_PROMPTS_DIR` | Log prompts to directory (debug) | none |

### Model Sources

| Variable | Description | Default |
|---|---|---|
| `MODEL_URL` | Model download URL | none |
| `DOCKER_REPO` | Docker Hub model repo | none |
| `HF_REPO` | Hugging Face repo (user/model[:quant]) | none |
| `HF_FILE` | Hugging Face specific file | none |
| `HF_TOKEN` | Hugging Face access token | env: HF_TOKEN |

### Cache / Utilities

| Variable | Description | Default |
|---|---|---|
| `CACHE_LIST` | Show model cache list | off |
| `COMPLETION_BASH` | Print bash completion script | off |
| `LIST_DEVICES` | List available devices and exit | off |

### Presets

| Variable | Description | Default |
|---|---|---|
| `GPT_OSS_20B_DEFAULT` | Use GPT-OSS 20B preset | off |
| `GPT_OSS_120B_DEFAULT` | Use GPT-OSS 120B preset | off |
| `VISION_GEMMA_4B_DEFAULT` | Use Gemma 3 4B QAT preset | off |
| `VISION_GEMMA_12B_DEFAULT` | Use Gemma 3 12B QAT preset | off |
| `SPEC_DEFAULT` | Enable default speculative decoding | off |

### Offline / Misc

| Variable | Description | Default |
|---|---|---|
| `OFFLINE` | Offline mode (force cache) | off |
| `HELP` | Print usage and exit | off |
| `VERSION` | Show version and build info | off |

## Extra Passthrough

Any flag not covered above can be passed via `LLAMA_EXTRA_ARGS`:

```bash
export LLAMA_EXTRA_ARGS="--log-file /tmp/llama.log --verbose"
./src/start_modelv2.sh
```

## Docker Compose Integration

```yaml
services:
  llama:
    build: ./src
    environment:
      - MODEL=/models/Qwen3-Embedding-0.6B-Q8_0.gguf
      - EMBEDDING=1
      - HOST=0.0.0.0
      - PORT=8080
      # Uncomment as needed:
      # - CTX_SIZE=8192
      # - THREADS=16
      # - CACHE_TYPE_K=q4_0
      # - CACHE_TYPE_V=q4_0
      # - FLASH_ATTN=on
      - SYCL_DEVICE_INDEX=0
```

## Intel oneAPI / SYCL
The script auto-detects `SYCL_DEVICE_INDEX` and sets up the following environment variables:

- `ZES_ENABLE_SYSMAN=1`
- `ONEAPI_DEVICE_SELECTOR=level_zero:${SYCL_DEVICE_INDEX}`

No extra config needed.

## Migration from start_model.sh

| Old Variable | New Variable | Notes |
|---|---|---|
| `GGUF` | `MODEL` | Direct replacement |
| `MMPROJ` | `MMPOJ` | Renamed (shorter) |
| `CTX_SIZE` | `CTX_SIZE` | Unchanged |
| `CACHE_K` | `CACHE_TYPE_K` | Renamed |
| `CACHE_V` | `CACHE_TYPE_V` | Renamed |
| `SPEC_DRAFT` | `SPEC_DRAFT` | Unchanged |
| `CTX_CHECKPOINTS` | `CTX_CHECKPOINTS` | Unchanged |
| `HOST` | `HOST` | Unchanged |
| `PORT` | `PORT` | Unchanged |
| `SYCL_DEVICE_INDEX` | `SYCL_DEVICE_INDEX` | Unchanged |


