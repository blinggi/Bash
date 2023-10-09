#!/bin/bash

processed_sets=()

for i in $(find ./ -type f -name "*.fastq.gz" | while read F; do basename $F | grep -o '^[^_]*' | sort | uniq; done | sort -n)
do
    if [[ ! " ${processed_sets[@]} " =~ " $i " ]]; then
        echo "Processing set: $i"
        processed_sets+=($i)

        R1_files=("$i"_*R1*.fastq.gz)
        R2_files=("$i"_*R2*.fastq.gz)

        echo -e "Input files for R1:\n${R1_files[@]}"

        echo "Line count before merging R1:"
        line_count_before_r1_total=0
        for file in "${R1_files[@]}"; do
            line_count=$(zcat "$file" | wc -l)
            echo "$file: $line_count"
            line_count_before_r1_total=$((line_count_before_r1_total + line_count))
        done
        echo "Total line count before merging R1: $line_count_before_r1_total"

        merged_r1_file="$i"_ME_R1.fastq.gz

        echo "Merging R1"
        cat "${R1_files[@]}" > "$merged_r1_file"

        echo "Output file for merged R1: $merged_r1_file"

        echo "Line count after merging R1:"
        line_count_after_r1=$(zcat "$merged_r1_file" | wc -l)
        echo "$line_count_after_r1"

        echo -e "Input files for R2:\n${R2_files[@]}"

        echo "Line count before merging R2:"
        line_count_before_r2_total=0
        for file in "${R2_files[@]}"; do
            line_count=$(zcat "$file" | wc -l)
            echo "$file: $line_count"
            line_count_before_r2_total=$((line_count_before_r2_total + line_count))
        done
        echo "Total line count before merging R2: $line_count_before_r2_total"

        merged_r2_file="$i"_ME_R2.fastq.gz

        echo "Merging R2"
        cat "${R2_files[@]}" > "$merged_r2_file"

        echo "Output file for merged R2: $merged_r2_file"

        echo "Line count after merging R2:"
        line_count_after_r2=$(zcat "$merged_r2_file" | wc -l)
        echo "$line_count_after_r2"

        echo "Checking if line counts are equal"
        if ((line_count_after_r1 != line_count_before_r1_total || line_count_after_r2 != line_count_before_r2_total)); then
            echo "Error: Line counts after merging do not equal the sum of individual line counts"
            exit 1
        fi

        echo "------------------------"
    fi
done;
