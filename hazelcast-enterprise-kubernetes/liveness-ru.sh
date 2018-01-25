#!/bin/bash
URL="http://$HOSTNAME:5701/hazelcast/health"

HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" $URL)
HTTP_BODY=$(echo $HTTP_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')
HTTP_STATUS=$(echo $HTTP_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

if [ ! $HTTP_STATUS -eq 200  ]; then
  echo "failure, http status: "$HTTP_STATUS
  exit 1
fi

result=$(echo $HTTP_BODY | awk '{match($0,  /Hazelcast\:\:NodeState\=([A-Z_]*)/, m)}END{print m[1]}')
if [ "$result" != "ACTIVE" ]; then exit 1; fi

result=$(echo $HTTP_BODY | awk '{match($0,  /Hazelcast\:\:ClusterSize\=([0-9]*)/, m)}END{print m[1]}')
if [ "$result" -lt 2 ]; then exit 1; fi

result=$(echo $HTTP_BODY | awk '{match($0,  /Hazelcast\:\:ClusterSafe\=([A-Z_]*)/, m)}END{print m[1]}')
if [ "$result" != "TRUE" ]; then exit 1; fi
exit 0
