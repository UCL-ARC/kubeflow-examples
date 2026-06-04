# ghcr

* Build Dockerfile container
```bash
IMAGENAME=unified-ai-kserve-vllm
VERSION_ID=v0.0.2
docker build -t ${IMAGENAME}:${VERSION_ID} -f Dockerfile .
```

* Pushing container images
Tag your Docker image using the image ID and your desired image name and hosting destination.
```bash
GITHUB_ORG=YOUR_GITHUB_ORG  # or YOUR_GITHUB_USERNAME_ID
PROJECT_NAME=kserve-vllm
docker tag ${IMAGENAME}:${VERSION_ID} ghcr.io/${GITHUB_ORG}/${PROJECT_NAME}/${IMAGENAME}:${VERSION_ID}
```

* See an example of output logs for the command `docker images`:
```bash
$ docker images
REPOSITORY                                              TAG       IMAGE ID       CREATED         SIZE
ghcr.io/mxochicale/kserve-vllm/unified-ai-kserve-vllm   v0.0.2    c4ab68f6e4f6   2 minutes ago   26.2GB
unified-ai-kserve-vllm                                  v0.0.2    c4ab68f6e4f6   2 minutes ago   26.2GB
```

* Authenticating with a personal access token (classic)
```bash
GITHUB_USERNAME=YOUR_GITHUB_USERNAME_ID
export CR_PAT=YOUR_PERSONAL_ACCESS_TOKEN
echo ${CR_PAT} | docker login ghcr.io -u ${GITHUB_USERNAME} --password-stdin
	#Login Succeeded
```

* Pushing container images to GitHub container registry
```bash
docker push ghcr.io/${GITHUB_ORG}/${PROJECT_NAME}/${IMAGENAME}:${VERSION_ID}
```
Go to packages `https://github.com/orgs/${GITHUB_ORG}/packages` and in package settings, change visibility to public.
