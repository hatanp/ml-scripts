#!/usr/bin/bash
export LOCAL_RANK=$PALS_LOCAL_RANKID
export RANK=$PMIX_RANK

echo $PALS_LOCAL_RANKID/12, $RANK/$WORLD_SIZE $CCL_ATL_TRANSPORT
source /flare/AuroraGPT/vhat/TT_MoE/exec_wrap_inner.sh