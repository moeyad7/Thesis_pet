#!/bin/bash

# Specify the target directory where you want to delete files and directories
target_dir="$(pwd)/output"

# Specify the file names you want to delete
file_names=("eval_logits.txt" "logits.txt" "predictions.jsonl" "pytorch_model.bin" "spiece.model" "unlabeled_logits.txt")

# Loop through each file name and delete matching files in the target directory and its subdirectories
for file_name in "${file_names[@]}"; do
    find "$target_dir" -type f -name "$file_name" -delete
done

# Delete directories named "next-gen-train-data" in the target directory and its subdirectories
find "$target_dir" -type d -name "next-gen-train-data" -exec rm -r {} \;

echo "Deletion complete."
