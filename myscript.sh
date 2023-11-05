#!/bin/sh

current_dir="$(pwd)"

export PATTERN_IDS=("0 1")
export MODEL_TYPE="albert roberta"
export MODEL_NAME_OR_PATH="albert-base-v2 roberta-base"
export TASK="ar-en-sa"
export DATA_DIR="${current_dir}/data/ArEnSA/"
export OUTPUT_DIR="${current_dir}/output/"
