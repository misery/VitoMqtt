#!/bin/bash

PID=$(pidof vcontrold)
if [ -z "$PID" ]; then
	echo "vcontrold nicht vorhanden, exit"
	exit 0
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
MQTT_COMMAND="command"

while true
do
	echo "Listening..."
	mosquitto_sub -i $MQTT_ID -h $MQTT_HOST -p $MQTT_PORT -t $MQTT_TOPIC/$MQTT_COMMAND | while read -r payload
	do
		echo "Got '$payload'"
		tmpfile=""
		if [ -n "$payload" ]; then
			tmpfile=$(mktemp -t mqtt-XXXXXXXXXX)
		fi

		if [ -f "$tmpfile" ]; then
			readarray -d ';' -t strarr <<< "$payload"
			for (( n=0; n < ${#strarr[*]}; n++))
			do
				echo "${strarr[n]}" | tr -d '\n' >> $tmpfile
				echo >> $tmpfile
			done
		fi

		/data/polling.sh $tmpfile

		if [ -f "$tmpfile" ]; then
			rm "$tmpfile"
		fi

		echo "Done"
	done
done
