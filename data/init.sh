#!/bin/sh

if [ -z "$POLLING" ]; then
	POLLING="*/5 * * * *"
fi

echo "Use cron: $POLLING"
echo "$POLLING /data/polling.sh" > /var/spool/cron/crontabs/root
