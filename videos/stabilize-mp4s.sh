#!/bin/bash

#######
#
# This script stabilizes MP4 videos with ffmpeg.
# 
# There are fundamentally two steps:
#   1. Create the TRF file (motion data file)
#   2. Use the TRF file to stabilize the video and generate output
#
#######

# Loop through all .mp4 files in the current directory
for file in *.mp4; do
  # Skip files that already end with "-stable.mp4"
  if [[ "$file" != *"-stable.mp4" ]]; then
    base=$(basename "$file" .mp4)
    trf_file="${base}_transforms.trf"
    output_file="${base}-stable.mp4"
    
    # Check if the .trf file exists
    if [[ ! -f "$trf_file" ]]; then
      # If the .trf file doesn't exist, generate it
      echo "Generating transformation file for $file..."
      ffmpeg -i "$file" -vf vidstabdetect=shakiness=10:accuracy=15:result="$trf_file" -f null -
    else
      # If the .trf file exists, skip generating it
      echo "$trf_file already exists, skipping generation..."
    fi
    
    # Check if the stable output file already exists
    if [[ ! -f "$output_file" ]]; then
      # Now stabilize the video using the .trf file if it exists
      if [[ -f "$trf_file" ]]; then
        echo "Stabilizing $file using $trf_file..."
        ffmpeg -i "$file" -vf vidstabtransform=smoothing=30:interpol=1:optzoom=1:input="$trf_file" "$output_file"
      fi
    else
      echo "$output_file already exists, skipping stabilization..."
    fi
  fi
done

