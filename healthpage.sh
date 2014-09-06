# Print out health page of Nodeworx to screen with colors on good/bad/ugly
nodeworx -u -n -c health -a listHealthStatus | awk '{print $1,$3}' | sed "s/0$/${BRIGHT}${GREEN}GOOD${NORMAL}/g;s/1$/${BRIGHT}${RED}BAD${NORMAL}/g;s/2$/N\/A/g" | column -t
