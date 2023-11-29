# CloudCLI

**CloudCLI** is a Debian-based Docker image from [Cloudresty](https://cloudresty.com) that contains a collection of command-line tools for interacting with cloud providers such as AWS, Azure, GCP, and Alibaba Cloud. It can be used for various tasks such as managing cloud resources, inter-cloud migrations, and multi-cloud deployments.

&nbsp;

## CLI Tools Included

The following tools are included in CloudCLI:

- [AWS CLI](https://aws.amazon.com/cli/)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/)
- [Google Cloud SDK](https://cloud.google.com/sdk/)
- [Alibaba Cloud CLI](https://www.alibabacloud.com/help/en/alibaba-cloud-cli)

&nbsp;

## Version

Latest version: `v1.0.0`</br>
Release version: `v1.0.0-2023-11-29`</br>
Docker image: `cloudresty/cloudcli:v1.0.0` or `cloudresty/cloudcli:latest`</br>

&nbsp;

## CloudCLI Usage

### Docker Usage

A few examples of how to use CloudCLI as a Docker container.

&nbsp;

#### Docker container

```bash
docker run \
    --interactive \
    --tty \
    --rm \
    --name cloudcli \
    --hostname cloudcli \
    cloudresty/cloudcli:latest zsh
```

&nbsp;

#### Docker container with mounted credentials

```bash
docker run \
    --interactive \
    --tty \
    --rm \
    --name cloudcli \
    --hostname cloudcli \
    --volume ~/.aws:/root/.aws \
    cloudresty/cloudcli:latest zsh
```

&nbsp;

## Kubernetes Usage

CloudCLI can be used as a shell pod within a Kubernetes cluster. The examples below show how to use CloudCLI as a Kubernetes pod assuming that the credentials are passed in as environment variables.

&nbsp;

### Kubernetes Pod Usage with Service Account

```yaml
#
# CloudCLI Namespace
#

apiVersion: v1
kind: Namespace
metadata:
  name: cloudresty-system
```

```bash
cloudcli run \
    --namespace cloudresty-system \
        cloudcli \
        --stdin \
        --tty \
        --rm \
        --restart Never \
        --image cloudresty/cloudcli:latest \
        --image-pull-policy IfNotPresent \
        --command -- zsh
```

&nbsp;

---
Copyright &copy; [Cloudresty](https://cloudresty.com)
