# Setting up and running vllm use case

## Download model

```
cd scrach-volume
mkdir models && cd models
pip install -U "huggingface_hub[cli]"
export PATH="$HOME/.local/bin:$PATH"
hf download openai/gpt-oss-20b --include "original/*" --local-dir gpt-oss-20b/
#Download complete: : 13.8GB [00:58, 234MB/s]
```

## Starting services
```bash
kubectl apply -f serving-runtime.yaml
```

```bash
kubectl apply -f inference-service.yaml
```

## Managing services
```bash
kubectl get inferenceservice
kubectl describe inferenceservice zai-org-glm-47-vllm
kubectl delete inferenceservice zai-org-glm-47-vllm
```


