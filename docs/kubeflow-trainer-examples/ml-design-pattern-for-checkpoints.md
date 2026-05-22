---
title: Checkpoint fundamentals
description:
weight: 3
---

## Introduction
Saving intermediate checkpoints makes training more reliable.
Long training runs or work spread across several machines might be prone to fail.
Checkpoints allow PyTorch to restart from the last saved point instead of beginning again from scratch.

Checkpoints also help with generalisation.
Training loss may keep falling, but validation error can stop improving or even rise because of overfitting.
Saving checkpoints regularly lets you return to the model with the best validation results or stop training at the right time.

They also make training easier to adjust.
Models usually reach a good solution quickly and then improve slowly by focusing on edge cases.
When training again with new data, it is often better to restart from an earlier checkpoint so the model focuses on new information rather than older details.

Checkpoint size is important when planning training infrastructure.
It mainly depends on three things: the number of model parameters, the size of the compute cluster (world size), how training is distributed, such as model parallelism (MP) or data parallelism (DP).

![Kubernetes basic components](../assets/images/ml-design-pattern-checkpoints.svg)


## Checkpoint storage example for PyTorch DDP using Fashion MNIST Training


This example demonstrates how to train a convolutional neural network (CNN) on the Fashion-MNIST dataset using PyTorch Distributed Data Parallel (DDP), while reliably saving and resuming checkpoints.
It is designed for shared storage environments, including Kubernetes volumes, to ensure training continuity and scalability.


### Key Features
* Distributed Training: Scales seamlessly across multiple GPUs using PyTorch DDP.
* Atomic Checkpoint Saving: Checkpoints (model + optimizer state) are saved reliably at `~/scratch-volume/checkpoints` using an atomic save method. This prevents corruption in shared or cloud storage environments.
* Resume Training: Easily restart from the last checkpoint without losing progress.
* Efficient Dataset Handling: Only the main process handles dataset downloads, reducing redundant network usage.

### How It Works

1. Set Up Distributed Environment. The function initializes PyTorch’s distributed backend and ensures each process is assigned to the correct GPU.

2. Build a Simple CNN Model. A lightweight CNN suitable for Fashion-MNIST is created. The model supports multi-GPU training through DDP.

3. Training Loop with Checkpoints. The network is trained over multiple epochs on a subset of Fashion-MNIST.
Checkpoints are saved periodically.
Only the main process writes to disk, ensuring consistency.

4. Resume from Checkpoint. If a checkpoint exists, the model and optimizer state are restored automatically, allowing training to continue seamlessly.


### Getting Started

1. Open the Example Notebook
Check out the [kubeflow-trainer-checkpoints-fundamentals](https://github.com/ucl-arc-unified-ai//kubeflow-examples/tree/main/kubeflow-trainer-checkpoints-fundamentals/mnist-checkpoints-fundamentals.ipynb) notebook for a fully worked example.

2. Set Up Your Environment. Launch a new notebook using Kubeflow. Attach the existing volume scratch-volume/ in the Data Volumes section to store checkpoints and intermediate results.

3. Run Training.
Execute the `train_fashion_mnist()` function. Training will automatically handle distributed setup, checkpoint saving, and resuming if needed.


### Recommended Practices
* Use a dedicated checkpoint directory on shared storage to avoid conflicts between processes.
* Adjust the checkpoint frequency depending on the size of your dataset and training time.
* Monitor GPU usage to ensure all processes are efficiently utilized.
