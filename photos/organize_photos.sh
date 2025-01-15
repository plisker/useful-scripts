#!/bin/bash

#######
#
# This script organizes all files (ideally photos) in a directory
# into date directories by the file's creation date.
# 
# If there is a sidecar XMP file, it moves the XMP along with the
# original photo
#
#######

# Use the current directory where the script is run
SOURCE_DIR=$(pwd)

# Function to get the creation date of a file
get_creation_date() {
    # Get the creation date in "Year-Month Day" format
    creation_date=$(stat -f "%SB" -t "%Y-%m-%d" "$1")
    echo "$creation_date"
}

# Function to format the date into "YYYY-M Month" format
format_date() {
    # Extract year, month, and day
    year=$(date -j -f "%Y-%m-%d" "$1" +"%Y")
    month=$(date -j -f "%Y-%m-%d" "$1" +"%-m")
    month_name=$(date -j -f "%Y-%m-%d" "$1" +"%B")
    
    # Return formatted string
    echo "$year-$month $month_name"
}

# Loop through all photo files (ignoring .xmp files in the initial loop)
for photo_file in "$SOURCE_DIR"/*.*; do
    if [[ "$photo_file" == *.xmp ]]; then
        continue
    fi

    # Get the base file name (without extension)
    base_name="${photo_file%.*}"

    # Check if the corresponding XMP file exists
    xmp_file="$base_name.xmp"

    # Get the creation date of the photo file
    photo_creation_date=$(get_creation_date "$photo_file")

    # Format the date into "YYYY-M Month"
    folder_name=$(format_date "$photo_creation_date")

    # Create the destination folder if it doesn't exist
    dest_folder="$SOURCE_DIR/$folder_name"
    mkdir -p "$dest_folder"

    # Move both the photo and the XMP file (if it exists) to the new folder
    echo "Moving $photo_file to $dest_folder"
    mv "$photo_file" "$dest_folder/"

    if [[ -f "$xmp_file" ]]; then
        echo "Moving $xmp_file to $dest_folder"
        mv "$xmp_file" "$dest_folder/"
    fi
done

