#!/bin/bash

PID=$(pidof vcontrold)
if [ -z "$PID" ]; then
	echo "vcontrold nicht vorhanden, exit"
#	exit 0
fi

if [ -z "$MQTT_HOST" ]; then
	echo "MQTT_HOST undefined, exit"
	exit 1
fi

if [ -z "$MQTT_PORT" ]; then
	MQTT_PORT=1883
fi

trap exit INT
trap exit TERM

MQTT_TOPIC=VitoMqtt
MQTT_ID="${MQTT_TOPIC}-${HOSTNAME}-listener"

while true
do
	echo "Listening..."
	mosquitto_sub -i $MQTT_ID -h $MQTT_HOST -p $MQTT_PORT -t $MQTT_TOPIC/command | while read -r payload
	do
		echo "Got $payload"
		tmpfile=$(mktemp -t mqtt-XXXXXXXXXX)
		readarray -d ';' -t strarr <<< "$payload"
		for (( n=0; n < ${#strarr[*]}; n++))
		do
			echo "${strarr[n]}" | tr -d '\n' >> $tmpfile
			echo >> $tmpfile
		done

		/data/polling.sh $tmpfile
		rm "$tmpfile"
		echo "Done"
	done
done
