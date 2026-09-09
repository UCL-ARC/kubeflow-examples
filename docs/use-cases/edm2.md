---
title: Kubeflow Trainer - Elucidating Diffusion Models 2 (edm2) to generate syntethic ultrasound fetal images
description:
weight: 2
---

This guide walks you through setting up your unified-ai environment, downloading data, and training an EDM2 model to generate synthetic fetal ultrasound images.

## Create a Unified AI Notebook

Create a new notebook with a user-defined name Under Data Volumes, select: `scratch-volume`
This is required for storing datasets, models, and outputs.

## Clone Repository

Open a terminal in your notebook environment and run:
```bash
git clone https://github.com/xfetus/fetal-ultrasound-edm2.git
```

## Download Datasets

Download datsets into the `scratch-volume`:

### FETAL_PLANES_DB
```bash
mkdir -p ~/scratch-volume/FETAL_PLANES_DB && mkdir -p ~/scratch-volume/FETAL_PLANES_DB/OUTPUT_DIRECTORY && cd ~/scratch-volume/FETAL_PLANES_DB
wget -c --content-disposition https://zenodo.org/records/3904280/files/FETAL_PLANES_ZENODO.zip?download=1
unzip FETAL_PLANES_ZENODO.zip && rm FETAL_PLANES_ZENODO.zip
```


### FPUS23_Dataset
```bash
mkdir -p ~/scratch-volume/data-fetal-us-edm2 && cd ~/scratch-volume/data-fetal-us-edm2
wget -O FPUS23_Dataset.zip \
"https://drive.usercontent.google.com/download?export=download&confirm=t&id=1LL-r2hNiP6C190UBSE4v1FFCF3OQT9N3"
mkdir FPUS23
unzip FPUS23_Dataset.zip -d FPUS23
rm FPUS23_Dataset.zip
```

### AfricanDataset
```bash
mkdir -p ~/scratch-volume/data-fetal-us-edm2 && cd ~/scratch-volume/data-fetal-us-edm2
wget -c --content-disposition "https://zenodo.org/api/records/7540448/files/Zenodo_dataset.tar.xz/content"
mkdir AfricanDataset
tar -xvf Zenodo_dataset.tar.xz -C AfricanDataset
rm Zenodo_dataset.tar.xz
```

### FetalAbdominalSegmentation
```bash
mkdir -p ~/scratch-volume/data-fetal-us-edm2 && cd ~/scratch-volume/data-fetal-us-edm2
wget --content-disposition \
-O fetal_dataset.zip \
"https://data.mendeley.com/public-files/datasets/4gcpm9dsc3/files/89e74076-ff57-4e81-9634-4fc29c6128ff/file_downloaded"
mkdir FetalAbdominalSegmentation
unzip fetal_dataset.zip -d FetalAbdominalSegmentation
rm fetal_dataset.zip
```

## Download Pretrained VAE Model

```bash
mkdir -p ~/scratch-volume/data-fetal-us-edm2/OUTPUT_DIRECTORY
mkdir -p ~/scratch-volume/FETAL_PLANES_DB/models/sd-vae-ft-mse && cd ~/scratch-volume/FETAL_PLANES_DB/models/sd-vae-ft-mse
wget -4 -O config.json https://huggingface.co/stabilityai/sd-vae-ft-mse/resolve/main/config.json
wget -4 -O diffusion_pytorch_model.safetensors https://huggingface.co/stabilityai/sd-vae-ft-mse/resolve/main/diffusion_pytorch_model.safetensors
```

## (Optional) Build Custom Docker Image

Build Dockerfile container using either [Dockerfile-ghrc](https://github.com/UCL-ARC/kubeflow-examples/blob/main/kubeflow-trainer-usecases/edm2/Dockerfile-ghcr) or [Dockerfile-scratch-volume](https://github.com/UCL-ARC/kubeflow-examples/blob/main/kubeflow-trainer-usecases/edm2/Dockerfile-scratch-volume) and push container images to GHCR (see explicit steps [here](https://github.com/xfetus/fetal-ultrasound-edm2/blob/main/unified-ai/GHCR.md)).

Reference for [GHCR package fetal-ultrasound-edm2/fetal-ultrasound-edm2-distributed-learning](https://github.com/orgs/xfetus/packages/container/package/fetal-ultrasound-edm2%2Ffetal-ultrasound-edm2-distributed-learning)

## Configure Training Resources

Open the notebook [`training-edm2-model-ghcr.ipynb`](https://github.com/UCL-ARC/kubeflow-examples/blob/main/kubeflow-trainer-usecases/edm2/training-edm2-model-ghcr.ipynb)


Set your compute resources:

* Setting up resources where it is important to see cluster queue resources where `NUM_NODES` could be between 1 to 8. Consider 8 to 16 CPUs per GPU and memory 64Gi to 128Gi if available. Memory cap is 1000Gi and nvidia.com/gpu will depend on availble resources.

```bash
## Set how many PyTorch nodes you want to use for distributed training.
NUM_NODES = 1
NPROC_PER_NODE = 1  # match GPU count


# Set the resources for each PyTorch node.
RESOURCES_PER_NODE = {
    "cpu": "8",           # CPUs per node
    "memory": "128Gi",     # Memory in GiB per node (tried 2Gi CrashLoopBackOff/OOMKilled), 64Gi works
    "nvidia.com/gpu": 1,  # GPUs per node (the number will depend on the available resources)
}
```

* Setting up customised image

```bash
GITHUB_CONTAINER_REGISTRY = "ghcr.io/xfetus/fetal-ultrasound-edm2/fetal-ultrasound-edm2-distributed-learning:v0.1.1"
```

* Setting up torchrun with all dependendencies in the customimsed image (see full notebook [here](https://github.com/xfetus/fetal-ultrasound-edm2/blob/main/unified-ai/training-edm2-model-ghcr.ipynb))

```bash

command = TrainerCommand(
    command=[
        "torchrun",
        f"--nnodes={NUM_NODES}",
        "train_edm2.py", #path of script in scratch 
        "--outdir /scratch-volume/FETAL_PLANES_DB/OUTPUT_DIRECTORY", # pragma: allowlist secret
        "--data /scratch-volume/data-fetal-us-edm2/FETAL_PLANES_DB",
        "--fpus23 /scratch-volume/data-fetal-us-edm2/FPUS23",
        "--african /scratch-volume/data-fetal-us-edm2/AfricanDataset/Zenodo_dataset",
        "--fetal-abdomen /scratch-volume/data-fetal-us-edm2/FetalAbdominalSegmentation/IMAGES",
        "--batch 4",
        "--preset edm2-img512-s",
        "--batch-gpu 4",
    ]
)

```


* Setting up torchrun with all dependendencies in the customimsed image using the scratch-volume (see full notebook [here](https://github.com/xfetus/fetal-ultrasound-edm2/blob/main/unified-ai/training-edm2-model-scratch-volume.ipynb))

```bash

command = TrainerCommand(
    command=[
        "bash", "-c",
        (
            # Create writable dirs
            "mkdir -p /scratch-volume/pip-packages "
            "/scratch-volume/torch-inductor-cache "
            "/scratch-volume/home && "
            # Install deps exclude torch/torchvision (already in base image)
            # Use --upgrade to overwrite stale packages from previous runs
            "pip install "
            "torch==2.9.1 "
            "pandas "
            "accelerate "
            "basicsr "
            "diffusers "
            "einops "
            "scikit-learn "
            "--target=/scratch-volume/pip-packages "
            "--upgrade "
            "--no-cache-dir "
            "--quiet && "
            # Set cache env vars inline to guarantee they're set before torchrun
            "export HOME=/scratch-volume/home && "
            "export TORCHINDUCTOR_CACHE_DIR=/scratch-volume/torch-inductor-cache && "
            "export PYTHONPATH=/scratch-volume/pip-packages:$PYTHONPATH && "          
            "torchrun /scratch-volume/fetal-ultrasound-edm2/train_edm2.py "
            "--outdir /scratch-volume/data-fetal-us-edm2/OUTPUT_DIRECTORY "
            "--data /scratch-volume/data-fetal-us-edm2/FETAL_PLANES_DB "
            "--fpus23 /scratch-volume/data-fetal-us-edm2/FPUS23 "
            "--african /scratch-volume/data-fetal-us-edm2/AfricanDataset/Zenodo_dataset "
            "--fetal-abdomen /scratch-volume/data-fetal-us-edm2/FetalAbdominalSegmentation/IMAGES "
            "--batch 4 "
            "--preset edm2-img512-s "
            "--batch-gpu 4"
        )
    ]
)


```

## Models

Models, logs and stats will be saved at `~/scratch-volume/FETAL_PLANES_DB/OUTPUT_DIRECTORY`:

```bash
├── [1.7M]  log.txt
├── [ 59M]  network-snapshot-0000000-0.050.pkl
├── [ 59M]  network-snapshot-0000000-0.100.pkl
├── [ 62M]  training-state-0000655.pt
└── [ 320]  stats.jsonl
```

## Troubleshooting
* Out of Memory (OOMKilled / CrashLoopBackOff)
```bash
Increase memory to at least 64Gi
Reduce batch size:
--batch 2
```
* Dataset Not Found
Ensure dataset is extracted to:
```bash
~/scratch-volume/FETAL_PLANES_DB
```

* Use `kpodinfo` for pod information as a simplified kubectl queries

```bash
$ kpodinfo --help

Usage: /usr/local/bin/kpodinfo [OPTIONS] COMMAND

Options:
  -h, --help                  Show this help message

Commands:
  cpu-requests                Show pod names with CPU requests
  memory-requests             Show pod names with CPU and memory requests
  quota-summary               Show Quota Summary
  flavors                     Show Flavors Reservation and Usage
  all-info                    Show detailed pod information
```

## References
* Karras, Tero, Miika Aittala, Jaakko Lehtinen, Janne Hellsten, Timo Aila, and Samuli Laine. "Analyzing and improving the training dynamics of diffusion models." In Proceedings of the IEEE/CVF conference on computer vision and pattern recognition, pp. 24174-24184. 2024. https://arxiv.org/abs/2312.02696
* Karras, Tero, Miika Aittala, Timo Aila, and Samuli Laine. "Elucidating the design space of diffusion-based generative models." Advances in neural information processing systems 35 (2022): 26565-26577. https://arxiv.org/abs/2206.00364
* Harvey Mannering, Yilin Zhang, Ziao Liu, Zhiwu Huang, Jacqueline Matthew, Miguel Xochicale. "A Foundational EDM2-Based Generative Model for High-Resolution Synthetic Fetal Ultrasound Imaging from Open Datasets." arXiv preprint arXiv:2608.05471 (2026). Published in the 30th UK Conference on Medical Image Understanding and Analysis, MIUA'26 Short paper track. Dublin, Irland. 20th - 22nd July 2026.
