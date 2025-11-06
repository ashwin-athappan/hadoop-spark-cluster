#!/bin/bash

# Start Spark Master
$SPARK_HOME/sbin/start-master.sh

# Wait a moment for logs to be created
sleep 2

# Keep container running by tailing logs
find $SPARK_HOME/logs -name "spark-*.out" -type f 2>/dev/null | head -1 | xargs tail -f 2>/dev/null || tail -f /dev/null

