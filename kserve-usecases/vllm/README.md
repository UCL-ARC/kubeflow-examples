# Setting up and running vllm use case

## Download model
* Download openai/gpt-oss-20b
```bash
cd $HOME/scratch-volume && mkdir -p models && cd models
pip install -U "huggingface_hub[cli]"
export PATH="$HOME/.local/bin:$PATH"
# hf auth login (optional)
hf download openai/gpt-oss-20b --include "original/*" --local-dir gpt-oss-20b/
# Download complete: : 13.8GB [00:58, 234MB/s]
```

* logs (for reference and to be removed)
```bash
(base) jovyan@kvserve-llm-v01-0:~/scratch-volume/models/gpt-oss-20b/original$ ls -la
-rw-r--r--. 1 jovyan nfs-group-10320         376 May 28 19:26 config.json
-rw-r--r--. 1 jovyan nfs-group-10320       13082 May 28 19:26 dtypes.json
-rw-r--r--. 1 jovyan nfs-group-10320 13761300984 May 28 19:28 model.safetensors
```

## Starting services
```bash
kubectl apply -f kserve-usecases/vllm/serving-runtime.yaml
```

```bash
kubectl apply -f kserve-usecases/vllm/inference-service.yaml
```

## Managing services
```bash
kubectl get inferenceservice
kubectl describe inferenceservice zai-org-glm-47-vllm
kubectl delete inferenceservice zai-org-glm-47-vllm
kubectl get pods
kubectl describe pod zai-org-glm-47-vllm-predictor-00001-deployment
```


