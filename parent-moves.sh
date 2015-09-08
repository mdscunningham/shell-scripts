#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2015-09-02
# Updated: 2015-09-03
#
#
#!/bin/bash

x=0;
for parent in $@ ; do

  # Initializations
  start=$((17+$x));
  SERVER=($(cat $parent))
  days="$(seq 0 20)"
  hours="$(seq 0 3 9)"

  ## Date Generation (For email subject and body)
  TIMESTAMP=($(
  for day in $days; do
    for hour in $hours; do
      date --date="$start +$hour hour +$day day" +"%r %Z on %B %d" | sed 's/ /_/g'
    done;
  done)
  )

  # Date Generation for file names
  DATE=($(
  for day in $days; do
    for hour in $hours; do
      date --date="$start +$hour hour +$day day" +"%Y.%m.%d_%H:00"
    done;
  done)
  )

  # Print ticket response
  for ((i=0;i<${#SERVER[@]};i++)); do
    echo "Scheduled Server Maintenance :: $(echo ${SERVER[$i]} | cut -d_ -f2) :: ($( echo ${TIMESTAMP[$i]} | sed 's/_/ /g' ))

Hello,

I am contacting you because the parent server of **$(echo ${SERVER[$i]} | cut -d_ -f2)** requires maintenance and needs to be temporarily taken offline.
To avoid the downtime associated with the parent maintenance we will need to move your server to another parent.
I have tentatively scheduled this task to begin at **($( echo ${TIMESTAMP[$i]} | sed 's/_/ /g' ))** and we will notify you prior to beginning.

Please note, there are two brief instances of downtime associated with the move: The first occurs when the server is taken offline
for a file-system check, and the latter when the server is rebooted at the end of the file transfer to assign networking.
The server will remain online throughout the bulk of the process, which is during the transfer of data.

Please let us know if you have any questions or concerns regarding this process, or if you would otherwise like to reschedule the move.

Sincerely,
" > ${DATE[$i]}_${SERVER[$i]}_maint.txt
  done

  #End outer loop, and increment counter
  x=$(($x+1));
done

unset day days hour hours SERVER TIMESTAMP DATE
