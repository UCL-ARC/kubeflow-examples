# Setting up and running vllm use case

## Download model
* Download openai/gpt-oss-20b
```bash
cd $HOME/scratch-volume && mkdir -p models && cd models
pip install -U "huggingface_hub[cli]"
export PATH="$HOME/.local/bin:$PATH"
# hf auth login (optional)
hf download openai/gpt-oss-20b --local-dir gpt-oss-20b/ --max-workers 1
# Download complete: 100%, 41.3G/41.3G
```

* logs (for reference and to be removed)
```bash

$ ~/scratch-volume/models$ ls -la
drwxr-sr-x. 5 4096 Jun  1 13:23 gpt-oss-20b

$ ~/scratch-volume/models/gpt-oss-20b$ ls -la
-rw-r--r--. 1      16738 Jun  1 13:19 chat_template.jinja
-rw-r--r--. 1       1806 Jun  1 13:19 config.json
-rw-r--r--. 1        177 Jun  1 13:19 generation_config.json
-rw-r--r--. 1       1570 Jun  1 13:19 .gitattributes
-rw-r--r--. 1      11357 Jun  1 13:19 LICENSE
drwxr-sr-x. 2       4096 Jun  1 13:20 metal
-rw-r--r--. 1 4792272488 Jun  1 13:20 model-00000-of-00002.safetensors
-rw-r--r--. 1 4798702184 Jun  1 13:20 model-00001-of-00002.safetensors
-rw-r--r--. 1 4170342232 Jun  1 13:21 model-00002-of-00002.safetensors
-rw-r--r--. 1      36355 Jun  1 13:21 model.safetensors.index.json
drwxr-sr-x. 2       4096 Jun  1 13:23 original
-rw-r--r--. 1       7095 Jun  1 13:19 README.md
-rw-r--r--. 1         98 Jun  1 13:23 special_tokens_map.json
-rw-r--r--. 1       4200 Jun  1 13:23 tokenizer_config.json
-rw-r--r--. 1   27868174 Jun  1 13:23 tokenizer.json
-rw-r--r--. 1        200 Jun  1 13:19 USAGE_POLICY
```

## Starting services
```bash
kubectl apply -f kserve-usecases/vllm/serving-runtime.yaml
```

```bash
kubectl apply -f kserve-usecases/vllm/inference-service.yaml
```

## End-point
http://zai-org-glm-47-vllm.kubeflow-${USERNAME}.svc.cluster.local

## Managing services
```bash
kubectl get inferenceservice
kubectl describe inferenceservice zai-org-glm-47-vllm
kubectl delete inferenceservice zai-org-glm-47-vllm
kubectl get pods
kubectl describe pod zai-org-glm-47-vllm-predictor-00001-deployment
```


