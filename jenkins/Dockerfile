FROM jenkins/jenkins:lts-jdk17

USER root

RUN apt-get update && \
    apt-get install -y docker.io curl gnupg build-essential \
    python3 python3-pip python3-venv nodejs npm && \
    python3 -m venv /var/jenkins_home/taurus-venv && \
    /bin/bash -c "source /var/jenkins_home/taurus-venv/bin/activate && pip install bzt"

USER jenkins
