#!/bin/sh

PID=`pidof vcontrold`
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

MQTT_TOPIC=VitoMqtt
MQTT_ID=${MQTT_TOPIC}-${HOSTNAME}

TPL=/tmp/mqtt.tpl

echo "#!/bin/sh" > $TPL
COUNT=`wc -l /data/commands | cut -d ' '  -f1`
for i in `seq 1 $COUNT`;
do
	echo "mosquitto_pub -i $MQTT_ID -h $MQTT_HOST -p $MQTT_PORT -t $MQTT_TOPIC/\$C$i -m \$$i" >> $TPL
done

vclient -f /data/commands -t $TPL -x /tmp/mqtt.sh
