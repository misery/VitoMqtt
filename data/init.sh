#!/bin/sh

if [ -n "$POLLING" ]; then
	echo "Use cron: $POLLING"
	echo "$POLLING /data/polling.sh" > /var/spool/cron/crontabs/root
fi

