#!/bin/bash
#example: distribute_and_activate.sh /flare/AuroraGPT/vhat/TT_MoE pytorch_nightly_oneapi_2025.2.0_pti_0.12.3_numpy_2.2.6_python3.12.8
if [ "$#" -ne 2 ]; then
    echo "Two arguments are required, path to envs and env name"
    exit 0
fi

conda deactivate

export NNODES=$(cat $PBS_NODEFILE | uniq | wc -l)
#/flare/AuroraGPT/vhat/TT_MoE
ENVPATH=$1
if [[ "${ENVPATH: -1}" != "/" ]]; then
    ENVPATH="${ENVPATH}/"
fi
#pytorch_nightly_oneapi_2025.2.0_pti_0.12.3_numpy_2.2.6_python3.12.8
ENVNAME=$2

TARFILE=$ENVPATH$ENVNAME.tar
mkdir -p /tmp/conda_torch
mpiexec -n ${NNODES} --ppn 1 cp $TARFILE /tmp/
mpiexec -n ${NNODES} --ppn 1 tar -xf /tmp/$ENVNAME.tar -C /tmp/conda_torch
conda activate /tmp/conda_torch/$ENVNAME