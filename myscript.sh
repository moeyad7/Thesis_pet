#!/bin/sh

export PATTERN_IDS=("4")
export DATA_DIR="/Users/mohamedeyad/Documents/Thesis_Workspace/pet/data/ArEnSA/"
export MODEL_TYPE="roberta"
export MODEL_NAME_OR_PATH="roberta-base"
export TASK="ar-en-sa"
export OUTPUT_DIR="/Users/mohamedeyad/Documents/Thesis_Workspace/pet/output/"


python cli.py \
--method pet \
--pattern_ids $PATTERN_IDS \
--data_dir $DATA_DIR \
--model_type $MODEL_TYPE \
--model_name_or_path $MODEL_NAME_OR_PATH \
--task_name $TASK \
--output_dir $OUTPUT_DIR \
--do_train \
--do_eval \
--train_examples 10 \
--unlabeled_examples 2000 \
--split_examples_evenly \
--lm_training