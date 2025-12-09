---
title: Local kubectl access
description:
weight: 1
---

The Kubeflow platform is hosted inside a Kubernetes cluster, `kubectl` is the main command-line tool for interacting, observing, debugging kubernetes clusters.

## Installation


=== ":fontawesome-brands-linux: Linux"

    **1. Install kubectl**

    Download the latest release with the command:
    ```bash
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    ```


=== ":fontawesome-brands-apple: macOS"

    **1. Install kubectl**

    ```bash
    brew install kubectl
    ```
