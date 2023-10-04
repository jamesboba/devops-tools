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