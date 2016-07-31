#!/bin/bash

for x in $(cat whmapi.txt); do
  cli=$(curl -sk https://documentation.cpanel.net/display/SDK/WHM+API+1+Functions+-+{+,}${x});
  #params=$(echo $cli | grep 'Parameter<'
  #paramlist=$(echo $cli | grep 'confluenceTd"><code>.*?</code></td>')

  if [[ -n $(echo $cli | grep 'Command Line' 2>/dev/null) ]]; then
    echo "$x :: CLI";
  fi;
done
