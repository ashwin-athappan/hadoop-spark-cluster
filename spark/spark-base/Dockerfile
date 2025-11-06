# =============================================
# STAGE 1: BUILDER - Downloads and unpacks Spark
# =============================================
FROM debian:11-slim as builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gnupg \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set Spark version
ENV SPARK_VERSION=3.3.2
ENV HADOOP_VERSION=2

# Download and extract Spark
RUN set -x \
    && curl -fSL "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" -o /tmp/spark.tar.gz \
    && tar -xzf /tmp/spark.tar.gz -C /opt/ \
    && rm -rf /tmp/* \
    && mv /opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} /opt/spark-${SPARK_VERSION}

# =============================================
# STAGE 2: FINAL IMAGE - Installs Java 8 and adds Spark
# =============================================
FROM debian:11-slim

# Install runtime dependencies and Java 8 JDK (Spark 3.3.2 requires Java 8)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    net-tools \
    curl \
    netcat \
    libsnappy-dev \
    wget \
    gnupg \
    openssh-server \
    python3 \
    python3-pip \
    && mkdir -p /etc/apt/keyrings \
    && wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor > /etc/apt/keyrings/adoptium.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb bullseye main" > /etc/apt/sources.list.d/adoptium.list \
    && apt-get update \
    && apt-get install -y temurin-8-jdk \
    && apt-get purge -y --auto-remove wget gnupg \
    && rm -rf /var/lib/apt/lists/*

# Define Spark version before the COPY command
ENV SPARK_VERSION=3.3.2

# Copy Spark from the builder stage
COPY --from=builder /opt/spark-${SPARK_VERSION} /opt/spark-${SPARK_VERSION}

# Set Environment Variables
ENV JAVA_HOME="/usr/lib/jvm/temurin-8-jdk-amd64"
ENV SPARK_HOME=/opt/spark-${SPARK_VERSION}
ENV SPARK_CONF_DIR=/opt/spark-${SPARK_VERSION}/conf
ENV PATH=$JAVA_HOME/bin:$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH
ENV PYSPARK_PYTHON=python3
ENV PYSPARK_DRIVER_PYTHON=python3

# Copy entrypoint script and create directories
COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh \
    && mkdir -p $SPARK_HOME/logs \
    && mkdir -p $SPARK_HOME/work \
    && mkdir -p /var/run/sshd \
    && echo 'root:hadoop' | chpasswd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config \
    && ssh-keygen -A

ENTRYPOINT ["/entrypoint.sh"]

