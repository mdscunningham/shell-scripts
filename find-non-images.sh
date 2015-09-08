#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2015-06-23
# Updated: 2015-09-08
#
#
#!/bin/bash

# So when using regex matching in find, you need to escape both the () and |
# http://stackoverflow.com/questions/19111067/regex-match-either-string-in-linux-find-command

find /home*/*/public_html/ -type f -regex ".*\(jpg\|jpeg\|gif\|png\|bmp\)$" -print0 | xargs -0 grep -l '<?php' 2> /dev/null
