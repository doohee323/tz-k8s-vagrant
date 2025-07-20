FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y curl build-essential iputils-ping telnet netcat

RUN apt-get install -y python3.12 python3.12-dev python3.12-distutils
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1
RUN update-alternatives --set python /usr/bin/python3.12
RUN curl -s https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
   python get-pip.py --force-reinstall && \
   rm get-pip.py
RUN apt install unzip rsync telnet netcat dnsutils iputils-ping jq -y
RUN apt install awscli jq unzip wget vim -y

RUN wget "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz"
RUN tar xvfz "eksctl_$(uname -s)_amd64.tar.gz"
RUN rm -Rf "eksctl_$(uname -s)_amd64.tar.gz"
RUN mv eksctl /usr/local/bin

RUN curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.18.9/2020-11-02/bin/linux/amd64/aws-iam-authenticator
RUN chmod +x aws-iam-authenticator
RUN mv aws-iam-authenticator /usr/local/bin

RUN apt-get install -y apt-transport-https gnupg2 curl
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update
RUN apt install kubectl=1.23.6-00 -y

RUN groupadd --gid 1000 ubuntu \
    && useradd --uid 1000 --gid 1000 -m ubuntu \
    && apt-get update \
    && apt-get install -y sudo \
    && echo ubuntu ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/ubuntu \
    && chmod 0440 /etc/sudoers.d/ubuntu

RUN apt-get install -y ca-certificates curl gnupg \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_18.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
RUN apt-get update \
    && apt-get install nodejs -y

