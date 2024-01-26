#!/bin/sh

if [ -n "$POLLING" ]; then
	echo "Use cron: $POLLING"
	echo "$POLLING polling.sh" > /var/spool/cron/crontabs/root
fi

