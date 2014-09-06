#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2013-11-08
# Updated: 2014-08-02
#
#
#!/bin/bash

# U=$(pwd | cut -d/ -f3); if [[ $U == 'home' ]]; then U=$(pwd | cut -d/ -f4); fi; echo $U
# F=3; if [[ $PWD =~ ^\/chroot ]]; then F='4'; fi; pwd | cut -d/ -f$F
pwd | sed 's:^/chroot::' | cut -d/ -f3
