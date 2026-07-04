# Jenkins host image for the local demo. The stock jenkins/jenkins image has none
# of the CLIs the pipeline needs, so we bake them in: docker CLI (talks to the
# host daemon via the mounted socket — Docker-out-of-Docker), aws, kubectl, kustomize.
# Plugins are pre-installed so the setup wizard can be skipped.
#
# For production you would not bake tools into the controller; you'd run jobs on a
# dedicated agent (an EC2 node or an EKS pod) that carries the toolchain and assumes
# an IAM role. This image keeps the demo to a single `docker compose up`.
FROM jenkins/jenkins:lts-jdk17

USER root

# docker CLI from Docker's apt repo (arch-aware via dpkg architecture).
RUN apt-get update \
 && apt-get install -y --no-install-recommends curl unzip ca-certificates gnupg \
 && install -m 0755 -d /etc/apt/keyrings \
 && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release; echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list \
 && apt-get update && apt-get install -y --no-install-recommends docker-ce-cli \
 && rm -rf /var/lib/apt/lists/*

# kubectl, kustomize, aws-cli v2 (arch-aware).
RUN set -eux; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in amd64) k=amd64; a=x86_64;; arm64) k=arm64; a=aarch64;; *) echo "unsupported arch $arch"; exit 1;; esac; \
    curl -fsSL "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/${k}/kubectl" -o /usr/local/bin/kubectl; \
    chmod +x /usr/local/bin/kubectl; \
    ( cd /usr/local/bin && curl -fsSL "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash ); \
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${a}.zip" -o /tmp/awscliv2.zip; \
    unzip -q /tmp/awscliv2.zip -d /tmp && /tmp/aws/install && rm -rf /tmp/aws /tmp/awscliv2.zip

# The repo is mounted from the host (a different owner), so git-as-root would flag
# "dubious ownership" when cloning it as a local SCM source. Trust all paths (demo image).
RUN git config --system --add safe.directory '*'

# Pre-install plugins so the first boot needs no setup wizard.
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Jenkins Configuration as Code: seed the pipeline job from code on startup.
COPY casc.yaml /usr/share/jenkins/casc.yaml
ENV CASC_JENKINS_CONFIG=/usr/share/jenkins/casc.yaml

# Runs as root (compose also sets user: root) so it can use the mounted docker socket.
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"
