#!/bin/bash
#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
#                                                          +----+----+----+----+
# Created: 2016-10-05
# Updated: 2016-10-05
#
# Purpose: Remove previous cPanel backups, to prevent disk filling with new backups.
#

# Remove Old Weekly backup before new one is created
0 0 * * 5 rm -rf $(find /backup/weekly/ -maxdepth 1 -type d -mtime +5)

# Remove old Daily backup before new one is created
0 0 * * 1 rm -rf $(find /backup/*/accounts/ -maxdepth 0 -type d -mtime +5 | sed 's/accounts\///')
