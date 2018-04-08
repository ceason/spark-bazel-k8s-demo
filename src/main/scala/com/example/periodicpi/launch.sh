#!/usr/bin/env bash
[ "$DEBUG" = "1" ] && set -x
set -euo pipefail
err_report() { echo "errexit on line $(caller)" >&2; }
trap err_report ERR
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

APP_LABEL=periodicpi

port-forward-ui(){
	until DRIVER_POD=$(kubectl get po -l "app=${APP_LABEL},spark-role=driver"|tail -1|awk '{print $1}') && [ -n "$DRIVER_POD" ]; do
		echo "Waiting for driver..."
		sleep 1
	done
	until kubectl port-forward $DRIVER_POD 4040:4040; do
		echo "Retrying connection to driver..."
		sleep 1
	done
}

echo "
	* Building docker image
	* Deploying k8s manifests
"
bazel run //src/main/scala/com/example/periodicpi:cronjob|kubectl apply -f -

echo "
	* Forwarding UI to http://localhost:4040
	* Tailing logs from all pods (app=$APP_LABEL)
"
port-forward-ui &
stern --tail 10 --color always -l app=$APP_LABEL &

wait -n
kill $(jobs -p)

