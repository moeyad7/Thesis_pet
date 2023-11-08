#!/bin/bash

# Define the input file and output CSV file
input_file="output/result_test.txt"
final_file="output/final/result_test.txt"
output_csv="results.csv"

# Extract the required lines from the input file
p_values=$(grep -E 'acc-p[0-9]+|f1-macro-p[0-9]+|precision-macro-p[0-9]+|recall-macro-p[0-9]+' "$input_file")
p_values_all=$(grep -E 'acc-all-p|f1-macro-all-p|precision-macro-all-p|recall-macro-all-p' "$input_file")

# Extract the required lines from the final file
final_values=$(grep -E 'acc-all-p|f1-macro-all-p|precision-macro-all-p|recall-macro-all-p' "$final_file")

# Initialize arrays to store the data
data=()

# Loop through the extracted lines and split them into arrays
while IFS= read -r line; do
    # Extract the metric and "p" value
    metric="${line%%-*}"
    p_value="${line%%:*}"
    p_value="${p_value##*-p}"

    # Store the data as "p" value, metric, and value
    data+=("$metric-$p_value,${line#*: }")
done <<< "$p_values"



# Add the "-all" values to the data array
while IFS= read -r line; do
    # Extract the metric and add "-all"
    metric="${line%%-*}"
    metric="$metric-all"

    # Store the data as "p" value, metric, and value
    data+=("$metric,${line#*: }")
done <<< "$p_values_all"


# Add the final values to the data array
while IFS= read -r line; do
    # Extract the metric and add "-all"
    metric="${line%%-*}"
    metric="final-$metric"

    # Store the data as "p" value, metric, and value
    data+=("$metric,${line#*: }")
done <<< "$final_values"


# Initialize an associative array to store the data
declare -A metric_data

for entry in "${data[@]}"; do
    metric=$(echo "$entry" | cut -d',' -f1)
    value=$(echo "$entry" | cut -d',' -f2)
#     # Store the value in the associative array
    metric_data["$metric"]=$value
done


declare -A combined_metrics

metric_name=()
pattern_number=()
pattern_value=()
# #Loop through the metric_data associative array and combine values for keys that end with "-[0-9]"
for key in "${!metric_data[@]}"; do
    value="${metric_data[$key]}"
    # Check if the key ends with "-[0-9]" using a regular expression
    if [[ "$key" =~ -[0-9]$ ]]; then
        metric="${key%-*}"
        number="${key##*-}"
        metric_name+=("$metric")
        pattern_number+=("$number")
        pattern_value+=("$value")
    else
        # If the key doesn't end with "-[0-9]", store the value as is
        combined_metrics["$key"]="$value"
    fi
done

# Initialize arrays to store combined values for ACC, recall, precision, and f1
combined_f1=()
combined_precision=()
combined_recall=()
combined_acc=()

# Combine every two consecutive values for ACC, recall, precision, and f1
for ((i = 0; i < ${#metric_name[@]}; i += 1)); do
    if [ "${metric_name[i]}" == "acc" ]; then
        combined_acc+=("${metric_name[i]}-${pattern_number[i]}: ${pattern_value[i]} ")
    elif [ "${metric_name[i]}" == "recall" ]; then
        combined_recall+=("${metric_name[i]}-${pattern_number[i]}: ${pattern_value[i]} ")
    elif [ "${metric_name[i]}" == "precision" ]; then
        combined_precision+=("${metric_name[i]}-${pattern_number[i]}: ${pattern_value[i]} ")
    elif [ "${metric_name[i]}" == "f1" ]; then
        combined_f1+=("${metric_name[i]}-${pattern_number[i]}: ${pattern_value[i]} ")
    fi
done


# Create the header for the CSV file
header="f1-p,precision-p,recall-p,acc-p,f1-all,precision-all,recall-all,acc-all,final-f1,final-precision,final-recall,final-acc"

# Create the CSV file with the specified format
if [ ! -f "$output_csv" ]; then
  # If it doesn't exist, create the file with the header
  echo "$header" > "$output_csv"
fi

echo "\"${combined_f1[@]}\",\"${combined_precision[@]}\",\"${combined_recall[@]}\",\"${combined_acc[@]}\",\"${combined_metrics["f1-all"]}\",\"${combined_metrics["precision-all"]}\",\"${combined_metrics["recall-all"]}\",\"${combined_metrics["acc-all"]}\",\"${combined_metrics["final-f1"]}\",\"${combined_metrics["final-precision"]}\",\"${combined_metrics["final-recall"]}\",\"${combined_metrics["final-acc"]}\"" >> "$output_csv"

echo "Results saved to $output_csv"

echo ${combined_metrics["final-acc"]}