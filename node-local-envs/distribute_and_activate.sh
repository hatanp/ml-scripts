#!/bin/bash
#example: distribute_and_activate.sh /flare/AuroraGPT/vhat/TT_MoE pytorch_nightly_oneapi_2025.2.0_pti_0.12.3_numpy_2.2.6_python3.12.8
if [ "$#" -ne 2 ]; then
    echo "Two arguments are required, path and env name"
else
    conda deactivate

    export NNODES=$(cat $PBS_NODEFILE | uniq | wc -l)
    #/flare/AuroraGPT/vhat/TT_MoE
    PATH=$1
    if [[ "${PATH: -1}" != "/" ]]; then
        PATH="${PATH}/"
    fi
    #pytorch_nightly_oneapi_2025.2.0_pti_0.12.3_numpy_2.2.6_python3.12.8
    ENVNAME=$2

    TARFILE=$PATH$ENVNAME.tar
    mpiexec -n ${NNODES} --ppn 1 cp $TARFILE /tmp/
    mpiexec -n ${NNODES} --ppn 1 tar -xf /tmp/$ENVNAME.tar -C /tmp
    conda activate /tmp/$ENVNAME
fi