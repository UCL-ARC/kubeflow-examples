# Setting up and running vllm use case

## Download model

```
cd scrach-volume
mkdir -d models
mkdir -p gpt-oss-20b
cd gpt-oss-20b

wget https://huggingface.co/openai/gpt-oss-20b/resolve/main/config.json
wget https://huggingface.co/openai/gpt-oss-20b/resolve/main/tokenizer.json
wget https://huggingface.co/openai/gpt-oss-20b/resolve/main/tokenizer_config.json
wget https://huggingface.co/openai/gpt-oss-20b/resolve/main/special_tokens_map.json
```


## Starting services

```bash
kubectl apply -f serving-runtime.yaml
```

```bash
kubectl apply -f inference-service.yaml
```


