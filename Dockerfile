#
# Cloudresty CloudCLI
#

# Base Image
FROM    debian:12.6-slim

# Image details
LABEL   org.opencontainers.image.authors="Cloudresty" \
        org.opencontainers.image.url="https://hub.docker.com/r/cloudresty/cloudcli" \
        org.opencontainers.image.source="https://github.com/cloudresty/cloudcli" \
        org.opencontainers.image.version="v1.0.0" \
        org.opencontainers.image.revision="v1.0.0-2023-11-29" \
        org.opencontainers.image.vendor="Cloudresty" \
        org.opencontainers.image.licenses="MIT" \
        org.opencontainers.image.title="cloudcli" \
        org.opencontainers.image.description="CloudCLI is a Docker image that contains all the CLI tools for the major cloud providers."

ENV     LANG=C.UTF-8

# Update and Upgrade
RUN     apt-get update && \
        apt-get upgrade -y && \
        apt-get clean

# Install Packages
RUN     apt-get install -y \
        apt-transport-https \
        apparmor \
        apparmor-utils \
        ca-certificates \
        curl \
        git \
        gnupg \
        gnupg2 \
        jq \
        unzip \
        vim \
        zsh

# Set zsh as default shell
RUN     chsh -s $(which zsh)

# Install Oh My Zsh
RUN     apt-get install -y zsh && \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install Powerlevel10K Theme
RUN     git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Set Powerlevel10K Theme
RUN     sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' ~/.zshrc

# Install ZSH Plugins
RUN     git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Set ZSH Plugins
RUN     sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' ~/.zshrc

# Copy and source .p10k.zsh
COPY    .p10k.zsh /root/.p10k.zsh
RUN     echo "source ~/.p10k.zsh" >> ~/.zshrc

# Set up CloudCLI welcome message
COPY    20-welcome /etc/update-motd.d/20-welcome
RUN     chmod +x /etc/update-motd.d/20-welcome && \
        echo "/etc/update-motd.d/20-welcome" >> ~/.zshrc && \
        echo exit | script -qec zsh /dev/null

# Set Workdir
WORKDIR /root

#
# Cloud CLI Tools
#

# Install Alibaba Cloud CLI
RUN     curl -fsSL https://raw.githubusercontent.com/aliyun/aliyun-cli/HEAD/install.sh | bash
RUN     rm aliyun-cli-linux-latest-amd64.tgz

# Install AWS CLI
RUN     curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip && \
        unzip awscliv2.zip && \
        ./aws/install && \
        rm awscliv2.zip aws

# Install Azure CLI
RUN     curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install Google Cloud SDK
RUN     echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
        curl -sL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
        apt-get update && \
        apt-get install -y google-cloud-sdk
