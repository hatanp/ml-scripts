#!/bin/bash
#example: repack_from_tmp.sh /flare/AuroraGPT/vhat/TT_MoE pytorch_nightly_oneapi_2025.2.0_pti_0.12.3_numpy_2.2.6_python3.12.8
if [ "$#" -ne 2 ]; then
    echo "Two arguments are required, path and env name"
    exit 0
fi

cd /tmp
#/flare/AuroraGPT/vhat/TT_MoE
ENVPATH=$1
if [[ "${ENVPATH: -1}" != "/" ]]; then
    ENVPATH="${ENVPATH}/"
fi
#pytorch_nightly_oneapi_2025.2.0_pti_0.12.3_numpy_2.2.6_python3.12.8
ENVNAME=$2

tar -cf $ENVNAME.tar -C /tmp/conda_torch $ENVNAME
#cp /tmp/$ENV_NAME.tar /your/path/here/
cp /tmp/$ENVNAME.tar $ENVPATH