---
title: Quickstart and mnist
description:
weight: 1
---

Hello world examples illustrate steps to run basic kubeflow trainer examples in Unified-AI platform.

## Setting up Unified-AI notebook

Follow [documentation](https://kubeflow.arc-unified-ai.condenser.arc.ucl.ac.uk/docs/kubeflow_notebooks/) to create notebooks.
The following notebook settings are examples for running the provided examples. The exact settings will depend on the needs of the users and their applications.
We recommend using the minimum resources required for your workload.

* CPU: 2
* RAM: 4Gb
* GPUs: 2 (A100 80GB)
* Workspace Volume of 20Gb (20Gb is recommeded but you can increase it if you get space errors).

## Examples
You can then run examples using terminal for python scripts and jupyter notebook for notebooks.

* [quickstart.ipynb](https://github.com/ucl-arc-environments/kubeflow-trainer-examples/blob/main/hello-world/quickstart.ipynb)
* [mnist.ipynb](https://github.com/ucl-arc-environments/kubeflow-trainer-examples/blob/main/hello-world/mnist.ipynb)
