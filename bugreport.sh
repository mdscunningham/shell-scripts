#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-08-12
# Updated: 2014-08-24
#
#
#!/bin/bash

## Send a bug report to my email regarding a function in my bashrc

# Print explanation of what to put in the report
echo -e "\nPlease include information regarding what you were trying to do, any files
you were working with, the command you ran, and the error you received. I will
try and get back to you with either an explaination or a fix, as soon as I can.\n
Once you save and exit this file, this message will be sent and this file removed.\n"

# Pause for displaying the message above
read -p "Script is paused, press [Enter] to begin editing the message ..."

# Lookup Iworx version for inclusion in the email report
IworxVersion=$(echo -n $(grep -A1 'user=\"iworx\"' /home/interworx/iworx.ini | cut -d\" -f2 | sed 's/^\(.\)/\U\1/'))

# Input basic infomration in to temp file as a framework for the report
echo -e "Bug Report (.bashrc): <Put the subject here>\n\nSERVER: $(serverName)\nUSER: $SUDO_USER\nPWD: $PWD\n$IworxVersion\n\nFiles:\n\nCommands:\n\nErrors:\n\n" > ~/tmp.file

# Open the temp file for editing, and send the contents of the temp file as email, then remove temp file
vim ~/tmp.file && cat ~/tmp.file | mail -s "$(head -1 ~/tmp.file)" "mcunningham@nexcess.net" && rm ~/tmp.file
