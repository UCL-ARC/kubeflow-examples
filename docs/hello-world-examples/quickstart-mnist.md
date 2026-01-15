---
title: Quickstart and mnist
description:
weight: 1
---

Hello world examples illustrate steps to run basic kubeflow trainer examples in Unified-AI platform.

## Setting up Unified-AI notebook

Follow [documentation](https://kubeflow.arc-unified-ai.condenser.arc.ucl.ac.uk/docs/kubeflow_notebooks/) to create notebooks.
The following notebook settings are examples for running the provided examples. The exact settings will depend on the needs of the users and their applications.
We recommend using the minimum resources required for your workload. In some cases, you may not need a GPU at all; in others, you may need one or two.

* CPU: 2 cores (minimum when using a GPU)
* RAM: 4 GB (minimum memory)
* GPUs: 1 × NVIDIA A100 80 GB (Options: none, 1, 2, 4, or 8 GPUs. NVIDIA A100 80 GB, NVIDIA A100 40 GB, NVIDIA vGPU 40 GB, or NVIDIA vGPU 20 GB)
* Workspace volume: 20 GB (20 GB is recommended, but you can increase this if you encounter space errors).

## Examples
You can then run examples using terminal for python scripts and jupyter notebook for notebooks.

* [quickstart.ipynb](https://github.com/ucl-arc-environments/kubeflow-trainer-examples/blob/main/hello-world/quickstart.ipynb)
* [mnist.ipynb](https://github.com/ucl-arc-environments/kubeflow-trainer-examples/blob/main/hello-world/mnist.ipynb)
