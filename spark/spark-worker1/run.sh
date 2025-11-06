#!/bin/bash

# Wait for Spark Master to be ready
master_host=$(echo ${SPARK_MASTER:-spark://spark-master:7077} | sed 's|spark://||' | sed 's|:.*||')
master_port=$(echo ${SPARK_MASTER:-spark://spark-master:7077} | sed 's|spark://||' | sed 's|.*:||')
if [ -z "$master_port" ]; then
    master_port=7077
fi

echo "Waiting for Spark Master at $master_host:$master_port..."
until nc -z $master_host $master_port; do
    echo "Waiting for Spark Master..."
    sleep 2
done
echo "Spark Master is ready!"

# Start Spark Worker
$SPARK_HOME/sbin/start-worker.sh ${SPARK_MASTER:-spark://spark-master:7077}

# Wait a moment for logs to be created
sleep 2

# Keep container running by tailing logs
find $SPARK_HOME/logs -name "spark-*.out" -type f 2>/dev/null | head -1 | xargs tail -f 2>/dev/null || tail -f /dev/null

