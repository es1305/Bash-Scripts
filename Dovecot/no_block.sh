#!/bin/bash

input=spammers.txt

if [[ -e $input ]]; then
  i=$(cat $input | grep "@" | sort | uniq | wc -l)
  echo "Found $i spammer's addresses in file"
  cat $input | grep "@" | sort | uniq | while read addr; do
    doveadm expunge -A mailbox "*" FROM $addr
  done
  :>$input
  echo "Finished!"

else
  echo "File $input not found!"
  exit 1
fi
