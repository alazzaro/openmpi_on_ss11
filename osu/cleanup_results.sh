#!/bin/bash

# This script removes log garbage from OSU output files saved by the slurm batch jobs.
# Apart from the OSU output there are some othe lines (gpu binding logs) that should be removed.

for file in *.txt; do
  if [[ -f "$file" ]]; then
    sed -n '/^# /,$p' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
    echo "Processed: $file"
  fi
done
