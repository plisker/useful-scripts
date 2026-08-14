#!/bin/bash

#######
#
# This script stabilizes MP4 and MOV videos with ffmpeg.
# 
# There are fundamentally two steps:
#   1. Create the TRF file (motion data file)
#   2. Use the TRF file to stabilize the video and generate output
#
#######

# Exit cleanly on Ctrl-C
trap "echo -e '\nInterrupted. Exiting...'; exit 1" SIGINT

shopt -s nullglob

# Loop through all .mp4, .mov, and .MOV files in the current directory
for file in *.mp4 *.mov *.MOV; do
  # Skip files that already end with "-stable.<ext>"
  if [[ "$file" != *"-stable."* ]]; then
    ext="${file##*.}"  # Get file extension
    base="${file%.*}"  # Get filename without extension
    trf_file="${base}_transforms.trf"
    output_file="${base}-stable.${ext}"

    # Check if the .trf file exists
    if [[ ! -f "$trf_file" ]]; then
      echo "Generating transformation file for $file..."
      ffmpeg -i "$file" -vf vidstabdetect=shakiness=10:accuracy=15:result="$trf_file" -f null -
    else
      echo "$trf_file already exists, skipping generation..."
    fi

    # Check if the stabilized output already exists
    if [[ ! -f "$output_file" ]]; then
      if [[ -f "$trf_file" ]]; then
        echo "Stabilizing $file using $trf_file..."
        ffmpeg -i "$file" -vf vidstabtransform=smoothing=30:interpol=1:optzoom=1:input="$trf_file" -pix_fmt yuv420p "$output_file"
      fi
    else
      echo "$output_file already exists, skipping stabilization..."
    fi
  fi
done
