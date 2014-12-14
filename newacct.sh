#!/bin/bash
if [[ -n $1 && -n $2 ]]; then
  eval $(ssh-agent); ssh-add ~/.ssh/nex$(whoami).id_rsa
  ./provision.expect $1 $2 $(whoami)
  eval $(ssh-agent) > /dev/null
else
  echo -e "\n Usage $0 <host> <domain>\n"
fi

