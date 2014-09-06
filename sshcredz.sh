sshcredz(){
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  echo -e "\n Usage: sshcredz [-p <password>] [-i \"<IP1> <IP2> <IP3> ...\"] [comment]\n";
  return 0;
fi

# if password specified
if [[ $1 == '-p' ]]; then newPass="$2"; shift; shift;
else newPass=$(mkpasswd -l 15); fi

# if whitelist specified
if [[ $1 == '-i' ]]; then whitelist ssh "$2" "$3"; fi

# nksshd userControl -Csr $U -p $P;
# ^^^ Foregoing this usage in order to be more uniform

# Set shell, and add to ssh user's group; then reset failed logins, and reset password.
usermod -s /bin/bash -a -G sshusers $(getusr) && echo -n "User $(getusr) added to sshusers ... "
pam_tally2 -u $(getusr) -r &> /dev/null && echo -n "Failures for $(getusr) reset ... "
echo "$newPass" | passwd --stdin $(getusr) &> /dev/null && echo "Password set to $newPass"

# Output block for copy pasta
echo -e "\nHostname: $(serverName)\nUsername: $U\nPassword: $newPass\n";
}

sshcredz "$@"
