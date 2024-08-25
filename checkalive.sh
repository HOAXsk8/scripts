#!/bin/bash

# Check if at least one argument is provided
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <input_file> [--noping]"
    exit 1
fi

# Input file containing the list of hosts
input_file="$1"

# Check if --noping option is provided
use_noping=false
if [ "$2" == "--noping" ]; then
    use_noping=true
fi

# Output files for alive and dead hosts
alive_file="alive_hosts.txt"
dead_file="dead_hosts.txt"

# Clear the contents of the output files if they already exist
> "$alive_file"
> "$dead_file"

# Loop through each line (host) in the input file
while IFS= read -r host; do
  host=$(echo "$host" | xargs)  # Trim whitespace

  if [ "$use_noping" == true ]; then
    # Check if host is up using nc (Netcat) on port 80 (or another port)
    if nc -z -w 5 "$host" 80 > /dev/null 2>&1; then
      echo "$host is alive (checked via TCP connection)"
      echo "$host" >> "$alive_file"
    else
      echo "$host is dead (checked via TCP connection)"
      echo "$host" >> "$dead_file"
    fi
  else
    # Check if host is up using ping
    if ping -c 1 -W 5 "$host" > /dev/null 2>&1; then
      echo "$host is alive (checked via ping)"
      echo "$host" >> "$alive_file"
    else
      echo "$host is dead (checked via ping)"
      echo "$host" >> "$dead_file"
    fi
  fi

done < "$input_file"

echo "Host check completed."
