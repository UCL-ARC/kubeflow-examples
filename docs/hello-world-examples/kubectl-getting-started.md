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

Important fields include:#

* **Parallelism / **Completions: How many Pods run in parallel and how many must complete.
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

**Extract Pod Names and CPU Requests**

Lists all Pods. Prints the Pod name followed by the CPU request for each container. Useful for checking resource requests across workloads.

```bash
kubectl get pods -o=jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[].resources.requests.cpu}{"\n"}{end}'
```

**Filter Pods Using jq**

Retrieves all Pods in JSON format. Uses jq to filter Pods that are failing to pull container images. Prints only the names of affected Pods.

This is particularly useful for quickly identifying broken or misconfigured workloads.

```bash
kubectl get pods -o json | jq -r '.items[]| select(.status.phase=="Running").metadata.name'
```






## References
* What is kubectl?: https://dockerlabs.collabnix.com/kubernetes/beginners/what-is-kubect.html
* The Main Components of Kubernetes Explained: https://www.linkedin.com/posts/nikkisiapno_the-main-components-of-kubernetes-explained-activity-7289900175534284801-JLVC

