#!/bin/sh

current_dir="$(pwd)"

export PATTERN_IDS=("0 1 2")
export MODEL_TYPE=("kermit")
export MODEL_NAME_OR_PATH=("../../kermit")
export TASK="ar-en-sa"
export DATA_DIR="${current_dir}/data/ArEnSA/"
export OUTPUT_DIR="${current_dir}/output/"
