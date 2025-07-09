#!/bin/bash

# Show help message
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  echo "Target Folder Setup Script"
  echo
  echo "Description:"
  echo "  This script creates a structured folder setup for a given web target (e.g., for bug bounty or pentesting)."
  echo "  It sets up default folders and Markdown files used for live testing, PoCs, Burp data, etc."
  echo "  Optionally, you can fix an existing target by ensuring all required files/folders exist."
  echo
  echo "Usage:"
  echo "  $0 <target_base_name> [--fix] [extra_live_test_file1 ...]"
  echo
  echo "Options:"
  echo "  --fix        Check and fix missing folders/files for an existing target"
  echo "  -h, --help   Show this help message and exit"
  echo
  echo "Behavior:"
  echo "  - If a folder like <target>_* (e.g., ACME_BBP) exists, it will be used automatically."
  echo "  - Creates default Markdown files in the LiveTest folder."
  echo "  - You can pass extra LiveTest file names (with spaces), and they'll be created as <name>_live_testing.md"
  echo
  echo "Examples:"
  echo "  $0 YourTargetName 'OAuth Flaws' 'JWT tokens'"
  echo "  $0 YourTargetName --fix"
  echo
  echo "Author: Ahmed Fares"
  exit 0
fi

if [ -z "$1" ]; then
  echo "Usage: $0 <target_base_name> [--fix] [additional_live_test_files...]"
  exit 1
fi

base_name="$1"
shift

fix_mode=false
extra_files=()

# Parse arguments
for arg in "$@"; do
  if [ "$arg" == "--fix" ]; then
    fix_mode=true
  else
    extra_files+=("$arg")
  fi
done

# Try to find a directory like Target_*
target=$(find . -maxdepth 1 -type d -name "${base_name}_*" -printf "%f\n" | head -n 1)

# Fallback to base name if not found
if [ -z "$target" ]; then
  target="$base_name"
fi

echo "[*] Working on target folder: $target"

# Default folders
folders=(
  "$target"
  "$target/Accounts"
  "$target/Burp_${target}"
  "$target/${target}_Main_Domain"
  "$target/${target}_Sub_Domain"
  "$target/LiveTest"
  "$target/PoC"
)

# Default LiveTest files
default_tests=(
  "SQL injection"
  "Authentication live testing"
  "Path Traversal"
  "Command injection"
  "Business logic live testing"
  "Information disclosure"
  "Access control"
  "File upload"
  "SSRF"
  "XXE injection"
  "NoSQL injection"
  "API testing"
  "XXS"
  "CSRF"
  "CORS"
  "Clickjacking"
  "WebSockets"
  "SST injection"
)

# Create folders if not exist
for folder in "${folders[@]}"; do
  if [ ! -d "$folder" ]; then
    echo "[+] Creating folder: $folder"
    mkdir -p "$folder"
  elif $fix_mode; then
    echo "[✓] Folder exists: $folder"
  fi
done

# Create account.md if not exist
account_file="$target/Accounts/account.md"
if [ ! -f "$account_file" ]; then
  echo "[+] Creating file: $account_file"
  touch "$account_file"
elif $fix_mode; then
  echo "[✓] File exists: $account_file"
fi

# Create default LiveTest files
for test in "${default_tests[@]}"; do
  filename="${test// /_}_live_testing.md"
  filepath="$target/LiveTest/$filename"
  if [ ! -f "$filepath" ]; then
    echo "[+] Creating LiveTest file: $filepath"
    touch "$filepath"
  elif $fix_mode; then
    echo "[✓] LiveTest file exists: $filepath"
  fi
done

# Handle extra files
for extra_file in "${extra_files[@]}"; do
  sanitized_name="${extra_file// /_}_live_testing.md"
  filepath="$target/LiveTest/$sanitized_name"
  if [ ! -f "$filepath" ]; then
    echo "[+] Creating extra LiveTest file: $filepath"
    touch "$filepath"
  elif $fix_mode; then
    echo "[✓] Extra file exists: $filepath"
  fi
done

echo "Done for target: $target"
