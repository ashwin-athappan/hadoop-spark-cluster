#!/bin/bash

set -e

# Check if user wants to remove volumes
REMOVE_VOLUMES=false
if [ "$1" == "-v" ] || [ "$1" == "--volumes" ]; then
    REMOVE_VOLUMES=true
fi

if [ "$REMOVE_VOLUMES" = true ]; then
    echo "Stopping Hadoop cluster and removing volumes..."
    echo "⚠️  WARNING: This will DELETE all HDFS data and job history!"
    docker compose down -v
else
    echo "Stopping Hadoop cluster (preserving volumes)..."
    echo "💾 Volumes are preserved - your HDFS data will be kept"
    echo "   To remove volumes, run: ./stop.sh -v"
    docker compose down
fi

echo "Removing built Hadoop images..."
docker rmi -f hadoop-base hadoop-namenode hadoop-datanode hadoop-resourcemanager hadoop-nodemanager hadoop-historyserver 2>/dev/null || true

echo "Hadoop cluster stopped successfully!"
