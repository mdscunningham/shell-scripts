#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2015-07-05
# Updated: 2015-09-07
#
#
#!/bin/bash
# Find large disk objects when '/' is full or close to full

if [[ -n $1 ]]; then depth=$1; else depth=1; fi
du -kx --max-depth $depth / | awk '{printf "%8.3fG %s\n",($1/1000/1024),$2}' | grep -E --color '[1-9]\....G |0\.[1-9]..G '
