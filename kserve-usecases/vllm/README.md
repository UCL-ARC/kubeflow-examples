# Setting up and running vllm use case

## Download model
* Download openai/gpt-oss-20b
```bash
cd $HOME/scratch-volume && mkdir -p models && cd models
pip install -U "huggingface_hub[cli]"
export PATH="$HOME/.local/bin:$PATH"
# hf auth login (optional)
hf download openai/gpt-oss-20b --local-dir gpt-oss-20b/ --max-workers 1
# Download complete: 100%, 41.3G/41.3G [02:20<00:00, 294MB/s]
```

* logs (for reference and to be removed)
```bash
(base) jovyan@kvserve-llm-v01-0:~/scratch-volume/models/gpt-oss-20b$ ls -la

-rwxr-xr-x. 1       16738 Jun  1 11:41 chat_template.jinja
-rwxr-xr-x. 1        1806 Jun  1 11:41 config.json
-rwxr-xr-x. 1         177 Jun  1 11:41 generation_config.json
-rwxr-xr-x. 1        1570 Jun  1 11:41 .gitattributes
drwxr-sr-x. 2        4096 Jun  1 11:47 .ipynb_checkpoints
-rwxr-xr-x. 1       11357 Jun  1 11:41 LICENSE
drwxr-sr-x. 2        4096 Jun  1 11:42 metal
-rwxr-xr-x. 1  4792272488 Jun  1 11:42 model-00000-of-00002.safetensors
-rwxr-xr-x. 1  4798702184 Jun  1 11:42 model-00001-of-00002.safetensors
-rwxr-xr-x. 1  4170342232 Jun  1 11:42 model-00002-of-00002.safetensors
-rwxr-xr-x. 1       36355 Jun  1 11:42 model.safetensors.index.json
drwxr-sr-x. 2        4096 Jun  1 11:43 original
-rwxr-xr-x. 1        7095 Jun  1 11:41 README.md
-rwxr-xr-x. 1          98 Jun  1 11:43 special_tokens_map.json
-rwxr-xr-x. 1        4200 Jun  1 11:43 tokenizer_config.json
-rwxr-xr-x. 1    27868174 Jun  1 11:43 tokenizer.json
-rwxr-xr-x. 1         200 Jun  1 11:41 USAGE_POLICY
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


