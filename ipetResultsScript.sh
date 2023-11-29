#!/bin/bash

# Define the input file and output CSV file
input_directory="output/"
final_file="output/final/result_test.txt"
output_csv="results.csv"

f1_p=""
precision_p=""
recall_p=""
acc_p=""

f1_all=""
precision_all=""
recall_all=""
acc_all=""

final_f1=""
final_precision=""
final_recall=""
final_acc=""

# Iterate through directories inside the input directory
for dir in "$input_directory"g*/; do

  # Extract the generation number from the directory name
  generation_number=$(basename "$dir" | sed 's/g//')

  # Check if the directory contains a result_test.txt file
  if [ -f "$dir/result_test.txt" ]; then

    # Extract the required lines from the input file
    p_values=$(grep -E 'acc-p[0-9]+|f1-macro-p[0-9]+|precision-macro-p[0-9]+|recall-macro-p[0-9]+' "$dir/result_test.txt")
    p_values_all=$(grep -E 'acc-all-p|f1-macro-all-p|precision-macro-all-p|recall-macro-all-p' "$dir/result_test.txt")

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
    

    # Add the values to the variables
    f1_p+="g$generation_number: ${combined_f1[*]} "
    precision_p+="g$generation_number: ${combined_precision[*]} "
    recall_p+="g$generation_number: ${combined_recall[*]} "
    acc_p+="g$generation_number: ${combined_acc[*]} "

    f1_all+="g$generation_number: ${combined_metrics["f1-all"]} "
    precision_all+="g$generation_number: ${combined_metrics["precision-all"]} "
    recall_all+="g$generation_number: ${combined_metrics["recall-all"]} "
    acc_all+="g$generation_number: ${combined_metrics["acc-all"]} "

    # Unset all the variables
    unset data
    unset metric_data
    unset combined_metrics
    unset metric_name
    unset pattern_number
    unset pattern_value
    unset combined_f1
    unset combined_precision
    unset combined_recall
    unset combined_acc

    fi
done

# Extract the required lines from the final file
final_values=$(grep -E 'acc-all-p|f1-macro-all-p|precision-macro-all-p|recall-macro-all-p' "$final_file")

# Initialize arrays to store the data
data=()

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

final_acc=${metric_data["final-acc"]}
final_f1=${metric_data["final-f1"]}
final_precision=${metric_data["final-precision"]}
final_recall=${metric_data["final-recall"]}
final_acc=${metric_data["final-acc"]}


# Create the header for the CSV file
header="f1-p,precision-p,recall-p,acc-p,f1-all,precision-all,recall-all,acc-all,final-f1,final-precision,final-recall,final-acc"

# Initialize the output CSV file with the header
if [ ! -f "$output_csv" ]; then
  echo "$header" > "$output_csv"
fi

# Append the values to the output CSV file
echo "$f1_p,$precision_p,$recall_p,$acc_p,$f1_all,$precision_all,$recall_all,$acc_all,$final_f1,$final_precision,$final_recall,$final_acc" >> "$output_csv"

echo "Results saved to $output_csv"
