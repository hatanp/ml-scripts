#!/usr/bin/bash
export LOCAL_RANK=$PALS_LOCAL_RANKID
export RANK=$PMIX_RANK

echo $PALS_LOCAL_RANKID/12, $RANK/$WORLD_SIZE $CCL_ATL_TRANSPORT
#python -m gpt_oss.generate gpt-oss-120b/original/ --backend torch
$@