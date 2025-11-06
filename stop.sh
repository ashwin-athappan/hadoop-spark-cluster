#!/bin/bash

set -e

# Parse arguments
CLUSTER_TYPE=""
REMOVE_VOLUMES=false

while [[ $# -gt 0 ]]; do
    case $1 in
        hadoop|spark)
            CLUSTER_TYPE="$1"
            shift
            ;;
        -v|--volumes)
            REMOVE_VOLUMES=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [hadoop|spark] [-v|--volumes]"
            echo "  hadoop|spark - Cluster type to stop (default: hadoop)"
            echo "  -v|--volumes - Remove volumes (WARNING: deletes data)"
            exit 1
            ;;
    esac
done

# Default to hadoop if not specified
if [ -z "$CLUSTER_TYPE" ]; then
    CLUSTER_TYPE="hadoop"
fi

if [ "$CLUSTER_TYPE" == "hadoop" ]; then
    CLUSTER_DIR="hadoop"
    COMPOSE_FILE="docker-compose.yml"
    IMAGES="hadoop-base hadoop-namenode hadoop-datanode hadoop-resourcemanager hadoop-nodemanager hadoop-historyserver"
    CLUSTER_NAME="Hadoop"
    DATA_TYPE="HDFS data and job history"
elif [ "$CLUSTER_TYPE" == "spark" ]; then
    CLUSTER_DIR="spark"
    COMPOSE_FILE="docker-compose.yml"
    IMAGES="spark-base spark-master spark-worker spark-history"
    CLUSTER_NAME="Spark"
    DATA_TYPE="Spark logs and event logs"
else
    echo "Invalid cluster type: $CLUSTER_TYPE"
    echo "Usage: $0 [hadoop|spark] [-v|--volumes]"
    exit 1
fi

cd $CLUSTER_DIR

if [ "$REMOVE_VOLUMES" = true ]; then
    echo "Stopping $CLUSTER_NAME cluster and removing volumes..."
    echo "⚠️  WARNING: This will DELETE all $DATA_TYPE!"
    docker compose -f $COMPOSE_FILE down -v
else
    echo "Stopping $CLUSTER_NAME cluster (preserving volumes)..."
    echo "💾 Volumes are preserved - your data will be kept"
    echo "   To remove volumes, run: ./stop.sh $CLUSTER_TYPE -v"
    docker compose -f $COMPOSE_FILE down
fi

cd ..

echo "Removing built $CLUSTER_NAME images..."
docker rmi -f $IMAGES 2>/dev/null || true

echo "$CLUSTER_NAME cluster stopped successfully!"
