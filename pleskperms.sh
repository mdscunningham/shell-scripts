#!/bin/bash
#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
#                                                          +----+----+----+----+
# Created: 2016-03-10
# Updated: 2016-03-10
#
# Purpose: Update Plesk 11/12 ownership and perms on files and directories
#

# Get username from current directory
getusr(){ pwd | sed 's:^/chroot::' | cut -d/ -f3; }

# Set ownership and perms on folders
find $PWD -type d -print0 | xargs -0 chown $(getusr):psaserv
find $PWD -type d -print0 | xargs -0 chmod 2775

# Set ownership and perms on files
find $PWD -type f -print0 | xargs -0 chown $(getusr):psacln
find $PWD -type f -print0 | xargs -0 chmod 644


