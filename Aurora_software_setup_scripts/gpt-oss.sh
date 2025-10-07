#!/bin/bash
#For next-eval queue:
qsub -A datascience -q next-eval -l select=1 -l walltime=01:00:00,filesystems=flare:home -I

git clone https://github.com/openai/gpt-oss.git
cd gpt-oss/
#Nighly build:
source /flare/datascience/vhat/ml-scripts/node-local-envs/distribute_and_activate.sh /flare/datascience/vhat/build_torch/envs/nightly_20251007 pytorch_dev20251007_oneapi_2025.2.0_pti_0.12.3_numpy_2.2.6_python3.12.8
python -m pip install -e ".[torch]"
source /flare/datascience/vhat/ml-scripts/node-local-envs/repack_from_tmp.sh /flare/datascience/vhat/experiments/gpt-oss-inference pytorch_dev20251007_oneapi_2025.2.0_pti_0.12.3_numpy_2.2.6_python3.12.8
#For multi-node do also two below:
#conda deactivate
#For future activate with this
#source /flare/datascience/vhat/ml-scripts/node-local-envs/distribute_and_activate.sh /flare/datascience/vhat/experiments/gpt-oss-inference pytorch_dev20251007_oneapi_2025.2.0_pti_0.12.3_numpy_2.2.6_python3.12.8
cd /flare/datascience/vhat/experiments/gpt-oss-inference/gpt-oss
python -m torch.distributed.run --nproc-per-node=12 -m gpt_oss.generate gpt-oss-120b/original/ --backend torch