#!/usr/bin/env bash
#
# start_modelv2.sh — Universal llama-server launcher
#
# Enables ALL llama-server command-line parameters via environment variables.
#
# Usage:
#   export MODEL=/models/my-model.gguf
#   ./start_modelv2.sh
#
# Or override any parameter:
#   export THREADS=16 CTX_SIZE=8192
#   ./start_modelv2.sh
#
# Any parameter not mapped to an env var can still be passed via LLAMA_EXTRA_ARGS.
#
set -euo pipefail

# ─────────────────────────────────────────────────────────────────────
# 1. Validation
# ─────────────────────────────────────────────────────────────────────
MODEL="${MODEL:-}"
if [[ -z "$MODEL" ]]; then
    echo "ERROR: MODEL env var is required. Set MODEL=/models/your-model.gguf" >&2
    exit 1
fi
[[ -f "$MODEL" ]] || { echo "ERROR: Model file not found: $MODEL" >&2; exit 1; }

MMPOJ="${MMPOJ:-}"
if [[ -n "$MMPOJ" ]]; then
    [[ -f "$MMPOJ" ]] || { echo "ERROR: mmproj file not found: $MMPOJ" >&2; exit 1; }
fi

# ─────────────────────────────────────────────────────────────────────
# 2. Build the llama-server command
# ─────────────────────────────────────────────────────────────────────
echo "=== llama-server v2 Launcher ==="
echo "  Model:   $MODEL"
[[ -n "$MMPOJ" ]] && echo "  mmproj:  $MMPOJ"
echo "  Env vars loaded. Building command..."

# Start building the command args
declare -a ARGS=()

# --- Core ---
ARGS+=("-m" "$MODEL")

# --- Model source ---
[[ -n "${MODEL_URL:-}" ]]           && ARGS+=("--model-url" "$MODEL_URL")
[[ -n "${DOCKER_REPO:-}" ]]         && ARGS+=("--docker-repo" "$DOCKER_REPO")
[[ -n "${HF_REPO:-}" ]]             && ARGS+=("--hf-repo" "$HF_REPO")
[[ -n "${HF_FILE:-}" ]]             && ARGS+=("--hf-file" "$HF_FILE")
[[ -n "${HF_TOKEN:-}" ]]            && ARGS+=("--hf-token" "$HF_TOKEN")


# --- embedding
[[ -n "${EMBEDDING:-}" ]]            && ARGS+=("--embedding" )
[[ -n "${NOMMAP:-}" ]]               && ARGS+=("--no-mmap" )



# --- Context & batching ---
[[ -n "${CTX_SIZE:-}" && "$CTX_SIZE" != "0" ]] && ARGS+=("-c" "$CTX_SIZE")
[[ -n "${CTX_CHECKPOINTS:-}" ]]                 && ARGS+=("--ctx-checkpoints" "$CTX_CHECKPOINTS")
[[ -n "${BATCH_SIZE:-}" ]]                      && ARGS+=("-b" "$BATCH_SIZE")
[[ -n "${UBATCH_SIZE:-}" ]]                     && ARGS+=("-ubatch" "$UBATCH_SIZE")
[[ -n "${KEEP:-}" ]]                            && ARGS+=("--keep" "$KEEP")

# --- Prediction ---
[[ -n "${N_PREDICT:-}" ]]                       && ARGS+=("-n" "$N_PREDICT")

# --- Threading ---
[[ -n "${THREADS:-}" ]]                         && ARGS+=("-t" "$THREADS")
[[ -n "${THREADS_BATCH:-}" ]]                   && ARGS+=("-tb" "$THREADS_BATCH")
[[ -n "${CPU_MASK:-}" ]]                        && ARGS+=("-C" "$CPU_MASK")
[[ -n "${CPU_RANGE:-}" ]]                       && ARGS+=("-Cr" "$CPU_RANGE")
[[ -n "${CPU_STRICT:-}" ]]                      && ARGS+=("--cpu-strict" "$CPU_STRICT")
[[ -n "${PRIO:-}" ]]                            && ARGS+=("--prio" "$PRIO")
[[ -n "${POLL:-}" ]]                            && ARGS+=("--poll" "$POLL")
[[ -n "${CPU_MASK_BATCH:-}" ]]                  && ARGS+=("-Cb" "$CPU_MASK_BATCH")
[[ -n "${CPU_RANGE_BATCH:-}" ]]                 && ARGS+=("-Crb" "$CPU_RANGE_BATCH")
[[ -n "${CPU_STRICT_BATCH:-}" ]]                && ARGS+=("--cpu-strict-batch" "$CPU_STRICT_BATCH")
[[ -n "${PRIO_BATCH:-}" ]]                      && ARGS+=("--prio-batch" "$PRIO_BATCH")
[[ -n "${POLL_BATCH:-}" ]]                      && ARGS+=("--poll-batch" "$POLL_BATCH")

# --- GPU / offload ---
[[ -n "${N_GPU_LAYERS:-}" ]]                    && ARGS+=("-ngl" "$N_GPU_LAYERS")
[[ -n "${SPLIT_MODE:-}" ]]                      && ARGS+=("--split-mode" "$SPLIT_MODE")
[[ -n "${TENSOR_SPLIT:-}" ]]                    && ARGS+=("--tensor-split" "$TENSOR_SPLIT")
[[ -n "${MAIN_GPU:-}" ]]                        && ARGS+=("-mg" "$MAIN_GPU")
[[ -n "${DEVICE:-}" ]]                          && ARGS+=("-dev" "$DEVICE")
[[ -n "${REPACK:-}" ]]                          && ARGS+=("--repack" "$REPACK")
[[ -n "${NO_HOST:-}" ]]                         && ARGS+=("--no-host" "$NO_HOST")
[[ -n "${KV_OFFLOAD:-}" ]]                      && ARGS+=("--kv-offload" "$KV_OFFLOAD")
[[ -n "${OP_OFFLOAD:-}" ]]                      && ARGS+=("--op-offload" "$OP_OFFLOAD")
[[ -n "${FIT:-}" ]]                             && ARGS+=("--fit" "$FIT")
[[ -n "${FIT_TARGET:-}" ]]                      && ARGS+=("--fit-target" "$FIT_TARGET")
[[ -n "${FIT_CTX:-}" ]]                         && ARGS+=("--fit-ctx" "$FIT_CTX")
[[ -n "${OVERRIDE_TENSOR:-}" ]]                 && ARGS+=("--override-tensor" "$OVERRIDE_TENSOR")
[[ -n "${CPU_MOE:-}" ]]                         && ARGS+=("-cmoe" "$CPU_MOE")
[[ -n "${N_CPU_MOE:-}" ]]                       && ARGS+=("-ncmoe" "$N_CPU_MOE")
[[ -n "${NUMA:-}" ]]                            && ARGS+=("--numa" "$NUMA")
[[ -n "${MLOCK:-}" ]]                           && ARGS+=("--mlock" "")
[[ -n "${MMAP:-}" ]]                            && ARGS+=("--mmap" "$MMAP")
[[ -n "${DIRECT_IO:-}" ]]                       && ARGS+=("--direct-io" "$DIRECT_IO")

# --- KV cache ---
[[ -n "${CACHE_TYPE_K:-}" ]]                    && ARGS+=("-ctk" "$CACHE_TYPE_K")
[[ -n "${CACHE_TYPE_V:-}" ]]                    && ARGS+=("-ctv" "$CACHE_TYPE_V")
[[ -n "${CACHE_RAM:-}" ]]                       && ARGS+=("-cram" "$CACHE_RAM")
[[ -n "${DEFRAG_THOLD:-}" ]]                    && ARGS+=("-dt" "$DEFRAG_THOLD")

# --- Attention / context ---
[[ -n "${FLASH_ATTN:-}" ]]                      && ARGS+=("-fa" "$FLASH_ATTN")
[[ -n "${SWA_FULL:-}" ]]                        && ARGS+=("--swa-full" "$SWA_FULL")
[[ -n "${CONTEXT_SHIFT:-}" ]]                   && ARGS+=("--context-shift" "$CONTEXT_SHIFT")

# --- RoPE / scaling ---
[[ -n "${ROPE_SCALING:-}" ]]                    && ARGS+=("--rope-scaling" "$ROPE_SCALING")
[[ -n "${ROPE_SCALE:-}" ]]                      && ARGS+=("--rope-scale" "$ROPE_SCALE")
[[ -n "${ROPE_FREQ_BASE:-}" ]]                  && ARGS+=("--rope-freq-base" "$ROPE_FREQ_BASE")
[[ -n "${ROPE_FREQ_SCALE:-}" ]]                 && ARGS+=("--rope-freq-scale" "$ROPE_FREQ_SCALE")
[[ -n "${YARN_ORIG_CTX:-}" ]]                   && ARGS+=("--yarn-orig-ctx" "$YARN_ORIG_CTX")
[[ -n "${YARN_EXT_FACTOR:-}" ]]                 && ARGS+=("--yarn-ext-factor" "$YARN_EXT_FACTOR")
[[ -n "${YARN_ATTN_FACTOR:-}" ]]                && ARGS+=("--yarn-attn-factor" "$YARN_ATTN_FACTOR")
[[ -n "${YARN_BETA_SLOW:-}" ]]                  && ARGS+=("--yarn-beta-slow" "$YARN_BETA_SLOW")
[[ -n "${YARN_BETA_FAST:-}" ]]                  && ARGS+=("--yarn-beta-fast" "$YARN_BETA_FAST")

# --- Parallel decoding ---
[[ -n "${PARALLEL:-}" ]]                        && ARGS+=("-np" "$PARALLEL")

# --- Sampling ---
[[ -n "${TEMPERATURE:-}" ]]                     && ARGS+=("--temp" "$TEMPERATURE")
[[ -n "${TOP_K:-}" ]]                           && ARGS+=("--top-k" "$TOP_K")
[[ -n "${TOP_P:-}" ]]                           && ARGS+=("--top-p" "$TOP_P")
[[ -n "${MIN_P:-}" ]]                           && ARGS+=("--min-p" "$MIN_P")
[[ -n "${TOP_N_SIGMA:-}" ]]                     && ARGS+=("--top-n-sigma" "$TOP_N_SIGMA")
[[ -n "${XTC_PROBABILITY:-}" ]]                 && ARGS+=("--xtc-probability" "$XTC_PROBABILITY")
[[ -n "${XTC_THRESHOLD:-}" ]]                   && ARGS+=("--xtc-threshold" "$XTC_THRESHOLD")
[[ -n "${TYPICAL_P:-}" ]]                       && ARGS+=("--typical" "$TYPICAL_P")
[[ -n "${REPEAT_LAST_N:-}" ]]                   && ARGS+=("--repeat-last-n" "$REPEAT_LAST_N")
[[ -n "${REPEAT_PENALTY:-}" ]]                  && ARGS+=("--repeat-penalty" "$REPEAT_PENALTY")
[[ -n "${PRESENCE_PENALTY:-}" ]]                && ARGS+=("--presence-penalty" "$PRESENCE_PENALTY")
[[ -n "${FREQUENCY_PENALTY:-}" ]]               && ARGS+=("--frequency-penalty" "$FREQUENCY_PENALTY")
[[ -n "${DRY_MULTIPLIER:-}" ]]                  && ARGS+=("--dry-multiplier" "$DRY_MULTIPLIER")
[[ -n "${DRY_BASE:-}" ]]                        && ARGS+=("--dry-base" "$DRY_BASE")
[[ -n "${DRY_ALLOWED_LENGTH:-}" ]]              && ARGS+=("--dry-allowed-length" "$DRY_ALLOWED_LENGTH")
[[ -n "${DRY_PENALTY_LAST_N:-}" ]]              && ARGS+=("--dry-penalty-last-n" "$DRY_PENALTY_LAST_N")
[[ -n "${DRY_SEQUENCE_BREAKER:-}" ]]            && ARGS+=("--dry-sequence-breaker" "$DRY_SEQUENCE_BREAKER")
[[ -n "${ADAPTIVE_TARGET:-}" ]]                 && ARGS+=("--adaptive-target" "$ADAPTIVE_TARGET")
[[ -n "${ADAPTIVE_DECAY:-}" ]]                  && ARGS+=("--adaptive-decay" "$ADAPTIVE_DECAY")
[[ -n "${DYNA_TEMP_RANGE:-}" ]]                 && ARGS+=("--dynatemp-range" "$DYNA_TEMP_RANGE")
[[ -n "${DYNA_TEMP_EXP:-}" ]]                   && ARGS+=("--dynatemp-exp" "$DYNA_TEMP_EXP")
[[ -n "${MIROSTAT:-}" ]]                        && ARGS+=("--mirostat" "$MIROSTAT")
[[ -n "${MIROSTAT_LR:-}" ]]                     && ARGS+=("--mirostat-lr" "$MIROSTAT_LR")
[[ -n "${MIROSTAT_ENT:-}" ]]                    && ARGS+=("--mirostat-ent" "$MIROSTAT_ENT")
[[ -n "${SEED:-}" ]]                            && ARGS+=("-s" "$SEED")
[[ -n "${IGNORE_EOS:-}" ]]                      && ARGS+=("--ignore-eos" "$IGNORE_EOS")
[[ -n "${SAMPLERS:-}" ]]                        && ARGS+=("--samplers" "$SAMPLERS")
[[ -n "${SAMPLER_SEQ:-}" ]]                     && ARGS+=("--sampler-seq" "$SAMPLER_SEQ")
[[ -n "${GRAMMAR:-}" ]]                         && ARGS+=("--grammar" "$GRAMMAR")
[[ -n "${GRAMMAR_FILE:-}" ]]                    && ARGS+=("--grammar-file" "$GRAMMAR_FILE")
[[ -n "${JSON_SCHEMA:-}" ]]                     && ARGS+=("-j" "$JSON_SCHEMA")
[[ -n "${JSON_SCHEMA_FILE:-}" ]]                && ARGS+=("-jf" "$JSON_SCHEMA_FILE")
[[ -n "${LOGIT_BIAS:-}" ]]                      && ARGS+=("-l" "$LOGIT_BIAS")
[[ -n "${BACKEND_SAMPLING:-}" ]]                && ARGS+=("--backend-sampling" "$BACKEND_SAMPLING")

# --- Speculative decoding ---
[[ -n "${SPEC_DRAFT_MODEL:-}" ]]                && ARGS+=("--spec-draft-model" "$SPEC_DRAFT_MODEL")
[[ -n "${SPEC_DRAFT:-}" ]]                       && ARGS+=("--spec-draft-n-max" "$SPEC_DRAFT")
[[ -n "${SPEC_DRAFT_N_MIN:-}" ]]                 && ARGS+=("--spec-draft-n-min" "$SPEC_DRAFT_N_MIN")
[[ -n "${SPEC_DRAFT_P_SPLIT:-}" ]]              && ARGS+=("--spec-draft-p-split" "$SPEC_DRAFT_P_SPLIT")
[[ -n "${SPEC_DRAFT_P_MIN:-}" ]]                && ARGS+=("--spec-draft-p-min" "$SPEC_DRAFT_P_MIN")
[[ -n "${SPEC_DRAFT_THREADS:-}" ]]              && ARGS+=("--spec-draft-threads" "$SPEC_DRAFT_THREADS")
[[ -n "${SPEC_DRAFT_THREADS_BATCH:-}" ]]        && ARGS+=("--spec-draft-threads-batch" "$SPEC_DRAFT_THREADS_BATCH")
[[ -n "${SPEC_DRAFT_CPU_MASK:-}" ]]             && ARGS+=("--spec-draft-cpu-mask" "$SPEC_DRAFT_CPU_MASK")
[[ -n "${SPEC_DRAFT_CPU_RANGE:-}" ]]            && ARGS+=("--spec-draft-cpu-range" "$SPEC_DRAFT_CPU_RANGE")
[[ -n "${SPEC_DRAFT_CPU_STRICT:-}" ]]           && ARGS+=("--spec-draft-cpu-strict" "$SPEC_DRAFT_CPU_STRICT")
[[ -n "${SPEC_DRAFT_PRIO:-}" ]]                 && ARGS+=("--spec-draft-prio" "$SPEC_DRAFT_PRIO")
[[ -n "${SPEC_DRAFT_POLL:-}" ]]                 && ARGS+=("--spec-draft-poll" "$SPEC_DRAFT_POLL")
[[ -n "${SPEC_DRAFT_CACHE_TYPE_K:-}" ]]         && ARGS+=("--spec-draft-type-k" "$SPEC_DRAFT_CACHE_TYPE_K")
[[ -n "${SPEC_DRAFT_CACHE_TYPE_V:-}" ]]         && ARGS+=("--spec-draft-type-v" "$SPEC_DRAFT_CACHE_TYPE_V")
[[ -n "${SPEC_TYPE:-}" ]]                        && ARGS+=("--spec-type" "$SPEC_TYPE")
[[ -n "${SPEC_NGRAM_MOD_N_MIN:-}" ]]            && ARGS+=("--spec-ngram-mod-n-min" "$SPEC_NGRAM_MOD_N_MIN")
[[ -n "${SPEC_NGRAM_MOD_N_MAX:-}" ]]            && ARGS+=("--spec-ngram-mod-n-max" "$SPEC_NGRAM_MOD_N_MAX")
[[ -n "${SPEC_NGRAM_MOD_N_MATCH:-}" ]]          && ARGS+=("--spec-ngram-mod-n-match" "$SPEC_NGRAM_MOD_N_MATCH")
[[ -n "${SPEC_NGRAM_SIMPLE_SIZE_N:-}" ]]        && ARGS+=("--spec-ngram-simple-size-n" "$SPEC_NGRAM_SIMPLE_SIZE_N")
[[ -n "${SPEC_NGRAM_SIMPLE_SIZE_M:-}" ]]        && ARGS+=("--spec-ngram-simple-size-m" "$SPEC_NGRAM_SIMPLE_SIZE_M")
[[ -n "${SPEC_NGRAM_SIMPLE_MIN_HITS:-}" ]]      && ARGS+=("--spec-ngram-simple-min-hits" "$SPEC_NGRAM_SIMPLE_MIN_HITS")
[[ -n "${SPEC_NGRAM_MAP_K_SIZE_N:-}" ]]         && ARGS+=("--spec-ngram-map-k-size-n" "$SPEC_NGRAM_MAP_K_SIZE_N")
[[ -n "${SPEC_NGRAM_MAP_K_SIZE_M:-}" ]]         && ARGS+=("--spec-ngram-map-k-size-m" "$SPEC_NGRAM_MAP_K_SIZE_M")
[[ -n "${SPEC_NGRAM_MAP_K_MIN_HITS:-}" ]]       && ARGS+=("--spec-ngram-map-k-min-hits" "$SPEC_NGRAM_MAP_K_MIN_HITS")
[[ -n "${SPEC_NGRAM_MAP_K4V_SIZE_N:-}" ]]       && ARGS+=("--spec-ngram-map-k4v-size-n" "$SPEC_NGRAM_MAP_K4V_SIZE_N")
[[ -n "${SPEC_NGRAM_MAP_K4V_SIZE_M:-}" ]]       && ARGS+=("--spec-ngram-map-k4v-size-m" "$SPEC_NGRAM_MAP_K4V_SIZE_M")
[[ -n "${SPEC_NGRAM_MAP_K4V_MIN_HITS:-}" ]]     && ARGS+=("--spec-ngram-map-k4v-min-hits" "$SPEC_NGRAM_MAP_K4V_MIN_HITS")

# --- LoRA / control vectors ---
[[ -n "${LORA:-}" ]]                            && ARGS+=("--lora" "$LORA")
[[ -n "${LORA_SCALED:-}" ]]                     && ARGS+=("--lora-scaled" "$LORA_SCALED")
[[ -n "${CONTROL_VECTOR:-}" ]]                  && ARGS+=("--control-vector" "$CONTROL_VECTOR")
[[ -n "${CONTROL_VECTOR_SCALED:-}" ]]           && ARGS+=("--control-vector-scaled" "$CONTROL_VECTOR_SCALED")
[[ -n "${CONTROL_VECTOR_LAYER_RANGE:-}" ]]      && ARGS+=("--control-vector-layer-range" "$CONTROL_VECTOR_LAYER_RANGE")

# --- Check / override ---
[[ -n "${CHECK_TENSORS:-}" ]]                   && ARGS+=("--check-tensors" "$CHECK_TENSORS")
[[ -n "${OVERRIDE_KV:-}" ]]                     && ARGS+=("--override-kv" "$OVERRIDE_KV")

# --- Multimodal ---
[[ -n "$MMPOJ" ]]                               && ARGS+=("--mmproj" "$MMPOJ")
[[ -n "${MMPOJ_URL:-}" ]]                       && ARGS+=("--mmproj-url" "$MMPOJ_URL")
[[ -n "${MMPOJ_AUTO:-}" ]]                      && ARGS+=("--mmproj-auto" "$MMPOJ_AUTO")
[[ -n "${MMPOJ_OFFLOAD:-}" ]]                   && ARGS+=("--mmproj-offload" "$MMPOJ_OFFLOAD")
[[ -n "${IMAGE:-}" ]]                           && ARGS+=("--image" "$IMAGE")
[[ -n "${AUDIO:-}" ]]                           && ARGS+=("--audio" "$AUDIO")
[[ -n "${VIDEO:-}" ]]                           && ARGS+=("--video" "$VIDEO")
[[ -n "${IMAGE_MIN_TOKENS:-}" ]]                && ARGS+=("--image-min-tokens" "$IMAGE_MIN_TOKENS")
[[ -n "${IMAGE_MAX_TOKENS:-}" ]]                && ARGS+=("--image-max-tokens" "$IMAGE_MAX_TOKENS")

# --- Server ---
[[ -n "${PORT:-}" ]]                            && ARGS+=("--port" "$PORT")
[[ -n "${HOST:-}" ]]                            && ARGS+=("--host" "$HOST")
[[ -n "${API_KEY:-}" ]]                         && ARGS+=("--api-key" "$API_KEY")
[[ -n "${CORIS_BASE:-}" ]]                      && ARGS+=("--coris-base" "$CORIS_BASE")
[[ -n "${CORIS_MODEL:-}" ]]                     && ARGS+=("--coris-model" "$CORIS_MODEL")
[[ -n "${CORIS_EXTRA_PARAMS:-}" ]]              && ARGS+=("--coris-extra-params" "$CORIS_EXTRA_PARAMS")
[[ -n "${TOML_CONFIG_PATH:-}" ]]                && ARGS+=("--toml-config-path" "$TOML_CONFIG_PATH")
[[ -n "${GRPC_HOST:-}" ]]                       && ARGS+=("--grpc-host" "$GRPC_HOST")
[[ -n "${GRPC_PORT:-}" ]]                       && ARGS+=("--grpc-port" "$GRPC_PORT")
[[ -n "${GRPC_SSL_ENABLE:-}" ]]                 && ARGS+=("--grpc-ssl-enable" "$GRPC_SSL_ENABLE")
[[ -n "${GRPC_SSL_SERVER_NAME:-}" ]]            && ARGS+=("--grpc-ssl-server-name" "$GRPC_SSL_SERVER_NAME")
[[ -n "${GRPC_SSL_CERT_FILE:-}" ]]              && ARGS+=("--grpc-ssl-cert-file" "$GRPC_SSL_CERT_FILE")
[[ -n "${GRPC_SSL_KEY_FILE:-}" ]]               && ARGS+=("--grpc-ssl-key-file" "$GRPC_SSL_KEY_FILE")
[[ -n "${GRPC_SSL_CA_FILE:-}" ]]                && ARGS+=("--grpc-ssl-ca-file" "$GRPC_SSL_CA_FILE")
[[ -n "${GRPC_KEEPALIVE_ENABLED:-}" ]]          && ARGS+=("--grpc-keepalive-enabled" "$GRPC_KEEPALIVE_ENABLED")
[[ -n "${GRPC_KEEPALIVE_TIMEOUT:-}" ]]          && ARGS+=("--grpc-keepalive-timeout" "$GRPC_KEEPALIVE_TIMEOUT")
[[ -n "${GRPC_KEEPALIVE_TIMEOUT_NO_HB:-}" ]]    && ARGS+=("--grpc-keepalive-timeout-no-hb" "$GRPC_KEEPALIVE_TIMEOUT_NO_HB")
[[ -n "${GRPC_KEEPALIVE_TIME:-}" ]]             && ARGS+=("--grpc-keepalive-time" "$GRPC_KEEPALIVE_TIME")
[[ -n "${GRPC_MAX_SEND_MSG_SIZE:-}" ]]          && ARGS+=("--grpc-max-send-msg-size" "$GRPC_MAX_SEND_MSG_SIZE")
[[ -n "${GRPC_MAX_RECV_MSG_SIZE:-}" ]]          && ARGS+=("--grpc-max-recv-msg-size" "$GRPC_MAX_RECV_MSG_SIZE")

# --- Chat / prompt ---
[[ -n "${PROMPT:-}" ]]                          && ARGS+=("-p" "$PROMPT")
[[ -n "${SYSTEM_PROMPT:-}" ]]                   && ARGS+=("-sys" "$SYSTEM_PROMPT")
[[ -n "${SYSTEM_PROMPT_FILE:-}" ]]              && ARGS+=("-sysf" "$SYSTEM_PROMPT_FILE")
[[ -n "${FILE:-}" ]]                            && ARGS+=("-f" "$FILE")
[[ -n "${BINARY_FILE:-}" ]]                     && ARGS+=("-bf" "$BINARY_FILE")
[[ -n "${REVERSE_PROMPT:-}" ]]                  && ARGS+=("-r" "$REVERSE_PROMPT")
[[ -n "${CHAT_TEMPLATE:-}" ]]                   && ARGS+=("--chat-template" "$CHAT_TEMPLATE")
[[ -n "${CHAT_TEMPLATE_FILE:-}" ]]              && ARGS+=("--chat-template-file" "$CHAT_TEMPLATE_FILE")
[[ -n "${JINJA:-}" ]]                           && ARGS+=("--jinja" "$JINJA")
[[ -n "${SKIP_CHAT_PARSING:-}" ]]               && ARGS+=("--skip-chat-parsing" "$SKIP_CHAT_PARSING")
[[ -n "${CHAT_TEMPLATE_KWARGS:-}" ]]            && ARGS+=("--chat-template-kwargs" "$CHAT_TEMPLATE_KWARGS")
[[ -n "${REASONING:-}" ]]                       && ARGS+=("--reasoning" "$REASONING")
[[ -n "${REASONING_FORMAT:-}" ]]                && ARGS+=("--reasoning-format" "$REASONING_FORMAT")
[[ -n "${REASONING_BUDGET:-}" ]]                && ARGS+=("--reasoning-budget" "$REASONING_BUDGET")
[[ -n "${REASONING_BUDGET_MESSAGE:-}" ]]        && ARGS+=("--reasoning-budget-message" "$REASONING_BUDGET_MESSAGE")

# --- Output / display ---
[[ -n "${CONVERSATION:-}" ]]                    && ARGS+=("--conversation" "$CONVERSATION")
[[ -n "${SINGLE_TURN:-}" ]]                     && ARGS+=("--single-turn" "$SINGLE_TURN")
[[ -n "${MULTILINE_INPUT:-}" ]]                 && ARGS+=("--multiline-input" "$MULTILINE_INPUT")
[[ -n "${DISPLAY_PROMPT:-}" ]]                  && ARGS+=("--display-prompt" "$DISPLAY_PROMPT")
[[ -n "${COLOR:-}" ]]                           && ARGS+=("-co" "$COLOR")
[[ -n "${ESCAPE:-}" ]]                          && ARGS+=("-e" "$ESCAPE")
[[ -n "${SIMPLE_IO:-}" ]]                       && ARGS+=("--simple-io" "$SIMPLE_IO")
[[ -n "${SPECIAL:-}" ]]                         && ARGS+=("--special" "$SPECIAL")
[[ -n "${VERBOSE_PROMPT:-}" ]]                  && ARGS+=("--verbose-prompt" "$VERBOSE_PROMPT")
[[ -n "${WARMUP:-}" ]]                          && ARGS+=("--warmup" "$WARMUP")
[[ -n "${SHOW_TIMINGS:-}" ]]                    && ARGS+=("--show-timings" "$SHOW_TIMINGS")

# --- Logging ---
[[ -n "${LOG_DISABLE:-}" ]]                     && ARGS+=("--log-disable" "")
[[ -n "${LOG_FILE:-}" ]]                        && ARGS+=("--log-file" "$LOG_FILE")
[[ -n "${LOG_COLORS:-}" ]]                      && ARGS+=("--log-colors" "$LOG_COLORS")
[[ -n "${LOG_VERBOSITY:-}" ]]                   && ARGS+=("--verbosity" "$LOG_VERBOSITY")
[[ -n "${LOG_PREFIX:-}" ]]                      && ARGS+=("--log-prefix" "$LOG_PREFIX")
[[ -n "${LOG_TIMESTAMPS:-}" ]]                  && ARGS+=("--log-timestamps" "$LOG_TIMESTAMPS")
[[ -n "${VERBOSE:-}" ]]                         && ARGS+=("-v" "$VERBOSE")
[[ -n "${PERF:-}" ]]                            && ARGS+=("--perf" "$PERF")
[[ -n "${LOG_PROMPTS_DIR:-}" ]]                 && ARGS+=("--log-prompts-dir" "$LOG_PROMPTS_DIR")

# --- Cache ---
[[ -n "${CACHE_LIST:-}" ]]                      && ARGS+=("--cache-list" "$CACHE_LIST")
[[ -n "${COMPLETION_BASH:-}" ]]                 && ARGS+=("--completion-bash" "$COMPLETION_BASH")
[[ -n "${LIST_DEVICES:-}" ]]                    && ARGS+=("--list-devices" "$LIST_DEVICES")

# --- Presets ---
[[ -n "${GPT_OSS_20B_DEFAULT:-}" ]]             && ARGS+=("--gpt-oss-20b-default" "$GPT_OSS_20B_DEFAULT")
[[ -n "${GPT_OSS_120B_DEFAULT:-}" ]]            && ARGS+=("--gpt-oss-120b-default" "$GPT_OSS_120B_DEFAULT")
[[ -n "${VISION_GEMMA_4B_DEFAULT:-}" ]]         && ARGS+=("--vision-gemma-4b-default" "$VISION_GEMMA_4B_DEFAULT")
[[ -n "${VISION_GEMMA_12B_DEFAULT:-}" ]]        && ARGS+=("--vision-gemma-12b-default" "$VISION_GEMMA_12B_DEFAULT")
[[ -n "${SPEC_DEFAULT:-}" ]]                     && ARGS+=("--spec-default" "$SPEC_DEFAULT")

# --- Offline / other ---
[[ -n "${OFFLINE:-}" ]]                         && ARGS+=("--offline" "$OFFLINE")

# --- Version / help ---
[[ -n "${HELP:-}" ]]                            && ARGS+=("-h" "$HELP")
[[ -n "${VERSION:-}" ]]                         && ARGS+=("--version" "$VERSION")

# ─────────────────────────────────────────────────────────────────────
# 3. Extra passthrough — any unhandled flags
# ─────────────────────────────────────────────────────────────────────
if [[ -n "${LLAMA_EXTRA_ARGS:-}" ]]; then
    # shellcheck disable=SC2086
    ARGS+=($LLAMA_EXTRA_ARGS)
fi

# ─────────────────────────────────────────────────────────────────────
# 4. Print & exec
# ─────────────────────────────────────────────────────────────────────
echo ""
echo "=== llama-server command ==="
echo "llama-server ${ARGS[*]}"
echo "============================"
echo ""

# Set up Intel oneAPI environment if not already sourced
if [[ -z "${SYCL_DEVICE_INDEX:-}" ]]; then
    SYCL_DEVICE_INDEX="0"
fi

# If running inside Docker on Intel, wrap with SYCL launcher
if [[ -n "${SYCL_DEVICE_INDEX:-}" ]]; then
    export ZES_ENABLE_SYSMAN=1
    export ONEAPI_DEVICE_SELECTOR="level_zero:${SYCL_DEVICE_INDEX}"
    exec llama-server "${ARGS[@]}"
else
    exec llama-server "${ARGS[@]}"
fi
