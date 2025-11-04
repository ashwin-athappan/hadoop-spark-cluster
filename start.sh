#!/bin/bash

set -e

echo "Building Hadoop base image for AMD64 (using Rosetta emulation)..."
docker build --platform linux/amd64 -t hadoop-base ./base

echo "Building Hadoop component images for AMD64..."
docker build --platform linux/amd64 -t hadoop-namenode ./namenode
docker build --platform linux/amd64 -t hadoop-datanode ./datanode
docker build --platform linux/amd64 -t hadoop-resourcemanager ./resourcemanager
docker build --platform linux/amd64 -t hadoop-nodemanager ./nodemanager
docker build --platform linux/amd64 -t hadoop-historyserver ./historyserver

echo "Starting Hadoop cluster..."
docker compose up -d

echo ""
echo "Hadoop cluster started successfully!"
echo ""
echo "Access points:"
echo "  - NameNode UI:        http://localhost:9870"
echo "  - ResourceManager UI: http://localhost:8088 (if resourcemanager is running)"
echo "  - SSH access:         ssh root@localhost -p 22"
echo "  - Workspace sync:     ./projects -> /workspace in container"
