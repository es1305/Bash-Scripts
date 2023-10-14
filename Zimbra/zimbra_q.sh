#!/bin/bash

# Zimbra Abuse Alerts
# -------------------
# su - zimbra
# zmprov mcf zimbraMtaSmtpdSaslAuthenticatedHeader yes
# zmmtactl restart
# -------------------
#
# Validate config variable is set:
# postconf -v | grep smtpd_sasl_authenticated_header
# > smtpd_sasl_authenticated_header = yes
#

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
MAXDEFERRED=100
CURDEFERRED=$(find /opt/zimbra/data/postfix/spool/deferred -type f | wc -l)
CURHELD=$(find /opt/zimbra/data/postfix/spool/hold -type f | wc -l)
ZIMBRA_ADMIN=USER@EXAMPLE.COM

if [[ $CURDEFERRED -ge $MAXDEFERRED ]]; then
  echo "Server has $CURDEFERRED deferred messages in the queue!" | mail -s "Zimbra Abuse Alert" $ZIMBRA_ADMIN
fi

if [ $CURHELD -gt 0 ]; then
  echo "Server has $CURHELD held messages in the queue!" | mail -s "Zimbra Abuse Alert" $ZIMBRA_ADMIN
  find /opt/zimbra/data/postfix/spool/hold -type f | xargs /opt/zimbra/common/sbin/postcat >/tmp/heldmsg.txt
  SASL_SENDER=$(grep "Authenticated sender:" /tmp/heldmsg.txt | awk '{print $3}' | sed 's/[)]*$//' | uniq)

  # Lock the account if we have the username
  if [ -n "${SASL_SENDER}" ]; then
    # Lock the accounts in Zimbra
    su - zimbra -c "/opt/zimbra/bin/zmprov ma $SASL_SENDER zimbraAccountStatus locked"
    # Send a notification email
    echo "Server has locked account \""$SASL_SENDER"\" for sending messages too fast" | mail -s "Zimbra Abuse Alert" $ZIMBRA_ADMIN
    # Restart Postfix to force reauthentication
    su - zimbra -c "zmmtactl restart"
  fi

  # Cleanup
  rm -f /tmp/heldmsg.txt
fi
