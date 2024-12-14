#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <zipfile>"
    exit 1
fi

zipfile="$1"
dbname="${zipfile%.zip}.db"

# Check if the ZIP file exists
if [ ! -f "$zipfile" ]; then
    echo "Error: File '$zipfile' does not exist."
    exit 1
fi

# Find the first CSV file in the ZIP
csvfile=$(unzip -Z1 "$zipfile" | grep -i '\.csv$' | head -n 1)

if [ -z "$csvfile" ]; then
    echo "Error: No CSV file found in '$zipfile'."
    exit 1
fi

echo "Found CSV file: $csvfile"
echo "Extracting and importing into SQLite database: $dbname"

# Extract CSV to a temporary file
tmpfile=$(mktemp)
unzip -p "$zipfile" "$csvfile" > "$tmpfile"

# Redirect only stderr to a temporary file
error_log=$(mktemp)

# Import the CSV from the temporary file
#sqlite3 "$dbname" <<SQL 
sqlite3 "$dbname" 2>"$error_log" <<SQL 
.mode csv
.nullvalue NULL
.import $tmpfile observations
SQL

# Filter specific warnings from the error log
grep -v "filling the rest with NULL" "$error_log" >&2
rm -f "$error_log"

# Clean up the temporary file
rm -f "$tmpfile"

echo "SQLite database created: $dbname"

