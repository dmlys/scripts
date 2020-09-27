#!/bin/bash

# >> /etc/pam.d/sshd
# session optional pam_exec.so seteuid ${path to this script}


if [[ ${PAM_TYPE} = "open_session" && $PAM_RHOST != 192.168.*.* ]]; then

	host="`hostname`"
	BODY="\
From: \"Service Account\" <from>
To: <to>
Subject: SSH Login: $PAM_USER from $PAM_RHOST on $host

SSH login was successful:
  	User:         $PAM_USER
	User IP Host: $PAM_RHOST
	Service:      $PAM_SERVICE
	TTY:          $PAM_TTY
	Date:         `date`
	Server:       `uname -a`
"
	#echo -n "$BODY"
	echo -n "$BODY" | curl --url smtps://$addr:465 --ssl-reqd --mail-from "$src_email" --mail-rcpt '$dest_email' --user $user:$pass --insecure --upload-file -
fi
