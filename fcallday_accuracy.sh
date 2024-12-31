#! /bin/bash

# Initialize the historical forecast accuracy report file
output_file="historical_fc_accuracy.tsv"
echo -e "Year\tMonth\tDay\tActual_Temp\tForecast_Temp\tAccuracy\tAccuracy_Range" > $output_file

# Read the log file and process consecutive pairs of lines
prev_line=""
while read -r current_line; do
    if [ -n "$prev_line" ]; then
        # Extract yesterday's forecast and today's temperature
        yesterday_fc=$(echo "$prev_line" | cut -d " " -f5)
        today_temp=$(echo "$current_line" | cut -d " " -f4)

        # Calculate accuracy
        accuracy=$(($yesterday_fc - $today_temp))

        # Determine accuracy range
        if [ -1 -le $accuracy ] && [ $accuracy -le 1 ]; then
            accuracy_range="excellent"
        elif [ -2 -le $accuracy ] && [ $accuracy -le 2 ]; then
            accuracy_range="good"
        elif [ -3 -le $accuracy ] && [ $accuracy -le 3 ]; then
            accuracy_range="fair"
        else
            accuracy_range="poor"
        fi

        # Extract date information from the current line
        year=$(echo "$current_line" | cut -d " " -f1)
        month=$(echo "$current_line" | cut -d " " -f2)
        day=$(echo "$current_line" | cut -d " " -f3)

        # Append results to the output file
        echo -e "$year\t$month\t$day\t$today_temp\t$yesterday_fc\t$accuracy\t$accuracy_range" >> $output_file
    fi

    # Update the previous line
    prev_line="$current_line"
done < rx_poc.log

echo "Historical forecast accuracy report generated: $output_file"
