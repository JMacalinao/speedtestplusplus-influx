#!/bin/bash

sleep 60

while :; do
	if [[ -z "${SPEEDTEST_SERVER_URL}" ]]; then
	 	echo "[Info][$(date)] Starting SpeedTest++..."
		JSON=$(./speedtestplusplus/SpeedTest --output json --share --line-type ${LINE_TYPE})
	else
 		echo "[Info][$(date)] Starting SpeedTest++ with specific testerver ${SPEEDTEST_SERVER_URL}..."
 		JSON=$(./speedtestplusplus/SpeedTest --test-server=${SPEEDTEST_SERVER_URL} --output json --share --line-type ${LINE_TYPE})
	fi
	DOWNLOAD=$(echo ${JSON} | jq -r .download)
	UPLOAD=$(echo ${JSON} | jq -r .upload)
	PING=$(echo ${JSON} | jq -r .ping)
	JITTER=$(echo ${JSON} | jq -r .jitter)
	SHARE=$(echo ${JSON} | jq -r .share)
	UPLOAD=$(echo $UPLOAD | sed 's/\(\.[0-9][0-9]\)[0-9]*/\1/g')
	DOWNLOAD=$(echo $DOWNLOAD | sed 's/\(\.[0-9][0-9]\)[0-9]*/\1/g')
	echo "[Info][$(date)] Speedtest results - Download: ${DOWNLOAD}, Upload: ${UPLOAD}, Ping: ${PING}, Jitter: ${JITTER}, Share: ${SHARE}"
	curl -sL -XPOST "${INFLUXDB_URL}/write?db=${INFLUXDB_DB}" --data-binary "download,host=${SPEEDTEST_HOST} value=${DOWNLOAD}"
	curl -sL -XPOST "${INFLUXDB_URL}/write?db=${INFLUXDB_DB}" --data-binary "upload,host=${SPEEDTEST_HOST} value=${UPLOAD}"
	curl -sL -XPOST "${INFLUXDB_URL}/write?db=${INFLUXDB_DB}" --data-binary "ping,host=${SPEEDTEST_HOST} value=${PING}"
	curl -sL -XPOST "${INFLUXDB_URL}/write?db=${INFLUXDB_DB}" --data-binary "jitter,host=${SPEEDTEST_HOST} value=${JITTER}"
	curl -sL -XPOST "${INFLUXDB_URL}/write?db=${INFLUXDB_DB}" --data-binary "share,host=${SPEEDTEST_HOST} value=\"${SHARE}\""
	echo "[Info][$(date)] Sleeping for ${SPEEDTEST_INTERVAL} seconds..."
	sleep ${SPEEDTEST_INTERVAL}
done
