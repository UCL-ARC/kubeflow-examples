---
title: Hello world examples
description:
weight: 2
---

Hello world examples for kubeflow trainer in unified-AI that use files [hello-world-customised-images](https://github.com/ucl-arc-environments/kubeflow-trainer-examples/tree/main/hello-world-customised-images).

## Customised images

### Creating a container registry

To host and distribute container images, you can use the [GitHub Container Registry (GHCR)](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
This registry allows you to store, manage, and version Docker images directly through GitHub for seamless integration with your CI/CD workflows.

### Build Dockerfile container
The following variables names are used in the terminal to help to build docker images.
```bash
IMAGENAME=kubeflowtrainerimage
VERSION_ID=v0.0.1
docker build -t ${IMAGENAME}:${VERSION_ID} -f Dockerfile .
```
See an example of output logs for `docker images`:
```bash
IMAGE                               ID             DISK USAGE   CONTENT SIZE   EXTRA
kubeflowtrainerimage:v0.0.1         f52d1846deae       7.75GB             0B
```


### Authenticating with a personal access token (classic)
1. Create `Personal access tokens (classic)` https://github.com/settings/tokens
	* Select the read:packages scope to download container images and read their metadata.
	* Select the write:packages scope to download and upload container images and read and write their metadata.
	* Select the delete:packages scope to delete container images.
2. Save your personal access token (classic). We recommend saving your token as an environment variable.
3. Using the CLI for your container type, sign in to the Container registry service at ghcr.io.
```
GITHUB_USERNAME=YOUR_GITHUB_USERNAME_ID
export CR_PAT=YOUR_PERSONAL_ACCESS_TOKEN
echo ${CR_PAT} | docker login ghcr.io -u ${GITHUB_USERNAME} --password-stdin
```

### Pushing container images
Tag your Docker image using the image ID and your desired image name and hosting destination.
```bash
GITHUB_ORG=YOUR_GITHUB_ORG or YOUR_GITHUB_USERNAME_ID
PROJECT_NAME=YOUR_PROJECT_NAME
docker tag ${IMAGENAME}:${VERSION_ID} ghcr.io/${GITHUB_ORG}/${PROJECT_NAME}/${IMAGENAME}:${VERSION_ID}
```
Pushing container images to GitHub container registry
```bash
docker push ghcr.io/${GITHUB_ORG}/${PROJECT_NAME}/${IMAGENAME}:${VERSION_ID}
```
Go to packages `https://github.com/orgs/${GITHUB_ORG}/packages` and in package settings, change visibility to public.


## Docker Management Commands
The following are a few useful commands, for more comprehensive list see this [cheatsheet](https://www.linuxteck.com/docker-management-command-cheat-sheet/)
```bash
docker images && docker ps # that list images containers
docker exec -it <container_id> bash # Exececute command inside the containers
docker exec -it $(docker container ls  | grep '${IMAGENAME}' | awk '{print $1}') bash # use IMAGENAME variable to select container id for docker command execution
docker system prune -f --volumes #free up disk space
docker rmi --force <ID> # remove docker images
```

### Example that connects to Unified-AI Kubeflow
Once you build your customised image with the files [hello-world-customised-images](https://github.com/ucl-arc-environments/kubeflow-trainer-examples/tree/main/hello-world-customised-images), you will connect to Unified-AI platform with the following steps:

1. Connect to VPN to access https://kubeflow.arc-unified-ai.condenser.arc.ucl.ac.uk
2. Create new Unified-AI notebook that mainly have these resources:
    * CPU: 2
    * RAM: 4Gb
    * GPUs: 2 (A100 80GB)
    * Workspace Volume of 20Gb
3. Run python script in the terminal
```bash
python quickstart-container-registry.py
```
