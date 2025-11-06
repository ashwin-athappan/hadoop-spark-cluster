# =============================================
# STAGE 1: BUILDER - Just downloads and unpacks Hadoop
# =============================================
FROM debian:11-slim as builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gnupg \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set Hadoop version
ENV HADOOP_VERSION=3.2.1

# Download, verify, and extract Hadoop, then remove unnecessary files
RUN set -x \
    && curl -fSL "https://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" -o /tmp/hadoop.tar.gz \
    && curl -fSL "https://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz.asc" -o /tmp/hadoop.tar.gz.asc \
    && curl -fSL "https://dist.apache.org/repos/dist/release/hadoop/common/KEYS" -o /tmp/KEYS \
    && gpg --import /tmp/KEYS \
    && gpg --verify /tmp/hadoop.tar.gz.asc /tmp/hadoop.tar.gz \
    && tar -xzf /tmp/hadoop.tar.gz -C /opt/ \
    && rm -rf /tmp/* \
    && cd /opt/hadoop-$HADOOP_VERSION \
    && rm -rf share/doc \
    && rm -rf share/hadoop/*/sources \
    && rm -rf share/hadoop/tools/sources \
    && rm -rf share/hadoop/client/sources \
    && find share/hadoop -name "*-tests.jar" -delete \
    && find share/hadoop -name "*-test-sources.jar" -delete

# =============================================
# STAGE 2: FINAL IMAGE - Installs compatible Java 8 and adds Hadoop
# =============================================
FROM debian:11-slim

# Install runtime dependencies and Java 8 JDK (Hadoop 3.2.1 requires Java 8)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    net-tools \
    curl \
    netcat \
    libsnappy-dev \
    wget \
    gnupg \
    openssh-server \
    && mkdir -p /etc/apt/keyrings \
    && wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor > /etc/apt/keyrings/adoptium.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb bullseye main" > /etc/apt/sources.list.d/adoptium.list \
    && apt-get update \
    && apt-get install -y temurin-8-jdk \
    && apt-get purge -y --auto-remove wget gnupg \
    && rm -rf /var/lib/apt/lists/*

# Define Hadoop version before the COPY command
ENV HADOOP_VERSION=3.2.1

# Copy Hadoop from the builder stage
COPY --from=builder /opt/hadoop-$HADOOP_VERSION /opt/hadoop-$HADOOP_VERSION

# Set Environment Variables
ENV JAVA_HOME="/usr/lib/jvm/temurin-8-jdk-amd64"
ENV HADOOP_HOME=/opt/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=/etc/hadoop
ENV PATH=$JAVA_HOME/bin:$HADOOP_HOME/bin:$PATH
ENV MULTIHOMED_NETWORK=1

# Copy entrypoint script and create directories in one layer
COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh \
    && ln -s $HADOOP_HOME/etc/hadoop $HADOOP_CONF_DIR \
    && mkdir $HADOOP_HOME/logs \
    && mkdir /hadoop-data \
    && mkdir -p /var/run/sshd \
    && echo 'root:hadoop' | chpasswd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config \
    && ssh-keygen -A

ENTRYPOINT ["/entrypoint.sh"]