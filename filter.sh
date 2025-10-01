# Usage: ./filter_all.sh /path/to/folder

dir="$1"

if [[ -z "$dir" ]]; then
    echo "Usage: $0 /path/to/folder"
    exit 1
fi

for file in "$dir"/*/*; do
    if [[ -f "$file" ]]; then
        echo "Filtering $file ..."
        grep -E '"name":.*\.(i|r|g)\..*\.unconv\.exp[^w]' "$file" > "${file}.tmp"
        mv "${file}.tmp" "$file"
    fi
done