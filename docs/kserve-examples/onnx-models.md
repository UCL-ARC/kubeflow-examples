---
title: Deploying ONNX Models with KServe
description:
weight: 2
---

## Prerequisites

Before starting, create a new Unified AI Notebook.
Under **Data Volumes**, select `scratch-volume`, this is required for storing datasets, models, and outputs.

## 1. Download model and sample image
```bash
mkdir -p mosaic && cd mosaic
wget -O mosaic-9.onnx https://huggingface.co/onnxmodelzoo/mosaic-9/resolve/main/mosaic-9.onnx
wget https://raw.githubusercontent.com/pytorch/examples/main/fast_neural_style/images/content-images/amber.jpg
```

## 2. Deploy Services
change path to `kserve-predictive-infence-onnx`
```bash
kubectl apply -f onnx.yaml
```

