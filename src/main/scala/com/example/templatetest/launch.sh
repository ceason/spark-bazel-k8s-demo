#!/usr/bin/env bash
[ "$DEBUG" = "1" ] && set -x
set -euo pipefail
err_report() { echo "errexit on line $(caller)" >&2; }
trap err_report ERR
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

APP_LABEL=templatetest

driver-pod(){
	kubectl get po -l "app=${APP_LABEL},spark-role=driver"|tail -1|awk '{print $1}'
}

port-forward-ui(){
	until kubectl port-forward $(driver-pod) 4040:4040; do
		echo "Retrying connection to driver..."
		sleep 1
	done
}

echo "
	* Building docker image
	* Deploying k8s manifests
"
bazel run //src/main/scala/com/example/templatetest:deployment|kubectl delete -f -||true
bazel run //src/main/scala/com/example/templatetest:deployment|kubectl apply -f -

echo "
	* Forwarding UI to http://localhost:4040
	* Tailing logs from all pods (app=$APP_LABEL)
"
port-forward-ui &
stern --tail 10 --color always -l app=$APP_LABEL &

wait -n
kill $(jobs -p)

