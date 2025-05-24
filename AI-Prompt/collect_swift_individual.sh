#!/bin/bash
# This script creates a folder named "swift_files_for_AI", copies all .swift files
# (from the current folder and all subfolders) into this folder and places a second script there.
# The second script (select_swift.sh) allows you to select the files stored there,
# merge their content and copy it to the clipboard (macOS).
# Afterwards, the script changes to the folder and starts a new shell, so you stay there.

# Define target folder
TARGET_DIR="swift_files_for_AI"

# Create the target folder if it doesn't exist yet
mkdir -p "$TARGET_DIR"

# Find and copy all .swift files (replace "cp" with "mv" if you want to move the files)
find . -type f -name "*.swift" | while read -r file; do
    # Remove leading "./" from the path
    file_clean=$(echo "$file" | sed 's|^\./||')
    # Replace "/" with "_" to create a unique filename
    safe_name=$(echo "$file_clean" | tr '/' '_')
    # Copy file to target folder
    cp "$file" "$TARGET_DIR/$safe_name"
done

echo "All Swift files have been copied to the folder '$TARGET_DIR'."

# Create the selection script in the target folder
cat << 'EOF' > "$TARGET_DIR/select_swift.sh"
#!/bin/bash
# This script lists all .swift files in the current folder (the "swift_files_for_AI" folder),
# allows you to make a numbered selection and copies the merged content
# of the selected files to the clipboard (macOS).

# Collect all .swift files in the current folder
files=( *.swift )

if [ ${#files[@]} -eq 0 ]; then
    echo "No .swift files found in the current folder."
    exit 1
fi

echo "Found .swift files:"
i=1
for file in "${files[@]}"; do
    echo "$i. $file"
    ((i++))
done

echo ""
read -p "Please enter the numbers of the files you want to copy (separated by spaces): " -a selections

# Merge the contents of the selected files
aggregateContent=""
for num in "${selections[@]}"; do
    if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le ${#files[@]} ]; then
        file=${files[$((num-1))]}
        aggregateContent+="\n----- Content of $file -----\n"
        aggregateContent+=$(cat "$file")
    else
        echo "Invalid selection: $num"
    fi
done

if [ -z "$aggregateContent" ]; then
    echo "No valid files selected."
    exit 1
fi

# Copy merged content to clipboard (macOS-specific)
echo -e "$aggregateContent" | pbcopy

echo "Selected files have been copied to the clipboard."
EOF

# Make the selection script executable
chmod +x "$TARGET_DIR/select_swift.sh"

echo "The selection script 'select_swift.sh' has been copied to the folder '$TARGET_DIR'."

# Change to the target folder
cd "$TARGET_DIR" || { echo "Error: Could not change to folder $TARGET_DIR."; exit 1; }

echo ""
echo "You are now in the folder '$(pwd)'."
echo "To select the Swift files and copy their content to the clipboard, run the following command:"
echo "   ./select_swift.sh"
echo ""

# Start a new shell to stay in the target folder
exec $SHELL
