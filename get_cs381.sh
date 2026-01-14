#!/bin/bash

# add new line to separate from previous day
echo ""

# Get timestamp prefix
timestamp() {
  echo -n "[$(date '+%Y-%m-%d %H:%M:%S')]"
}

# Variables
filename="cs381-textbook.pdf"
url="https://kentq.s3.amazonaws.com/fas26.pdf"
target_dir=~/Documents/university/4_year/2_semester/TA-cs381/

# Change to Downloads directory
cd ~/Downloads 2>/dev/null
if [ $? -ne 0 ]; then
  echo "$(timestamp) Failed to change to ~/Downloads directory." >&2
  exit 1
else
  echo "$(timestamp) Successfully changed to ~/Downloads directory."
fi

# Download the PDF
curl -L -o "$filename" "$url"
if [ $? -ne 0 ]; then
  echo "$(timestamp) Download failed during curl operation." >&2
  exit 1
else
  echo "$(timestamp) Download completed successfully with curl."
fi

# Check if the file was downloaded
if [ -f "$filename" ]; then
    # Check if target directory exists
  if [ ! -d "$target_dir" ]; then
    echo "$(timestamp) Error: Target directory does not exist: $target_dir" >&2
    exit 1
  else
    echo "$(timestamp) Target directory exists: $target_dir"
  fi
  
  # Move the file
  mv "$filename" "$target_dir"
  if [ $? -ne 0 ]; then
    echo "$(timestamp) Failed to move $filename to $target_dir" >&2
    exit 1
  else
    echo "$(timestamp) Successfully moved $filename to $target_dir"
  fi
else
  echo "$(timestamp) Download failed: $filename not found" >&2
  exit 1
fi

echo "$(timestamp) Script completed successfully."

