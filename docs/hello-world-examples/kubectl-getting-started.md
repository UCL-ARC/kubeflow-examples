---
title: Getting started with kubectl
description:
weight: 3
---

The following examples show how to use `kubectl` to manage resources on the Unified-AI platform.

We start with a brief introduction to Kubernetes (K8s) components, followed by common `kubectl` commands and practical examples of how to use them.


## Kubernetes components

Kubernetes (K8s) is made up of several components, such as namespaces, the control plane, and ingress.
This document focuses on the core building blocks: **containers, Pods, Nodes, and Services**.
These are briefly explained below and shown in the figure.

* **Service**: Provides a stable network endpoint (IP address or DNS name). Services allow Pods to communicate with each other and can also expose applications to external users.
* **Node**: A physical or virtual machine that runs containerised applications. Each Node hosts one or more Pods.
* **Pod**: The smallest unit that can be deployed in Kubernetes. A Pod contains one or more containers that share storage, networking, and other resources.
* **Container**: A lightweight and standalone executable package.

![Kubernetes basic components](../assets/images/k8s-basic-components.svg)

See further details in the reference section.

## kubectl pods

Pods are the smallest deployable units in Kubernetes. They usually contain one main container (and sometimes sidecars) that run your application.

**List Pods.**
```bash
kubectl get pods
```

Example output:
```
NAME                    READY   STATUS             RESTARTS   AGE
mx-notebook-06-0        2/2     Running            0          4d10h
f83d03fca881            0/1     ImagePullBackOff   0          2d22h
```

**Describe a Pod.**

This command provides detailed information about a specific Pod.
Use kubectl describe pod when a Pod is not behaving as expected.
```bash
kubectl describe pod mx-notebook-06-0
```

Key sections to look at:

* **Name / Namespace**: Identifies the Pod and where it runs.
* **Node**: The node where the Pod is scheduled.
* **Status**: Overall Pod state (for example, Running).
* **IP**: Internal cluster IP assigned to the Pod.
* **Controlled By**: The controller managing the Pod (for example, a StatefulSet).
* **Containers**: Details about each container, including image, resources, and runtime status.
* **Conditions**: Indicates whether the Pod is ready, scheduled, and fully initialised.
* **Node-Selectors / Tolerations**: Scheduling constraints that affect where the Pod can run.
* **Events**: Useful for debugging; shows recent issues such as image pull failures or scheduling problems.

## kubectl jobs

Jobs are used to run batch or one-off tasks, such as training jobs or data processing.

**List Jobs**
```bash
kubectl get jobs
```

Example output:
```bash
NAME                  STATUS      COMPLETIONS   DURATION   AGE
e55d07facbf4-node-0   Suspended   0/4                      2d21h
f83d03fca881-node-0   Running     0/1           11d        11d
```

**Describe a Job.**

```bash
kubectl describe job f83d03fca881-node-0
```

This command gives detailed information about how the Job is configured and how it is progressing.
Use this command to understand why a Job is running slowly, failing, or stuck.

Important fields include:

* **Parallelism / Completions**: How many Pods run in parallel and how many must complete.
* **Suspend**: Whether the Job is paused.
* **Pods Statuses**: Number of active, succeeded, and failed Pods.
* **Pod Template**: The Pod specification used by the Job, including:
    * Container image
    * Command and arguments
    * Resource requests and limits
    * Environment variables
* **Node-Selectors**: Constraints that control which nodes the Job can run on.
* **Events**: Helpful for troubleshooting Job failures.

## kubectl Filtering and Querying

Kubernetes outputs a lot of information. Filtering helps you extract only what you need.

We provide a Pod Information Script,[`pod-info.sh`](https://github.com/ucl-arc-environments/kubeflow-trainer-examples/blob/main/bash_scrips/pod-info.sh), which simplifies common kubectl queries.

**Using the Pod Information Script**

* View the help menu:
```bash
bash bash_scrips/pod-info.sh --help
```

* Help output:
```text
Pod Information Script - Simplified kubectl queries

Usage: pod-info.sh [OPTIONS] COMMAND

Options:
  -h, --help                  Show this help message

Commands:
  cpu-requests                Show pod names with CPU requests
  resources                   Show pod names with CPU and memory requests
  flavors                     Show Flavors Reservation and Usage
  all-info                    Show detailed pod information

Examples:
  pod-info.sh cpu-requests
  pod-info.sh resources
```

**Example: Get detailed pod information for your namespace**

Run this [mnist](https://github.com/ucl-arc-environments/kubeflow-trainer-examples/blob/main/hello-world-mnist/mnist.ipynb) jupyter notebook and after the cell for checking job status directly, you can run `bash pod-info.sh all-info`

```bash
bash bash_scrips/pod-info.sh all-info
```

Sample output
```text
=== All Pod Information ===

1. Basic Pod Status:
NAME                                               READY   STATUS    RESTARTS   AGE
ml-pipeline-ui-artifact-55894b5986-xnmmg           2/2     Running   0          24h
ml-pipeline-visualizationserver-847879f7bb-lgfjd   2/2     Running   0          2d3h
mx-notebook-06-0                                   2/2     Running   0          23h
v54b375a0eb1-node-0-0-gf89q                        1/1     Running   0          4s
v54b375a0eb1-node-0-1-csg8z                        1/1     Running   0          4s
v54b375a0eb1-node-0-2-8v9qj                        1/1     Running   0          4s
v54b375a0eb1-node-0-3-qfq2w                        1/1     Running   0          3s
v54b375a0eb1-node-0-4-9t9dr                        1/1     Running   0          3s

2. Pods with CPU Requests:
=== Pod CPU Requests ===
Pod Name	per-container:Number of CPUs Requested
--------------------------------
ml-pipeline-ui-artifact-55894b5986-xnmmg          ml-pipeline-ui-artifact:10m
ml-pipeline-visualizationserver-847879f7bb-lgfjd  ml-pipeline-visualizationserver:50m
mx-notebook-06-0                                  mx-notebook-06:2
v54b375a0eb1-node-0-0-gf89q                       node:5
v54b375a0eb1-node-0-1-csg8z                       node:5
v54b375a0eb1-node-0-2-8v9qj                       node:5
v54b375a0eb1-node-0-3-qfq2w                       node:5
v54b375a0eb1-node-0-4-9t9dr                       node:5

3. Pod Resource Requests:
=== Pod Resource Requests ===
Pod Name	CPU	Memory
----------------------------------------
ml-pipeline-ui-artifact-55894b5986-xnmmg          10m  70Mi
ml-pipeline-visualizationserver-847879f7bb-lgfjd  50m  200Mi
mx-notebook-06-0                                  2    4Gi
v54b375a0eb1-node-0-0-gf89q                       5    2Gi
v54b375a0eb1-node-0-1-csg8z                       5    2Gi
v54b375a0eb1-node-0-2-8v9qj                       5    2Gi
v54b375a0eb1-node-0-3-qfq2w                       5    2Gi
v54b375a0eb1-node-0-4-9t9dr                       5    2Gi

4. Show workloads with Flavors Reservation and Usage:
=== Flavors Reservation and Usage ===
Flavor	Total
---------------------------------------------------------------------------------------
RESOURCE                  RESERVED (a100-80gb-nvlink)    USED (a100-80gb-nvlink)
------------------------  ------------------------------ ------------------------------
cpu                       27360m                         27360m
pods                      8                              8
ephemeral-storage         42460Mi                        42460Mi
nvidia.com/gpu            5                              5
memory                    14990Mi                        14990Mi
```



## References
* What is kubectl?: https://dockerlabs.collabnix.com/kubernetes/beginners/what-is-kubect.html
* The Main Components of Kubernetes Explained: https://www.linkedin.com/posts/nikkisiapno_the-main-components-of-kubernetes-explained-activity-7289900175534284801-JLVC
