#!/bin/bash

input=spammers.txt
gd='(mail.ru|list.ru|inbox.ru|bk.ru|gmail.com|yandex|rambler|outlook.com|msn.com|live.com|icloud.com|me.com)'

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
  fi

  cat $input | grep "@" | sort | uniq | while read addr; do
    doveadm expunge -A mailbox "*" FROM $addr
  done

  cat /etc/postfix/accesslist > /tmp/list_tmp
  cat $input | awk -F'@' '{print $2}' | sort | uniq | awk '{print $0" REJECT"}' >> /tmp/list_tmp
  cat /tmp/list_tmp | sort | uniq | grep -E -v $gd > /etc/postfix/accesslist
  postmap /etc/postfix/accesslist
  :>$input
  echo
  echo "${GREEN}Finished!${NORMAL}"

else
  echo
  echo "${RED}ERROR! File $input is not found!${NORMAL}"
  exit 1
fi
