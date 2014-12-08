#!/bin/bash
echo "Moving current var to var.old"; mv var{,.old}
echo "Unpacking var archive ..."; tar -zxpf var.tar.gz

primaryDomain=$(~iworx/bin/listaccounts.pex | awk "/$(pwd | sed 's:^/chroot::' | cut -d/ -f3)/"'{print $2}')
echo "Runing varpermsfix on Siteworx account [$primaryDomain]"
~iworx/bin/varpermsfix.pex --siteworx=$primaryDomain
echo "Cleaning up var backup ..."; rm -r var.old var.tar.gz; echo "Done"
