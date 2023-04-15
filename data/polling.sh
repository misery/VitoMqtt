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

if [ "$1" = "" ]; then
	cmds="/data/commands"
else
	cmds="$1"
fi

cmdName="${cmds//\//_}"

MQTT_TOPIC=VitoMqtt
MQTT_ID="${MQTT_TOPIC}-${HOSTNAME}$cmdName"

TPL="/tmp/mqtt$cmdName.tpl"
SCRIPT="/tmp/mqtt$cmdName.sh"

echo "#!/bin/bash" > $TPL
COUNT=`wc -l $cmds | cut -d ' '  -f1`
for i in `seq 1 $COUNT`;
do
	echo "if [ \"\$E$i\" = \"OK\" ]; then" >> $TPL
		echo "if [[ \"\$C$i\" = \"*Str\" ]]; then" >> $TPL
			echo "value='\$R$i'" >> $TPL
		echo "else" >> $TPL
			echo "value='\$$i'" >> $TPL
		echo "fi" >> $TPL

		echo "mosquitto_pub -i $MQTT_ID -h $MQTT_HOST -p $MQTT_PORT -t $MQTT_TOPIC/\$C$i -m \"\$value\"" >> $TPL
	echo "fi" >> $TPL
done

vclient -f $cmds -t $TPL -x $SCRIPT
rm "$TPL"
rm "$SCRIPT"

