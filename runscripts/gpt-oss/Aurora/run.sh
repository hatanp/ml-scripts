#!/usr/bin/bash

#source /flare/datascience/vhat/ml-scripts/node-local-envs/distribute_and_activate.sh /flare/datascience/vhat/experiments/gpt-oss-inference pytorch_dev20251007_oneapi_2025.2.0_pti_0.12.3_numpy_2.2.6_python3.12.8
#cd /flare/datascience/vhat/experiments/gpt-oss-inference/gpt-oss
#cd /flare/datascience/vhat/ml-scripts
SCRIPTS_LOCATION=/flare/datascience/vhat/ml-scripts

source ${SCRIPTS_LOCATION}/distributed_env/aurora.sh

export NGPU=12
export PBS_JOBSIZE=$(cat $PBS_NODEFILE | uniq | wc -l)
export NNODES=$PBS_JOBSIZE
export WORLD_SIZE=$((NGPU*PBS_JOBSIZE))

export MASTER_ADDR=$(head -n 1 ${PBS_NODEFILE})
export MASTER_PORT=29505

mpiexec --pmi=pmix --env CCL_PROCESS_LAUNCHER=pmix --env CCL_ATL_TRANSPORT=mpi \
-n $((NNODES*NGPU)) --ppn ${NGPU} --cpu-bind $CPU_BIND \
${SCRIPTS_LOCATION}/runscripts/exec_wrapd_any.sh python -m gpt_oss.generate gpt-oss-20b/original/ --backend torch $@
#torchrun --standalone --nnodes=1 --nproc-per-node=12 -m gpt_oss.generate gpt-oss-120b/original/ --backend torch