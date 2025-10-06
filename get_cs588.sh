#!/bin/bash

# add new line to separate from previous day
echo ""

# Get timestamp prefix
timestamp() {
    echo -n "[$(date '+%Y-%m-%d %H:%M:%S')]"
}

# Change to Downloads directory
cd ~/Downloads 2>/dev/null
if [ $? -ne 0 ]; then
    echo "$(timestamp) Failed to change to ~/Downloads directory." >&2
    exit 1
else
    echo "$(timestamp) Successfully changed to ~/Downloads directory."
fi

# Download the PDF
curl -L -o cs588-textbook.pdf https://kentq.s3.us-east-1.amazonaws.com/raf25.pdf
if [ $? -ne 0 ]; then
    echo "$(timestamp) Download failed during curl operation." >&2
    exit 1
else
    echo "$(timestamp) Download completed successfully with curl."
fi

# Check if the file was downloaded
if [ -f cs588-textbook.pdf ]; then
    target_dir=~/Documents/university/4_year/1_semester/cs588/

    # Check if target directory exists
    if [ ! -d "$target_dir" ]; then
        echo "$(timestamp) Error: Target directory does not exist: $target_dir" >&2
        exit 1
    else
        echo "$(timestamp) Target directory exists: $target_dir"
    fi
    
    # Move the file
    mv cs588-textbook.pdf "$target_dir"
    if [ $? -ne 0 ]; then
        echo "$(timestamp) Failed to move cs588-textbook.pdf to $target_dir" >&2
        exit 1
    else
        echo "$(timestamp) Successfully moved cs588-textbook.pdf to $target_dir"
    fi
else
    echo "$(timestamp) Download failed: cs588-textbook.pdf not found" >&2
    exit 1
fi

echo "$(timestamp) Script completed successfully."

