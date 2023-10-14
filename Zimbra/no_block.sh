#!/bin/bash
input=in.txt

if [[ -e $input ]]; then
  i=$(cat $input | grep "@" | sort | uniq | wc -l)
  echo "Found $i spammer's addresses in file"
  cat $input | grep "@" | sort | uniq | while read addr; do
    for acct in $(/opt/zimbra/bin/zmprov -l gaa | grep -E -v '(^spam\..*@|^ham\..*@|^virus-quarantine.*@|^galsync.*@)' | sort); do
      echo "Searching in $acct for $addr"
      for msg in $(/opt/zimbra/bin/zmmailbox -z -m "$acct" s -l 999 -t message "from:$addr" | awk '{ if (NR!=1) {print}}' | grep -v -e Id -e "--" -e "^$" | awk '{ print $2 }'); do
        echo "Removing "$msg" from "$acct""
        /opt/zimbra/bin/zmmailbox -z -m $acct dm $msg
      done
    done
  done
  :>$input
  echo "Finished!"
else
  echo "File $input not found!"
  exit 1
fi
