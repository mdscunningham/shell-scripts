#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2015-07-05
# Updated: 2015-07-05
#
#
#!/bin/bash
# Find large disk objects when '/' is full or close to full

# Enable BASH extended globs
shopt -s extglob

# Generate list of partitions to exlude
PARTLIST=$(df -h | awk -F/ 'NR>2 {printf "%s|",$2}' | sed 's/|$/|proc/g';)

# Summarize disk usage for all non-partition directories in '/'
du --max-depth 3 -h /!($PARTLIST) | grep --color -E '^[0-9]{3}M|^[0-9\.]*G'


## Oneliner-version
#
# shopt -s extglob; du --max-depth 3 -h /!($(df -h | awk -F/ 'NR>2 {printf "%s|",$2}' | sed 's/|$/|proc/g';)) | grep --color -E '^[0-9]{3}M|^[0-9\.]*G'
#
##
