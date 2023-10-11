# 使用jenkinse官方的image為基底，在後續的指令客製環境與套件
FROM jenkins/jenkins:2.414.2-lts-jdk17

# 指定Jenkins帳號密碼
ENV JENKINS_USER admin
ENV JENKINS_PASS admin

# 跳過Jenkins設定流程
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

# 安裝jenkins plugins
COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

#Passing Jenkins launcher parameters
#COPY --chown=jenkins:jenkins certificate.pfx /var/lib/jenkins/certificate.pfx
#COPY --chown=jenkins:jenkins https.key /var/lib/jenkins/pk
#ENV JENKINS_OPTS --httpPort=-1 --httpsPort=8083 --httpsKeyStore=/var/lib/jenkins/certificate.pfx --httpsKeyStorePassword=Password12
#ENV JENKINS_SLAVE_AGENT_PORT 50001
#EXPOSE 8083

# 設置運行映像時使用root使用者
USER root
# 安裝與更新linux套件
RUN apt update && \
    apt -y install apt-transport-https \
      ca-certificates \
      curl \
      gnupg2 \
      bc \
      software-properties-common \
      jq && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli && \
    apt clean && rm -rf awscliv2.zip && rm -rf aws && rm -rf /var/lib/apt/lists/*

USER jenkins