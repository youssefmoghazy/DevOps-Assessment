#!/bin/bash

# Check that there are exactly two arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: backup <source_directory> <destination_directory>"
    exit 2
fi

SOURCE_INPUT="$1"
DESTINATION_INPUT="$2"


# Check that the source directory exists
if [ ! -d "$SOURCE_INPUT" ]; then
    echo "Error: Source directory does not exist: $SOURCE_INPUT"
    exit 1
fi


# Create destination directory if it does not exist
mkdir -p "$DESTINATION_INPUT" || { echo "Error: cannot create destination directory: $DESTINATION_INPUT" >&2; exit 1; }

# Convert paths to absolute paths
SOURCE="$(realpath "$SOURCE_INPUT")"
DESTINATION="$(realpath "$DESTINATION_INPUT")"
TIMESTAMP="$(date '+%Y%m%d_%H%M%S')"
SOURCE_NAME="$(basename "$SOURCE")"
ARCHIVE="$DESTINATION/${SOURCE_NAME}_${TIMESTAMP}.tar.gz"

# echo "$ARCHIVE"
#echo "$SOURCE_INPUT"echo "$SOURCE"
#echo "$SOURCE_NAME"

exec 3>"$DESTINATION/.backup.lock"

if ! flock -n 3; then
    echo "Error: Another backup is already running."
    exit 1
fi

tar -czf "$ARCHIVE" \
    -C "$(dirname "$SOURCE")" \
    "$SOURCE_NAME"


mapfile -t BACKUPS < <(
    find "$DESTINATION" \
        -maxdepth 1 \
        -type f \
        -name "${SOURCE_NAME}_*.tar.gz" \
        -printf '%T@ %p\n' |
    sort -nr |
    cut -d' ' -f2-
)

if (( ${#BACKUPS[@]} > 5 )); then
    for (( i=5; i<${#BACKUPS[@]}; i++ )); do
        rm -f "${BACKUPS[$i]}"
    done
fi


