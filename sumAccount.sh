#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
#                                                          +----+----+----+----+
# Created: 2014-08-02
# Updated: 2014-08-02
#
#
#!/bin/bash

sumAccount=$(nodeworx -u -n -c Siteworx -a listAccounts | grep $(getusr) | sed 's/ /_/g')
echo $sumAccount | awk '{print $2" - "$4" - "$5" - "$7" - "$8" - "$10}'
(
echo $sumAccount | awk '{print "User: "$2}'
echo $sumAccount | awk '{print "Status: "$4}'
echo $sumAccount | awk '{print "Reseller: "$5}'
echo $sumAccount | awk '{print "Name: "$7}'
echo $sumAccount | awk '{print "Email: "$8}'
echo $sumAccount | awk '{print "Domain: "$10}'
) | column -t
