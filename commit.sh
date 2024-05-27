#!/bin/bash

# Define variables
csv_file="p1bugs.csv"
branch_name=$(git rev-parse --abbrev-ref HEAD)
current_time=$(date +"%Y%m%d%H%M%S")

# Check if the CSV file exists
if [ ! -f "$csv_file" ]; then
    echo "CSV file not found!"
    exit 1
fi

# Extract data from the CSV file for the current branch
IFS=',' read -r _ _ dev_name _ description bug_id < <(awk -F',' -v branch="$branch_name" '$4 == branch { print $0 }' $csv_file)

if [ -z "$bug_id" ]; then
    echo "No matching branch found in CSV file!"
    exit 1
fi

priority=$(awk -F',' -v branch="$branch_name" '$4 == branch { print $2 }' $csv_file)

# Generate the commit message
commit_message="${bug_id}:${current_time}:${branch_name}:${dev_name}:${priority}:${description}"

# Check for an additional developer description
if [ -n "$1" ]; then
    commit_message="${commit_message}:$1"
fi

# Perform git operations
git add .
git commit -m "$commit_message"

if git push origin "$branch_name"; then
    echo "Push successful!"
else
    echo "Push failed!"
    exit 1
fi
