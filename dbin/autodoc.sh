#!/bin/bash

# Auto documentation of shell CLI program
# Anthony Destefano 8/14/2024 11:39 PM

# ------------------------------------------------------------
# Given a shell script as the only argument
# this script will perform static analysis on the shell script
# and exract elif conditonal statement values
# and the associated comments
# display them in a list of commands with descriptions
# NOTE: this file is used by d.sh to self document the possible commands
# to use this script correctly,  your shell script should have a long list of

# example commands like this:
# "# using current directory find any d files recursevely.  $1: optional path instead"
# "elif [ "$CMD" == "which" ] || [ "$CMD" == "inspect" ]; then"

# in the above two linse the command 'which' and 'inspect' will envoke the same action
# the comment describes the outcome and arguments associated to this condition

# this script will extract the comment, and both strings to be printed out as:
# "which","inspect"          - using current directory find any d files recursevely.  $1: optional path instead


# ------------------------------------------------------------

# Check if a file is passed as an argument
if [ -z "$1" ]; then
    echo "Please provide a .sh file as an argument."
    exit 1
fi

# Initialize an empty array to hold the extracted strings
extracted_strings=()
last_comment=""

# Read the .sh file line by line
while IFS= read -r line; do
    # Check if the line is a comment
    if [[ "$line" =~ ^# ]]; then
        # Store the comment after stripping the leading "#"
        last_comment=$(echo "$line" | sed 's/^# *//')
    elif [[ "$line" =~ ^elif ]]; then
        # Extract the content within quotes using grep and regex, then filter out "$CMD"
        quoted_strings=$(echo "$line" | grep -oE '"[^"]*"' | grep -v '"\$CMD"')

        # Replace spaces and line breaks with commas when "||" is found
        if [[ "$line" =~ \|\| ]]; then
            comma_separated=$(echo "$quoted_strings" | paste -sd, -)
            extracted_strings+=("$comma_separated - $last_comment")
        else
            # If no "||" is found, just add the single string with the comment
            extracted_strings+=("$quoted_strings - $last_comment")
        fi

        # Reset the last comment after processing
        last_comment=""
    fi
done < "$1"

# sets YYYYMMDD
formatted_date=$(date +'%m/%d/%Y-%H:%M')
SAVE_FILE="d_help.txt"
rm $SAVE_FILE
# Print the extracted strings with comments formatted into columns
#echo "Extracted conditions with comments:"
echo "Documenation auto generated on $formatted_date" >> $SAVE_FILE
echo "-----------------------------------------------------" >> $SAVE_FILE
echo " > Hello, I am Docker Helper 'd' v${2}" >> $SAVE_FILE
echo " > My commands are:" >> $SAVE_FILE
printf "%-30s %-50s\n" "Command(s)" "Description" >> $SAVE_FILE
printf "%-30s %-50s\n" "----------" "-----------" >> $SAVE_FILE
for string in "${extracted_strings[@]}"; do
    # Split the string into command and comment
    command=$(echo "$string" | cut -d'-' -f1 | sed 's/ *$//' | sed "s/\"//g")
    comment=$(echo "$string" | cut -d'-' -f2- | sed 's/^ *//')

    # Print formatted columns
    printf "%-30s %-50s\n" "$command" "$comment" >> $SAVE_FILE
done
