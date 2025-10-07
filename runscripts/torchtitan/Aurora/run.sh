#!/usr/bin/bash
# Copyright (c) Meta Platforms, Inc. and affiliates.
# All rights reserved.

# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.

#set -ex

# use envs as local overrides for convenience
# e.g.
# LOG_RANK=0,1 NGPU=4 ./run_train.sh

cd /flare/AuroraGPT/vhat/TT_MoE
source ml-scripts/distributed_env/aurora.sh

export NGPU=12
export PBS_JOBSIZE=$(cat $PBS_NODEFILE | uniq | wc -l)
export NNODES=$PBS_JOBSIZE
export WORLD_SIZE=$((NGPU*PBS_JOBSIZE))

export CONFIG_FILE="torchtitan/models/llama3/train_configs/llama3_debug.toml"

export MASTER_ADDR=$(head -n 1 ${PBS_NODEFILE})
export MASTER_PORT=29504

export LOG_RANK=${LOG_RANK:-0}

mpiexec --pmi=pmix --env CCL_PROCESS_LAUNCHER=pmix --env CCL_ATL_TRANSPORT=mpi \
-n $((NNODES*NGPU)) --ppn ${NGPU} --cpu-bind $CPU_BIND \
/flare/AuroraGPT/vhat/TT_MoE/exec_wrapd.sh
