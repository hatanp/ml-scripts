cd /flare/AuroraGPT/vhat/TT_MoE/torchtitan
set -x
#torchrun --nproc_per_node=1 --rdzv_backend c10d --rdzv_endpoint="$MASTER_ADDR:$MASTER_PORT" \
#--local-ranks-filter ${LOG_RANK} --local_rank=$LOCAL_RANK --role rank --tee 3 \
#-m torchtitan.train --job.config_file ${CONFIG_FILE} $overrides

python /flare/AuroraGPT/vhat/TT_MoE/torchtitan_main/torchtitan/torchtitan/train.py --job.config_file ${CONFIG_FILE} $overrides