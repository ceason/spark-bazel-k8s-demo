#!/usr/bin/env bash
[ "$DEBUG" = "1" ] && set -x
set -euo pipefail
err_report() { echo "errexit on line $(caller)" >&2; }
trap err_report ERR

# set up environment and classpath
export LD_LIBRARY_PATH=/opt/hadoop/lib/native
export SPARK_HOME=/opt/spark
readarray -t SPARK_JAVA_OPTS < <(env|grep SPARK_JAVA_OPT_|grep -v '\-Dspark.jars=/fake.jar'|sed 's/[^=]*=\(.*\)/\1/g')
SPARK_CLASSPATH="/app:/app/*:${SPARK_HOME}/jars/*"
[ -n "${SPARK_MOUNTED_CLASSPATH-}" ]        && SPARK_CLASSPATH="$SPARK_MOUNTED_CLASSPATH:$SPARK_CLASSPATH"
[ -n "${SPARK_EXECUTOR_EXTRA_CLASSPATH-}" ] && SPARK_CLASSPATH="$SPARK_EXECUTOR_EXTRA_CLASSPATH:$SPARK_CLASSPATH"
[ -n "${SPARK_EXTRA_CLASSPATH-}" ]          && SPARK_CLASSPATH="$SPARK_EXTRA_CLASSPATH:$SPARK_CLASSPATH"
[ -n "${HADOOP_CONF_DIR-}" ]                && SPARK_CLASSPATH="$HADOOP_CONF_DIR:$SPARK_CLASSPATH"

# todo: find cleaner way to reference classpath file
if cp_file=$(find /app -type f -name \*.classpath); then
	SPARK_CLASSPATH="/app:$(cat ${cp_file})"
fi

mkdir -p $SPARK_HOME/work-dir
cd $SPARK_HOME/work-dir

# copy in mounted files as appropriate
[ -n "${SPARK_MOUNTED_FILES_DIR-}" ] && cp -R "$SPARK_MOUNTED_FILES_DIR/." $SPARK_HOME/work-dir
[ -n "${SPARK_MOUNTED_FILES_FROM_SECRET_DIR-}" ] && cp -R "$SPARK_MOUNTED_FILES_FROM_SECRET_DIR/." $SPARK_HOME/work-dir

SPARK_K8S_CMD="$1"
case "$SPARK_K8S_CMD" in
	init)
		echo "Ignoring 'init' command and moving on.."
		exit 0
		;;
	executor)
		exec ${JAVA_HOME}/bin/java \
		  -Xms$SPARK_EXECUTOR_MEMORY \
		  -Xmx$SPARK_EXECUTOR_MEMORY \
		  "${SPARK_JAVA_OPTS[@]}" \
		  -cp "$SPARK_CLASSPATH" \
		  org.apache.spark.executor.CoarseGrainedExecutorBackend \
			--driver-url $SPARK_DRIVER_URL \
			--executor-id $SPARK_EXECUTOR_ID \
			--cores $SPARK_EXECUTOR_CORES \
			--app-id $SPARK_APPLICATION_ID \
			--hostname $SPARK_EXECUTOR_POD_IP
		;;

	*)
		TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
		POD_INFO=$(curl -sSk -H "Authorization: Bearer $TOKEN" https://kubernetes.default.svc/api/v1/namespaces/$POD_NAMESPACE/pods/$POD_NAME)
		DRIVER_IMAGE=$(echo "$POD_INFO"|jq '.spec.containers[]|select(.name == "spark-kubernetes-driver")|.image' -r)
		APP_LABEL=$(echo "$POD_INFO"|jq '.metadata.labels.app' -r)
		exec ${JAVA_HOME}/bin/java \
		  -Dspark.submit.deployMode=cluster \
		  -Dspark.kubernetes.namespace=${POD_NAMESPACE} \
		  -Dspark.kubernetes.driver.pod.name=${POD_NAME} \
		  -Dspark.kubernetes.executor.podNamePrefix=${POD_NAME} \
		  -Dspark.executor.instances=${SPARK_EXECUTOR_INSTANCES} \
		  -Dspark.driver.host=$POD_IP \
		  -Dspark.driver.bindAddress=$POD_IP \
		  -Dspark.kubernetes.executor.label.app=$APP_LABEL \
		  -Dspark.driver.blockManager.port=7079 \
		  -Dspark.app.id=$APP_LABEL-$(date +%s) \
		  -Dspark.app.name=$APP_LABEL \
		  -Dspark.kubernetes.authenticate.driver.serviceAccountName=$POD_SERVICE_ACCOUNT_NAME \
		  -Dspark.kubernetes.container.image=${DRIVER_IMAGE} \
		  -Dspark.driver.port=7078 \
		  -Dspark.master=k8s://kubernetes.default.svc \
		  -Xms$SPARK_DRIVER_MEMORY \
		  -Xmx$SPARK_DRIVER_MEMORY \
		  "${SPARK_JAVA_OPTS[@]}" \
		  -cp "$SPARK_CLASSPATH" \
		  "$MAIN_CLASS" "$@"
		;;

esac
