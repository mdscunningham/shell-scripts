#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2015-04-23
# Updated: 2015-07-28
#
#
#!/bin/bash

## Exim Cheetsheet
# http://bradthemad.org/tech/notes/exim_cheatsheet.php

# Inspiration from previous work by: mwineland
# With php_maillog functions assisted by: mcarmack

## Exim command line flags and usage
# http://www.exim.org/exim-html-4.50/doc/html/spec_5.html#IX199

## Exim Utilities (help and usage info)
# http://www.exim.org/exim-html-4.50/doc/html/spec_49.html#IX2895

## Exim Log Files (flags and delimiters)
# http://www.exim.org/exim-html-current/doc/html/spec_html/ch-log_files.html

#-----------------------------------------------------------------------------#
## Because /moar/ regex is always better
shopt -s extglob

#-----------------------------------------------------------------------------#
## Utility functions, because prettier is better
dash(){ for ((i=1;i<=$1;i++)); do printf $2; done; }
section_header(){ echo -e "\n$1\n$(dash 40 -)"; }

#-----------------------------------------------------------------------------#
## Initializations
LOGFILE="/var/log/exim_mainlog"
PHPCONF=$(php -i | awk '/php.ini$/ {print $NF}');
if [[ -n $PHPCONF ]]; then PHPLOG=$(awk '/mail.log/ {print $NF}' $PHPCONF); fi
QUEUEFILE="/tmp/exim_queue_$(date +%Y.%m.%d_%H.%M)"
l=1; p=0; q=0; full_log=0;
LINECOUNT='1000000'
RESULTCOUNT='10'
DAYS=''; VERBOSE=0;

#-----------------------------------------------------------------------------#
# Menus for the un-initiated
#-----------------------------------------------------------------------------#
## MAIN MENU BEGIN
main_menu(){
PS3="Enter selection: "; clear
echo -e "$(dash 80 =)\nCurrent Queue: $(exim -bpc)\n$(dash 40 -)\n\nWhat would you like to do?\n$(dash 40 -)"
select OPTION in "Analyze Exim Logs" "Analyze PHP Logs" "Analyze Exim Queue" "Quit"; do
  case $OPTION in

    "Analyze Exim Logs")
      log_select_menu "/var/log/exim_mainlog"
      if [[ $l != '0' && -f $LOGFILE && ! $(file -b $LOGFILE) =~ zip ]]; then line_count_menu; fi
      results_prompt $l; break ;;

    "Analyze PHP Logs")
      l=0; p=1; q=0; log_select_menu "${PHPLOG}";
      if [[ $p != '0' && -f $PHPLOG && ! $(file -b $PHPLOG) =~ zip ]]; then line_count_menu; fi
      results_prompt $p; break;;

    "Analyze Exim Queue")
      l=0; q=1; p=0; line_count_menu;
      results_prompt $q; break ;;

    "Quit") l=0; q=0; p=0; break ;;

    *) echo -e "\nPlease enter a valid option.\n" ;;

  esac;
done; clear
}
## MAIN MENU END

#-----------------------------------------------------------------------------#
## Select a log file from what's on the server
log_select_menu(){
  if [[ -f $1 ]]; then
    echo -e "\nWhich file?\n$(dash 40 -)\n$(du -sh ${1}* 2> /dev/null)\n"
    select LOGS in ${1}* "Quit"; do
      case $LOGS in
        "Quit") l=0; q=0; p=0; break ;;
        *) if [[ -f $LOGS ]]; then LOGFILE=$LOGS; PHPLOG=$LOGS; break;
           elif [[ -f ${REPLY} ]]; then LOGFILE=${REPLY}; PHPLOG=${REPLY}; break;
           else echo -e "\nPlease enter a valid option.\n"; fi ;;
      esac
    done;
  else
    echo -e "\nNo logs found. Quitting.\n"; l=0; q=0; p=0;
    read -p "Press [Enter] to continue ..." pause;
  fi
}

#-----------------------------------------------------------------------------#
## Lines to read from the log file
line_count_menu(){
  PS3="Enter selection or linecount: "
  echo -e "\nHow many lines to analyze?\n$(dash 40 -)"
  select LINES in "Last 10,000 lines" "Last 100,000 lines" "Last 1,000,000 lines" "All of it" "Quit"; do
    case $LINES in
      "Quit") l=0; q=0; p=0; break ;;
      "All of it") full_log=1; break ;;
      "Last 10,000 lines") LINECOUNT=10000; break ;;
      "Last 100,000 lines") LINECOUNT=100000; break ;;
      "Last 1,000,000 lines") LINECOUNT=1000000; break ;;
      *) if [[ ${REPLY} =~ [0-9] ]]; then LINECOUNT=${REPLY}; break;
         else echo "Invalid input, using defaults."; break; fi ;;
    esac
  done
}

#-----------------------------------------------------------------------------#
# How many results to show
results_prompt(){
  if [[ $1 != '0' ]]; then
    echo; read -p "How many results do you want? [10]: " NEWCOUNT;
    if [[ -n $NEWCOUNT && $NEWCOUNT =~ [0-9] ]]; then RESULTCOUNT=$NEWCOUNT;
      elif [[ -z $NEWCOUNT ]]; then echo "Continuing with defaults.";
      else echo "Invalid input, using defaults."; fi;
  fi
}

#-----------------------------------------------------------------------------#
# Calculate lines to read if start date is set (-d flag).
date_lookup(){
  if [[ $l == 1 ]]; then DATE=$(date --date="-$DAYS days" +%Y-%m-%d);
    elif [[ $p == 1 ]]; then DATE=$(date --date="-$DAYS days" +"%e %b %Y"); fi

  if [[ -n $DAYS ]]; then
    echo -ne "Searching for date: $DATE\r"
    FIRSTLINE=$(grep -n "$DATE" $1 | head -1 | cut -d: -f1)

    if [[ -n $FIRSTLINE ]]; then
      LINECOUNT="+${FIRSTLINE}"
    else
      echo "Could not find the desired date in the log, using default 1,000,000 lines."
    fi
  fi
}

#-----------------------------------------------------------------------------#
# Setup how much of the log file to read and how.
set_decomp(){
  # Servername and Current time of Analysis, and exim version
  echo -e "Hostname: $(hostname)\nCur.Date: $(date +'%A, %B %d, %Y -- %Y.%m.%d')\nExim Ver: $(/usr/sbin/exim --version | head -n1)\n"

  # Compressed file -- decompress and read whole log
  if [[ $(file -b $1) =~ zip ]]; then
    DECOMP="zcat -f";
    du -sh $1 | awk '{print "Using Log File: "$2,"("$1")"}'
    if [[ $l == 1 ]]; then
      $DECOMP $1 | head -n 1 | awk '{print "First date in log: "$1,$2}'
    elif [[ $p == 1 ]]; then
      $DECOMP $1 | head -n 1000 | perl -pe 's/.*(Date:.*?)\ Ret.*/\1/g' | awk '/Date:/ {print "First date in log: "$2,$3,$4,$5,$6}' | head -1
    fi

  # Read full log (uncompressed)
  elif [[ $full_log == 1 ]]; then
    DECOMP="cat";
    du -sh $1 | awk '{print "Using Log File: "$2,"("$1")"}'
    if [[ $l == 1 ]]; then
      head -1 $1 | awk '{print "First date in log: "$1,$2}';
    elif [[ $p == 1 ]]; then
      grep "Date:" $1 | head -1 | perl -pe 's/.*(Date:.*?)\ Ret.*/\1/g' | awk '/Date:/ {print "First date in log: "$2,$3,$4,$5,$6}';
    fi

  # Minimize impact on initial scan, using last LINECOUNT lines
  # Search for first date at the start of the LINECOUNT
  elif [[ -z $DAYS ]]; then
    DECOMP="tail -n $LINECOUNT";
    du -sh $1 | awk -v LINES="$LINECOUNT" '{print "Last",LINES,"lines of: "$2,"("$1")"}';
    echo -ne "Searching for first date  . . . \r"
    if [[ $l == 1 ]]; then
      tac $1 | head -n $LINECOUNT | tail -n 1 | awk '{print "First date found: "$1,$2}'
    elif [[ $p == 1 ]]; then
      tac $1 | head -n $LINECOUNT | tail -n 1000 | perl -pe 's/.*(Date:.*?)\ Ret.*/\1/g' | awk '/^Date:/ {print "First date found: "$2,$3,$4,$5,$6}' | tail -1
    fi

  # Use speficied date as starting point
  elif [[ -n $DAYS ]]; then
    DECOMP="tail -n $LINECOUNT";
    du -sh $1 | awk -v LINES="$LINECOUNT" '{print "Last",LINES,"lines of: "$2,"("$1")"}';
    echo "Starting with specified date: $DATE"
  fi

  # If log is not compressed, read the last date from the file
  if [[ ! $(file -b $1) =~ zip ]]; then
    if [[ $l == 1 ]]; then
      tail -n 1 $1 | awk '{print "Last date in log: "$1,$2}'
    elif [[ $p == 1 ]]; then
      tail -n 1000 $1 | perl -pe 's/.*(Date:.*?)\ Ret.*/\1/g' | awk '/Date:/ {print "Last date in log: "$2,$3,$4,$5,$6}' | tail -1
    fi
  fi
}

#-----------------------------------------------------------------------------#
# Process commandline flags
arg_parse(){
  local OPTIND;
  while getopts ac:d:f:hn:pqv OPTIONS; do
    case "${OPTIONS}" in
      a) full_log=1 ;;
      c) LINECOUNT=${OPTARG} ;;
      d) DAYS=${OPTARG} ;;
      f) LOGFILE=${OPTARG}; QUEUEFILE=${OPTARG}; PHPLOG=${OPTARG} ;; # Specify a log/queue file
      n) RESULTCOUNT=${OPTARG} ;;
      p) l=0; p=1; q=0 ;; # PHP log
      q) l=0; q=1; p=0 ;; # Analyze queue instead of log
      v) VERBOSE=1 ;; # Debugging Output
      h) l=0; q=0; p=0;
         echo -e "\nUsage: $0 [OPTIONS]\n
    -a ... Read full log (instead of last 1M lines)
    -c ... <#lines> to read from the end of the log
    -d ... <#days> back to read in the log (calculates linecount)
    -f ... </path/to/logfile> to use instead of default
    -n ... <#results> to show from analysis
    -p ... Look for 'X-PHP-Script' in the php mail log
    -q ... Create a queue logfile and analyze the queue
    -v ... Verbose (debugging output)\n
    -h ... Print this help and quit\n";
         return 0 ;; # Print help and quit
    esac
  done
}

#-----------------------------------------------------------------------------#
## Setup the log file analysis methods
mail_logs(){
# This will run a basic analysis of the exim_mainlog, and hopefully will also do the first few
# steps of finding any malware/scripts that are sending mail and their origins

date_lookup $LOGFILE
echo; set_decomp $LOGFILE;

## Count of messages sent by scripts
section_header "Directories"
$DECOMP $LOGFILE | grep 'cwd=' | grep -v 'exim -bp' | perl -pe 's/.*cwd=(\/.*?)\ .*/\1/g'\
 | awk '!/spool|error/ {freq[$0]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}'\
 | sort -rn | head -n $RESULTCOUNT

# Count of messages per "Account/Domains"
section_header "Accounts/Domains"
$DECOMP $LOGFILE | grep -o '<=\ [^<>].*\ U=.*\ P=' | perl -pe 's/.*@(.*?)\ U=(.*?)\ P=/\2 \1/g'\
 | awk '{freq[$0]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}'\
 | sort -rn | head -n $RESULTCOUNT | awk '{printf "%8s %-10s %s\n",$1,$2,$3}'

# Count of messages per Auth-Users
section_header "Auth-Users"
$DECOMP $LOGFILE | grep -Eo 'A=.*in:.*\ S=' | perl -pe 's/.*:(.*?)\ S=/\1/g'\
 | awk '{freq[$0]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}'\
 | sort -rn | head -n $RESULTCOUNT

# Count of IPs per Auth-Users
section_header "IP-Addresses/Auth-Users"
$DECOMP $LOGFILE | grep 'A=.*in:.*\ S=' | perl -pe 's/.*[^I=]\[(.*?)\].*A=.*in:(.*?)\ S=.*$/\1 \2/g'\
 | awk '{freq[$0]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}'\
 | sort -rn | head -n $RESULTCOUNT | awk '{printf "%8s %-15s %s\n",$1,$2,$3}'

# Count of IPs that failed login
section_header "Failed Login IPs"
$DECOMP $LOGFILE | grep 'authenticator failed' | perl -pe 's/.*\ \[(.*?)\]:.*/\1/g'\
 | awk '{freq[$1]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}'\
 | sort -rn | head -n $RESULTCOUNT

# Spoofed Sender Addresses
section_header "Spoofed Senders"
FMT="%8s %-35s %s\n"
printf "$FMT" "Count " " Auth-User" " Spoofed-User"
printf "$FMT" "--------" "$(dash 35 -)" "$(dash 35 -)"
$DECOMP $LOGFILE | grep 'A=.*in:.*\ S=' | perl -pe 's/.*<=\ (.*?)\ .*A=.*in:(.*?)\ .*/\2 \1/g'\
 | awk '{ if ($1 != $2) freq[$0]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}'\
 | sort -rn | head -n $RESULTCOUNT | awk -v FMT="$FMT" '{printf FMT,$1" ",$2,$3}'
printf "$FMT" "--------" "$(dash 35 -)" "$(dash 35 -)"

# Show sent messages with the most recipients
section_header "Bulk Senders"
FMT="%8s %-16s %s\n"
printf "$FMT" "RCPTs " " MessageID" " Auth-User"
printf "$FMT" "--------" "$(dash 16 -)" "$(dash 40 -)"
$DECOMP $LOGFILE | grep "<=.*A=.*in:.*\ for\ "\
 | perl -pe 's/.*\ (.*?)\ <=\ .*A=.*in:(.*)\ S=.*\ for\ (.*)//g; print $count = scalar(split(" ",$3))," ",$1," ",$2;'\
 | sort -rn | head -n $RESULTCOUNT | awk -v FMT="$FMT" '{printf FMT,$1" ",$2,$3}'
printf "$FMT" "--------" "$(dash 16 -)" "$(dash 40 -)"

# Count of Messages by Subject
section_header "Subjects (Non-Bounceback)"
$DECOMP $LOGFILE | grep '<=.*T=' | perl -pe 's/.*T=\"(.*?)\".*/\1/g'\
 | awk '!/failed: |deferred: / {freq[$0]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}'\
 | sort -rn | head -n $RESULTCOUNT

# Count of Bouncebacks by address
section_header "Bouncebacks (address)"
$DECOMP $LOGFILE | grep '<= <>.*\ for\ ' | perl -pe 's/.*\".*for\ (.*$)/\1/g'\
 | awk '{freq[$0]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}'\
 | sort -rn | head -n $RESULTCOUNT

echo
}

#-----------------------------------------------------------------------------#
## Setup the queue/file analysis methods
mail_queue(){
# This will run a basic summary of the mail queue, using both exim -bpr and /var/spool/exim/input/*

# Limit the queue scan to keep things fast
if [[ $full_log == 1 ]]; then READLIMIT="cat"; LOGLIMIT="cat"
  else READLIMIT="head -n $LINECOUNT"; LOGLIMIT="head -n $(( $LINECOUNT * 3 ))"; fi

## Current Queue Dump
if [[ -f $QUEUEFILE ]]; then
  echo -e "\nFound existing queue dump ( $QUEUEFILE ).\n"
else
  echo -e "\nCreating Queue Dump ($QUEUEFILE) to speed up analysis\n ... Thank you for your patience"
  /usr/sbin/exim -bpr | $LOGLIMIT > $QUEUEFILE
fi

# Read full log (uncompressed)
if [[ $full_log == 1 ]]; then
  DECOMP="cat";
  du -sh $QUEUEFILE | awk '{print "Using Queue Dump: "$2,"("$1")"}'
# Minimize impact on initial scan, using last 1,000,000 lines
else
  DECOMP="tail -n $LINECOUNT";
  du -sh $QUEUEFILE | awk -v LINES="$LINECOUNT" '{print "Last",LINES,"lines of: "$2,"("$1")"}';
fi

## Queue Summary
section_header "Queue: Summary"
if [[ -n $(head $QUEUEFILE) ]]; then
$DECOMP $QUEUEFILE | /usr/sbin/exiqsumm | head -3 | tail -2;
cat $QUEUEFILE | /usr/sbin/exiqsumm | sort -rnk1 | grep -v "TOTAL$" | head -n $RESULTCOUNT
fi

## Queue Senders
section_header "Queue: Auth Users"
find /var/spool/exim/input/ -type f -name "*-H" -print 2>/dev/null | xargs grep --no-filename 'auth_id' 2>/dev/null\
 | $READLIMIT | sed 's/-auth_id //g' | sort | uniq -c | sort -rn | head -n $RESULTCOUNT

## Queue Subjects
section_header "Queue: Subjects"
find /var/spool/exim/input/ -type f -name "*-H" -print 2>/dev/null | xargs grep --no-filename "Subject: " 2>/dev/null\
 | $READLIMIT | sed 's/.*Subject: //g' | sort | uniq -c | sort -rn | head -n $RESULTCOUNT

## Queue Scripts
section_header "Queue: X-PHP-Scripts"
find /var/spool/exim/input/ -type f -name "*-H" -print 2>/dev/null | xargs grep --no-filename "X-PHP.*-Script:" 2>/dev/null\
 | $READLIMIT | sed 's/^.*X-PHP.*-Script: //g;s/\ for\ .*$//g' | sort | uniq -c | sort -rn | head -n $RESULTCOUNT

## Count of (non-bounceback) Sending Addresses in queue
section_header "Queue: Senders"
$DECOMP $QUEUEFILE | awk '($4 ~ /<[^>]/) {freq[$4]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}'\
 | sort -rn | tr -d '<>' | head -n $RESULTCOUNT

## Count of Bouncebacks in the queue
section_header "Queue: Bouncebacks (count)"
$DECOMP $QUEUEFILE | awk '($4 ~ /<>/) {freq[$4]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}'\
 | sort -rn | head -n $RESULTCOUNT

## Count of 'frozen' messages by user
section_header "Queue: Frozen (count)"
$DECOMP $QUEUEFILE | awk '/frozen/ {freq[$4]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}'\
 | sort -rn  | head -n $RESULTCOUNT | sed 's/<>/*** Bounceback ***/' | tr -d '<>'

echo
}

# Check that X_Header is turned on and process the php_maillog
mail_php(){
echo -e "\n$(php -v | head -1)\n"
date_lookup $PHPLOG

if [[ -f $PHPCONF && -n $(grep '^mail.add_x_header.*On' $PHPCONF) ]]; then
  echo "php.ini : $PHPCONF"
  echo "mail.log: $PHPLOG ($(du -sh $PHPLOG | awk '{print $1}'))"
  echo -e "X_Header: Enabled\n"

  set_decomp $PHPLOG;

  # Look for mailer scripts in the php_maillog
  section_header "PHP Mailer Scripts"
  $DECOMP $PHPLOG | perl -pe 's/.*\[(\/home.*?)\]/\1/g'\
   | awk -F: '{freq[$1]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}' | sort -rn | head -n $RESULTCOUNT

  echo
elif [[ ! -f $PHPCONF ]]; then
  echo "Could not find php.ini file."
else
  echo "X_Header: Disabled"
fi
}

#-----------------------------------------------------------------------------#
# Call menus or parse cli flags
if [[ -z $@ ]]; then main_menu; else arg_parse "$@"; fi

#-----------------------------------------------------------------------------#
## Run either logs() or queue() function
if [[ $l == 1 ]]; then mail_logs
elif [[ $q == 1 ]]; then mail_queue
elif [[ $p == 1 ]]; then mail_php; fi

if [[ $VERBOSE == 1 ]]; then
  dash 80 =; section_header "Debugging Information"
  echo -e "    LOGFILE : $LOGFILE
  QUEUEFILE : $QUEUEFILE
     PHPLOG : $PHPLOG
    PHPCONF : $PHPCONF
   full_log : $full_log
  LINECOUNT : $LINECOUNT
RESULTCOUNT : $RESULTCOUNT
       DAYS : ${DAYS:-Unset}
       DATE : ${DATE:-Unset}\n"
fi

unset LOGFILE QUEUEFILE PHPCONF PHPLOG full_log LINECOUNT RESULTCOUNT DAYS DATE VERBOSE READLIMIT LOGLIMIT
#~Fin~
