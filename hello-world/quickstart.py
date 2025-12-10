# Install kubeflow and run script
# pip install kubeflow
# python3 trainer-quickstart.py

import os
import torch
import torch.distributed as dist
import kubeflow.trainer
import time

config = kubeflow.trainer.KubernetesBackendConfig()
trainer = kubeflow.trainer.TrainerClient(backend_config=config)

def get_torch_dist():
    device, backend = ("cuda", "nccl") if torch.cuda.is_available() else ("cpu", "gloo")
    dist.init_process_group(backend)
    print("PyTorch Distributed Environment")
    print(f"Using device: {device}")
    print(f"WORLD_SIZE: {dist.get_world_size()}")
    print(f"RANK: {dist.get_rank()}")
    print(f"LOCAL_RANK: {os.environ['LOCAL_RANK']}")
    dist.destroy_process_group()

 job_id = trainer.train(
    runtime=trainer.get_runtime("torch-distributed"),
    trainer=kubeflow.trainer.CustomTrainer(
        func=get_torch_dist,
        num_nodes=3,
        resources_per_node={
            "nvidia.com/gpu": 0
        }),
)

while True:
    initial_logs = list(trainer.get_job_logs(job_id, follow=False))
    if initial_logs:
        break
    time.sleep(1)

for logline in trainer.get_job_logs(job_id, follow=True):
    print(logline)
