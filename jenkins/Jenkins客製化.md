# Jenkins客製化

## Tools && Files

1. Docker
2. Docker Compose v2
3. Jenkins official docker image
4. plugins list
5. Dockerfile
6. docker-compose.yml 

[官方文件](https://github.com/jenkinsci/docker#preinstalling-plugins)

## Execute

```console
.
├── Dockerfile
├── docker-compose.yaml
├── plugins.txt
```

```console

#docker build && test
docker build --no-cache --compress -t jenkins:v1.0 -f Dockerfile .
docker run -d -p 8080:8080 jenkins:v1.0

#offline env
docker save -o jenkins-v1.0.tar jenkins:v1.0
docker load -i jenkins-v1.0.tar

#docker compose

docker compose up -d
docker logs jenkins

#folder permission

chmod -R 755 data

```

## Build Custom Image

### Dockerfile
```dockerfile
# 使用jenkinse官方的image為基底，在後續的指令客製環境與套件
FROM jenkins/jenkins:2.414.1-lts-jdk17

# 指定Jenkins帳號密碼
ENV JENKINS_USER admin
ENV JENKINS_PASS admin

# 跳過Jenkins設定流程
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

# 安裝jenkins plugins
COPY plugins.txt /usr/share/jenkins/ref/
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# 設置運行映像時使用root使用者
USER root
# 安裝與更新linux套件
RUN apt-get update && \
    apt-get -y install apt-transport-https \
      ca-certificates \
      curl \
      gnupg2 \
      bc \
      software-properties-common \
      jq && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli && \
    apt-get clean && rm -rf awscliv2.zip && rm -rf aws && rm -rf /var/lib/apt/lists/*

USER jenkins

```

> amd64: https://awscli.amazonaws.com/awscli-exe-linux-amd64.zip
> arm: https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip

### plugins.txt
```shell

trilead-api
cloudbees-folder
antisamy-markup-formatter
jdk-tool
script-security
command-launcher
structs
workflow-step-api
token-macro
bouncycastle-api
build-timeout
credentials
plain-credentials
ssh-credentials
credentials-binding
scm-api
workflow-api
timestamper
workflow-support
durable-task
workflow-durable-task-step
junit
matrix-project
resource-disposer
ws-cleanup
ant
workflow-scm-step
workflow-cps
workflow-job
apache-httpcomponents-client-4-api
display-url-api
mailer
workflow-basic-steps
gradle
pipeline-milestone-step
jackson2-api
pipeline-input-step
pipeline-stage-step
pipeline-graph-analysis
pipeline-rest-api
pipeline-stage-view
pipeline-build-step
pipeline-model-api
pipeline-model-extensions
jsch
branch-api
workflow-multibranch
authentication-tokens
pipeline-stage-tags-metadata
pipeline-model-definition
lockable-resources
workflow-aggregator
git
git-client
git-parameter
gitlab-plugin
pipeline-github-lib
mapdb-api
subversion
ssh-slaves
pam-auth
ldap
email-ext
blueocean
google-oauth-plugin
role-strategy
gitlab-plugin
oauth-credentials
build-user-vars-plugin
thinBackup
uno-choice
description-setter
jobConfigHistory
simple-theme-plugin
google-login
Office-365-Connector
mask-passwords
aws-credentials
```

### docker-compose.yml 

```dockerfile

services:
  jenkins:
    image: jenkins-v1.0
    privileged: true
    user: jenkins
    restart: unless-stopped
    environment:
      - TZ=Asia/Taipei
    ports:
      - '8080:8080'
    volumes:
      - ./data:/var/jenkins_home
    container_name: jenkins

```