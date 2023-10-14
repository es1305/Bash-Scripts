#!/bin/bash

input=spammers.txt

if [[ -e $input ]]; then
  i=$(cat $input | grep "@" | sort | uniq | wc -l)
  echo "Found $i spammer's addresses in file"
  cat $input | grep "@" | sort | uniq | while read addr; do
    doveadm expunge -A mailbox "*" FROM $addr
  done

  cat /etc/postfix/accesslist > /tmp/list_tmp
  cat $input | awk -F'@' '{print $2}' | sort | uniq | awk '{print $0" REJECT"}' >> /tmp/list_tmp
  cat /tmp/list_tmp | grep -E -v '(mail.ru|list.ru|inbox.ru|bk.ru|gmail.com|yandex|rambler|outlook.com|msn.com|live.com|icloud.com|me.com)' > /etc/postfix/accesslist
  sort -o /etc/postfix/accesslist{,} && postmap /etc/postfix/accesslist
  rm /tmp/list_tmp
  :>$input
  echo "Finished!"

else
  echo "File $input not found!"
  exit 1
fi
