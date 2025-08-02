FROM jenkins/jenkins:lts

USER root

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV JMETER_VERSION=5.6.3
ENV NODE_VERSION=18

# Install tools
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    python3 python3-pip python3-full python3-venv \
    curl wget unzip nano git \
    gnupg lsb-release build-essential ca-certificates \
    coreutils

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && \
    apt-get install -y nodejs

# Install JMeter
RUN wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz && \
    tar -xvzf apache-jmeter-${JMETER_VERSION}.tgz -C /opt && \
    rm apache-jmeter-${JMETER_VERSION}.tgz
ENV JMETER_HOME=/opt/apache-jmeter-${JMETER_VERSION}
ENV PATH=$JMETER_HOME/bin:/opt/taurus/bin:$PATH

# Install Taurus
RUN python3 -m venv /opt/taurus && \
    /opt/taurus/bin/pip install --upgrade pip && \
    /opt/taurus/bin/pip install bzt

# Create directories and set permissions for persistent volumes
RUN mkdir -p /home/jenkins/test && \
    mkdir -p /var/jenkins_home && \
    chown -R jenkins:jenkins /home/jenkins && \
    chown -R jenkins:jenkins /var/jenkins_home && \
    chown -R jenkins:jenkins /opt/apache-jmeter-${JMETER_VERSION} && \
    chown -R jenkins:jenkins /opt/taurus

# Set working directory
WORKDIR /home/jenkins/test

# Switch back to jenkins user
USER jenkins

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/login || exit 1
