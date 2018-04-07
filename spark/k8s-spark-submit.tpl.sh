#!/usr/bin/env bash
[ "$DEBUG" = "1" ] && set -x
set -euo pipefail
err_report() { echo "errexit on line $(caller)" >&2; }
trap err_report ERR

CONTEXT="${K8S_CONTEXT}"
NAMESPACE="${K8S_NAMESPACE}"
[ -z "${CONTEXT}" ]   && CONTEXT=$(kubectl config current-context)
[ -z "${NAMESPACE}" ] && NAMESPACE=$(kubectl config get-contexts ${CONTEXT}|tail -1|awk '{print $NF}')
K8S_CLUSTER=$(kubectl config get-contexts ${CONTEXT}|tail -1|awk '{print $3}')
K8S_SERVER=$(kubectl config view -o jsonpath="{.clusters[?(@.name=='${K8S_CLUSTER}')].cluster.server}")

# we'll use this as a label for this specific submission
SPARK_SUBMIT_ID="$(whoami)-$(date +%s)"

F="${IMAGE_PUSH_OUTPUT_FILE}"
IMAGE_DIGEST=$(cat "$F"|awk '{print $NF}')
IMAGE_REPO=$(cat "$F"|awk '{print $1}'|cut -d':' -f1)
IMAGE="${IMAGE_REPO}@${IMAGE_DIGEST}"

port-forward-ui(){
	set -x
	until DRIVER_POD=$(kubectl get po -l "spark-submit-id=${SPARK_SUBMIT_ID},spark-role=driver"|tail -1|awk '{print $1}') && [ -n "$DRIVER_POD" ]; do
		echo "Waiting for driver..."
		sleep 1
	done

	until kubectl port-forward $DRIVER_POD 4040:4040; do
		echo "Retrying connection to driver..."
		sleep 1
	done

}
../apache_spark_on_k8s/bin/spark-submit \
  --deploy-mode cluster \
  --class ${MAIN_CLASS} \
  --master k8s://${K8S_SERVER} \
  --kubernetes-namespace ${NAMESPACE} \
  --conf spark.executor.instances=5 \
  --conf spark.app.name=${K8S_APP_NAME} \
  --conf spark.kubernetes.driver.docker.image=${IMAGE} \
  --conf spark.kubernetes.docker.image.pullPolicy=Always \
  --conf spark.kubernetes.executor.docker.image=${IMAGE} \
  --conf spark.kubernetes.driver.label.app=${K8S_APP_NAME} \
  --conf spark.kubernetes.executor.label.app=${K8S_APP_NAME} \
  --conf spark.kubernetes.driver.label.spark-submit-id=${SPARK_SUBMIT_ID} \
  --conf spark.kubernetes.executor.label.spark-submit-id=${SPARK_SUBMIT_ID} \
  --conf spark.kubernetes.authenticate.driver.serviceAccountName=${K8S_SERVICE_ACCOUNT_NAME} \
  ${K8S_APP_JAR} "$@" &

stern --tail 1000 \
  --context="${CONTEXT}" \
  --namespace="${NAMESPACE}" \
  --color always \
  -l spark-submit-id=${SPARK_SUBMIT_ID} &

port-forward-ui &

wait -n
kill $(jobs -p)