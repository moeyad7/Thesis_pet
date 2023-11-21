#!/bin/sh

current_dir="$(pwd)"

export PATTERN_IDS=("0 1 2")
export MODEL_TYPE=("arabert")
export MODEL_NAME_OR_PATH=("aubmindlab/bert-base-arabertv02")
export TASK="ar-ner-corp"
export DATA_DIR="${current_dir}/data/ANERcorp/"
export OUTPUT_DIR="${current_dir}/output/"
