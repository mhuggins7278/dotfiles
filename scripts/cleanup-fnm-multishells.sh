#!/bin/bash
# Cleanup old fnm multishell directories
# These accumulate over time and all point to the same default alias

multishells_dir="$HOME/.local/state/fnm_multishells"
current_shell_id="${FNM_MULTISHELL_PATH##*/}"

if [[ ! -d "$multishells_dir" ]]; then
  echo "No multishells directory found"
  exit 0
fi

echo "Current multishell: $current_shell_id"
echo "Total multishells: $(ls -1 "$multishells_dir" | wc -l)"

# Remove all except current shell
find "$multishells_dir" -maxdepth 1 -type l ! -name "$current_shell_id" -delete

echo "Cleaned up old multishells"
echo "Remaining: $(ls -1 "$multishells_dir" | wc -l)"
