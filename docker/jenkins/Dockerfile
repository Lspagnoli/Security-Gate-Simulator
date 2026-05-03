FROM jenkins/jenkins:lts
USER root

RUN apt-get update && apt-get install -y \
    docker.io \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64 \
    -o /usr/local/bin/cosign \
    && chmod +x /usr/local/bin/cosign

RUN curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin

RUN curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws/

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/kubectl

RUN usermod -aG docker jenkins && usermod -aG root jenkins

USER jenkins
