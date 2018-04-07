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


if [ -n "${SPARK_EXECUTOR_ID-}" ]; then
	# run as executor if appropriate
	exec ${JAVA_HOME}/bin/java \
      "${SPARK_JAVA_OPTS[@]}" \
      -Xms$SPARK_EXECUTOR_MEMORY \
      -Xmx$SPARK_EXECUTOR_MEMORY \
      -Dspark.executor.port=$SPARK_EXECUTOR_PORT \
      -cp "$SPARK_CLASSPATH" \
      org.apache.spark.executor.CoarseGrainedExecutorBackend \
        --driver-url $SPARK_DRIVER_URL \
        --executor-id $SPARK_EXECUTOR_ID \
        --cores $SPARK_EXECUTOR_CORES \
        --app-id $SPARK_APPLICATION_ID \
        --hostname $SPARK_EXECUTOR_POD_IP
else
	# otherwise run as driver
	exec ${JAVA_HOME}/bin/java \
      "${SPARK_JAVA_OPTS[@]}" \
      -Xms$SPARK_DRIVER_MEMORY \
      -Xmx$SPARK_DRIVER_MEMORY \
      -Dspark.driver.bindAddress=$SPARK_DRIVER_BIND_ADDRESS \
      -cp "$SPARK_CLASSPATH" \
      $SPARK_DRIVER_CLASS $SPARK_DRIVER_ARGS
fi