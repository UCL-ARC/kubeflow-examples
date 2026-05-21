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

## Download Dataset

Download and extract the dataset into the `scratch-volume`:
```bash
mkdir -p ~/scratch-volume/FETAL_PLANES_DB && mkdir -p ~/scratch-volume/FETAL_PLANES_DB/OUTPUT_DIRECTORY && cd ~/scratch-volume/FETAL_PLANES_DB
wget -c --content-disposition https://zenodo.org/records/3904280/files/FETAL_PLANES_ZENODO.zip?download=1
unzip FETAL_PLANES_ZENODO.zip && rm FETAL_PLANES_ZENODO.zip
```

## Download Pretrained VAE Model

```bash
mkdir -p ~/scratch-volume/FETAL_PLANES_DB/models/sd-vae-ft-mse && cd ~/scratch-volume/FETAL_PLANES_DB/models/sd-vae-ft-mse
wget -4 -O config.json https://huggingface.co/stabilityai/sd-vae-ft-mse/resolve/main/config.json
wget -4 -O diffusion_pytorch_model.safetensors https://huggingface.co/stabilityai/sd-vae-ft-mse/resolve/main/diffusion_pytorch_model.safetensors
```

## (Optional) Build Custom Docker Image

Build Dockerfile container using either [Dockerfile](../../kubeflow-trainer-usecases/edm2/Dockerfile) or [Dockerfile-scratch-volume](../../kubeflow-trainer-usecases/edm2/Dockerfile-scratch-volume) and push container images to GHCR (see explicit steps [here](https://github.com/xfetus/fetal-ultrasound-edm2/blob/main/unified-ai/GHCR.md)).

Reference for [GHCR package fetal-ultrasound-edm2/fetal-ultrasound-edm2-distributed-learning](https://github.com/orgs/xfetus/packages/container/package/fetal-ultrasound-edm2%2Ffetal-ultrasound-edm2-distributed-learning)

## Configure Training Resources

Open the notebook [`training-edm2-model-ghcr.ipynb`](../../kubeflow-trainer-usecases/edm2/training-edm2-model-ghcr.ipynb)


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
# it displays only index in the val dataset and use `docker.io/pytorch/pytorch:2.7.1-cuda12.8-cudnn9-devel`
GITHUB_CONTAINER_REGISTRY = "ghcr.io/xfetus/fetal-ultrasound-edm2/fetal-ultrasound-edm2-distributed-learning:v0.0.8"
```

* Setting up torchrun with all dependendencies in the customimsed image (see full notebook [here](https://github.com/xfetus/fetal-ultrasound-edm2/blob/main/unified-ai/training-edm2-model-ghcr.ipynb))

```bash
command = TrainerCommand(
    command=[
        "torchrun",
        f"--nnodes={NUM_NODES}", #DO WE NEED PASS THIS?
        f"--nproc_per_node={NPROC_PER_NODE}", #DO WE NEED PASS THIS?
        # f"--node_rank={NODE_RANK}", #DO WE NEED PASS THIS?
        # f"--master_addr={MASTER_ADDR}", #DO WE NEED PASS THIS?
        # f"--master_port={MASTER_PORT}", #DO WE NEED PASS THIS?
        "train_edm2.py",
        "--outdir", "/scratch-volume/FETAL_PLANES_DB/OUTPUT_DIRECTORY", #pragma: allowlist secret
        "--data", "/scratch-volume/FETAL_PLANES_DB", #pragma: allowlist secret
        "--batch", "4",
        "--preset", "edm2-img512-s",
        "--batch-gpu", "4",
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
            "--outdir /scratch-volume/FETAL_PLANES_DB/OUTPUT_DIRECTORY "
            "--data /scratch-volume/FETAL_PLANES_DB "
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

## References
* Karras, Tero, Miika Aittala, Jaakko Lehtinen, Janne Hellsten, Timo Aila, and Samuli Laine. "Analyzing and improving the training dynamics of diffusion models." In Proceedings of the IEEE/CVF conference on computer vision and pattern recognition, pp. 24174-24184. 2024. https://arxiv.org/abs/2312.02696
* Karras, Tero, Miika Aittala, Timo Aila, and Samuli Laine. "Elucidating the design space of diffusion-based generative models." Advances in neural information processing systems 35 (2022): 26565-26577. https://arxiv.org/abs/2206.00364
