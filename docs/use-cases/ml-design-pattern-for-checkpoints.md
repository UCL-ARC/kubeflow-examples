---
title: Design pattern for checkpoints
description:
weight: 2
---

## Checkpoint Design Pattern
Saving intermediate checkpoints makes training more reliable. 
Long training runs or work spread across several machines might be prone to fail. 
Checkpoints allow PyTorch to restart from the last saved point instead of beginning again from scratch.

Checkpoints also help with generalisation. 
Training loss may keep falling, but validation error can stop improving or even rise because of overfitting. 
Saving checkpoints regularly lets you return to the model with the best validation results or stop training at the right time.

They also make training easier to adjust. 
Models usually reach a good solution quickly and then improve slowly by focusing on edge cases. 
When training again with new data, it is often better to restart from an earlier checkpoint so the model focuses on new information rather than older details.

![Kubernetes basic components](../assets/images/ml-design-pattern-checkpoints.svg)


## Synthetic Fetal Ultrasound Applying Elucidating Diffusion Models 2

“Analyzing and Improving the Training Dynamics of Diffusion Models”, often called the EDM2 paper, stands for “Elucidating Diffusion Models 2”. It is a direct follow-up to the authors’ earlier and widely cited paper, “Elucidating the Design Space of Diffusion-Based Generative Models” (NeurIPS 2022), commonly known as the EDM paper.

