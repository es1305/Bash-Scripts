#!/bin/bash

input=spammers.txt

# Colors
NORMAL=''
GREEN=''
RED=''
if tty -s; then
  NORMAL="$(tput sgr0)"
  GREEN=$(tput setaf 2)
  RED="$(tput setaf 1)"
fi

if [[ -e $input ]]; then
  i=$(cat $input | grep "@" | sort | uniq | wc -l)

  if [[ $i -eq 0 ]]; then
    echo
    echo "${GREEN}Found ${RED}$i ${GREEN}spammer's addresses in $input"
    echo "Nothing to remove!${NORMAL}"
    exit 0
  else
    echo
    echo "${GREEN}Found ${RED}$i ${GREEN}spammer's addresses in $input"
    echo "Please wait for remove...${NORMAL}"
    :>$input
  fi

  cat $input | grep "@" | sort | uniq | while read addr; do
    doveadm expunge -A mailbox "*" FROM $addr
  done
else
  echo
  echo "${RED}ERROR! File $input is not found!${NORMAL}"
  exit 1
fi
