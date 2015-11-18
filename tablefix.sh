#!/bin/bash
#                                                          +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2015-11-01
# Updated: 2015-11-03
#
#
# Check/Repair/Optimize all tables in either one or more databases.

# Setting default action to check
check=1;

OPTIONS=$(getopt -o "acroh" -- "$@") # Execute getopt
eval set -- "$OPTIONS" # Magic
while true; do # Evaluate the options for their options
case $1 in
  -a ) dblist=$(mysql -Ne 'show databases' | grep -Ev 'schema|mysql'); all=1 ;;
  -c ) check=1 ;;
  -r ) repair=1 ;;
  -o ) optimize=1 ;;
  -- ) shift; break ;; # More Magic
  -h|--help|* ) echo "
  Usage: $0 [options] [<db1> <db2> <db3> ...]

  Options:
    -a ... Repeat for all dbs (Excludes 'mysql' and 'schema' datbases)
    -c ... Check tables of db
    -o ... Optimie tables of db
    -r ... Repair tables of db
    -h ... Print help and quit
"; exit ;; # Print help info
esac;
shift;
done

# Database list if not already set to all databases
if [[ -n "$@" ]]; then dblist="$@"; elif [[ -z "$@" && $all != '1' ]]; then read -p "Database: " dblist; fi

# Start selected operations
echo; for database in $dblist; do
  for table in $(mysql -Ne 'show tables' $database); do
    printf "%-60s" "$database.$table"
    if [[ $check == 1 ]]; then
      echo -n "[ Check ]";
      mysql -Ne "check table $table" $database > /dev/null;
    fi
    if [[ $repair == 1 ]]; then
      echo -n "[ Repair ]";
      mysql -Ne "repair table $table" $database > /dev/null;
    fi
    if [[ $optimize == 1 ]]; then
      echo -n "[ Optimize ]";
      mysql -Ne "optimize table $table" $database > /dev/null;
    fi
    echo
  done; echo
done;

unset check repair optimize dblist all
