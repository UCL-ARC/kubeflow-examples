# Install dependencies and run script
# pip install kubeflow torch torchvision
# python quickstart.py

import kubeflow.trainer
import time

config = kubeflow.trainer.KubernetesBackendConfig()
trainer = kubeflow.trainer.TrainerClient(backend_config=config)

# ==================== CONFIGURATION ====================
# Set your distributed environment configuration here
NUM_NODES = 5
RESOURCES_PER_NODE = {
    "nvidia.com/gpu": 2  # Adjust GPU type/quantity as needed
}
# Other possible resources:
# RESOURCES_PER_NODE = {
#     "nvidia.com/gpu": 2,  # 2 GPUs per node
#     "cpu": "4",           # 4 CPUs per node
#     "memory": "8Gi"       # 8GB memory per node
# }
# =======================================================


def get_torch_dist():
    import os
    import torch
    import torch.distributed as dist

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
        num_nodes=NUM_NODES,
        resources_per_node=RESOURCES_PER_NODE,
    ),
)

while True:
    initial_logs = list(trainer.get_job_logs(job_id, follow=False))
    if initial_logs:
        break
    time.sleep(1)

for logline in trainer.get_job_logs(job_id, follow=True):
    print(logline)
