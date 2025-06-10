#!/bin/bash

INPUT_FILE="$1"
OUTPUT_FILE="$1.csv"
TEMP_FILE="temp_metrics.csv"

# Extract all unique metric keys from the first block
awk '
  BEGIN { FS=": "; inside=0 }
  /^Run results:/ { inside=1; next }
  /^$/ { if (inside) exit }
  inside && NF==2 { print $1 }
' "$INPUT_FILE" | sort >keys.txt

# Create header row
paste -sd',' keys.txt >"$OUTPUT_FILE"

# Process each run block
awk -v header="$(paste -sd',' keys.txt)" '
  BEGIN {
    FS=": "
    split(header, keys, ",")
    run_line = ""
  }
  /^Run results:/ {
    if (run_line != "") print run_line >> "temp_metrics.csv"
    delete metrics
    next
  }
  /^[[:space:]]*$/ {
    next
  }
  NF == 2 {
    metrics[$1] = $2
  }
  END {
    if (length(metrics) > 0) {
      run_line = ""
      for (i = 1; i <= length(keys); i++) {
        run_line = run_line (i == 1 ? "" : ",") metrics[keys[i]]
      }
      print run_line >> "temp_metrics.csv"
    }
  }
  {
    run_line = ""
    for (i = 1; i <= length(keys); i++) {
      run_line = run_line (i == 1 ? "" : ",") metrics[keys[i]]
    }
  }
' "$INPUT_FILE"

# Append rows to final CSV
cat temp_metrics.csv >>"$OUTPUT_FILE"

# Clean up
rm keys.txt temp_metrics.csv

echo "✅ CSV created as $OUTPUT_FILE"
