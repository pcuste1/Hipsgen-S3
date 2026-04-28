#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<EOF
Usage: $0 <directory> <regex> <output-file>

Finds all regular files under <directory> and writes the paths
of files whose path matches <regex> (extended regex) to <output-file>,
one path per line.

Example:
    $0 ./mydir "\\.log$" matched_files.txt
EOF
    exit 2
}

if [ "$#" -ne 3 ]; then
    usage
fi

DIR="$1"
REGEX="$2"
OUTFILE="$3"

if [ ! -d "$DIR" ]; then
    echo "Error: '$DIR' is not a directory" >&2
    exit 1
fi

# Truncate/create output file
: > "$OUTFILE"

# Recursively walk the directory tree without using find.
# Uses bash glob patterns to iterate files and directories.
walk_dir() {
  local path="$1"
  local file
  
  # Iterate over items in the current directory
  for item in "$path"/*; do
    # Skip if glob didn't expand (no matches)
    [ -e "$item" ] || continue
    
    # If it's a regular file, test against regex
    if [ -f "$item" ]; then
      if [[ "$item" =~ $REGEX ]]; then
        printf '%s\n' "$item" >> "$OUTFILE"
      fi
    # If it's a directory, recurse
    elif [ -d "$item" ]; then
      walk_dir "$item"
    fi
  done
}

walk_dir "$DIR"

echo "Wrote matching file paths to: $OUTFILE"