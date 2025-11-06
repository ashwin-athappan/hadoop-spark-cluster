#!/bin/bash

set -e

# Determine cluster type (default to hadoop if not specified)
CLUSTER_TYPE=${1:-hadoop}

if [ "$CLUSTER_TYPE" != "hadoop" ] && [ "$CLUSTER_TYPE" != "spark" ]; then
    echo "Usage: $0 [hadoop|spark]"
    echo "  hadoop - Start Hadoop cluster (default)"
    echo "  spark  - Start Spark cluster"
    exit 1
fi

if [ "$CLUSTER_TYPE" == "hadoop" ]; then
    echo "=========================================="
    echo "Building Hadoop cluster..."
    echo "=========================================="

    cd hadoop

    echo "Building Hadoop base image for AMD64 (using Rosetta emulation)..."
    docker build --platform linux/amd64 -t hadoop-base ./base

    echo "Building Hadoop component images for AMD64..."
    docker build --platform linux/amd64 -t hadoop-namenode ./namenode
    docker build --platform linux/amd64 -t hadoop-datanode ./datanode
    docker build --platform linux/amd64 -t hadoop-resourcemanager ./resourcemanager
    docker build --platform linux/amd64 -t hadoop-nodemanager ./nodemanager
    docker build --platform linux/amd64 -t hadoop-historyserver ./historyserver

    echo "Starting Hadoop cluster..."
    docker compose -f docker-compose.yml up -d

    cd ..

    echo ""
    echo "✅ Hadoop cluster started successfully!"
    echo ""
    echo "Access points:"
    echo "  - NameNode UI:        http://localhost:9870"
    echo "  - ResourceManager UI: http://localhost:8088 (if resourcemanager is running)"
    echo "  - SSH access:         ssh root@localhost -p 22"
    echo "  - Workspace sync:     ./projects -> /workspace in container"

elif [ "$CLUSTER_TYPE" == "spark" ]; then
    echo "=========================================="
    echo "Building Spark cluster..."
    echo "=========================================="

    cd spark

    echo "Building Spark base image for AMD64 (using Rosetta emulation)..."
    docker build --platform linux/amd64 -t spark-base ./spark-base

    echo "Building Spark component images for AMD64..."
    docker build --platform linux/amd64 -t spark-master ./spark-master
    docker build --platform linux/amd64 -t spark-worker ./spark-worker1
    docker build --platform linux/amd64 -t spark-history ./spark-history

    echo "Starting Spark cluster..."
    docker compose -f docker-compose.yml up -d

    cd ..

    echo ""
    echo "✅ Spark cluster started successfully!"
    echo ""
    echo "Access points:"
    echo "  - Spark Master UI:    http://localhost:8080"
    echo "  - Spark Worker1 UI:   http://localhost:8081"
    echo "  - Spark Worker2 UI:   http://localhost:8082"
    echo "  - Spark History UI:   http://localhost:18080"
    echo "  - Spark Master URL:   spark://localhost:7077"
    echo "  - SSH access:          ssh root@localhost -p 22"
    echo "  - Workspace sync:     ./projects -> /workspace in container"
fi
