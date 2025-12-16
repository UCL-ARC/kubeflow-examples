#!/bin/bash

# Set up environment variables for distributed training
export LOCAL_RANK=${LOCAL_RANK:-0}
export RANK=${RANK:-0}
export WORLD_SIZE=${WORLD_SIZE:-1}

# Execute the Python script
python -c "
import os
import torch
import torch.distributed as dist

def get_torch_dist():
    device, backend = (\"cuda\", \"nccl\") if torch.cuda.is_available() else (\"cpu\", \"gloo\")
    
    # Initialize process group
    dist.init_process_group(
        backend=backend,
        world_size=int(os.environ.get('WORLD_SIZE', 1)),
        rank=int(os.environ.get('RANK', 0))
    )
    
    print(\"PyTorch Distributed Environment\")
    print(f\"Using device: {device}\")
    print(f\"WORLD_SIZE: {dist.get_world_size()}\")
    print(f\"RANK: {dist.get_rank()}\")
    print(f\"LOCAL_RANK: {os.environ.get('LOCAL_RANK', '0')}\")
    
    # Clean up
    dist.destroy_process_group()

# Call the function
get_torch_dist()
"
