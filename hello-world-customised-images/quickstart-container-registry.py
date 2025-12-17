import kubeflow.trainer
import time

config = kubeflow.trainer.KubernetesBackendConfig()
trainer = kubeflow.trainer.TrainerClient(backend_config=config)


command = kubeflow.trainer.options.TrainerCommand(command=["./my-entrypoint.sh"])
job_id = trainer.train(
    runtime=trainer.get_runtime("torch-distributed"),
    trainer=kubeflow.trainer.CustomTrainerContainer(
        image="ghcr.io/my-org/my-image:v1.0.0",
    ),
    options=[command],
)


while True:
    initial_logs = list(trainer.get_job_logs(job_id, follow=False))
    if initial_logs:
        break
    time.sleep(1)

for logline in trainer.get_job_logs(job_id, follow=True):
    print(logline)
