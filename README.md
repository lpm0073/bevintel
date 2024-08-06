# Open edX Redwood tutor build

- client contact: Stélio, +27 82 340 9120, stelio.gouveia@gmail.com
- consultant contact: Lawrence McDaniel +1 (617) 834-6172, lpm0073@gmail.com, https://lawrencemcdaniel.com
- start date: 10-aug-2024
- aws region: us-west-1

Migration from Koa native build to tutor redwood.

Original source server:

```bash
Host bi-dev
  Hostname training-staging.beverageintelligence.com
  User ubuntu
  IdentityFile ~/.ssh/bi-uni-prod-clone.pem
  IdentitiesOnly yes
```

Target server:

```bash
Host bi
  Hostname ???.beverageintelligence.com
  User ubuntu
  IdentityFile ~/.ssh/bi-uni-prod-clone.pem
  IdentitiesOnly yes
```

AWS S3 Source data:

- s3://training-staging.beverageintelligence.com/backups/openedx-mysql-20240807T060001.tgz
- s3://training-staging.beverageintelligence.com/backups/mongo-dump-20240807T060001.tgz

AWS IAM User: arn:aws:iam::595273754238:user/lawrence


## EC2 AMI

N/A. we're starting with a clone of the Koa instance, which is built on Ubuntu 16.04 LTS and the 
upgrade is still pending.


## ubuntu packages

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install python3 python3-pip libyaml-dev python3-venv
# sudo add-apt-repository ppa:deadsnakes/ppa -y
```

## Docker installation

https://docs.docker.com/engine/install/ubuntu/

### Add Docker's official GPG key

```bash
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

### Install Docker CE

```bash
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose
sudo apt update
sudo usermod -a -G docker ubuntu
logout
sudo docker run hello-world
docker-compose version
```

## python virtual environment

```bash
python3 -m venv venv
source venv/bin/activate
pip install setuptools
pip install "tutor[full]==12.2.0"
tutor local quickstart
```

## install aws cli

```bash
sudo snap install aws-cli --classic
```
