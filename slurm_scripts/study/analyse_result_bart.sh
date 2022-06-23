#!/bin/bash
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -J analyse
#SBATCH --gres=gpu:1
#SBATCH -p gpu
#SBATCH --mem=10G
#SBATCH --time=0-06:00:00

source /home/pgrimal/.bashrc
source activate cvlp

# variables
dataset=/scratch_global/stage_pgrimal/data/CVLP/data/datasets/vlbart_viquae_dataset/test
indice=vlbart_zs_avg_dict
passages=/scratch_global/stage_pgrimal/data/CVLP/data/datasets/bart_passages
kb=/scratch_global/stage_pgrimal/data/CVLP/data/datasets/kb
k=5
image=/scratch_global/stage_pgrimal/data/miniViQuAE/data/dataset/miniCommons/
save_path=/home/pgrimal/CVLEP/results/best_zs_vlbart

echo "processing relevant"
python -m processing.relevant \
    --indice=${indice} \
    --dataset_path=${dataset}

echo "create json"
python -m processing.analyse_result \
    --key=${indice} \
    --dataset_path=${dataset} \
    --kb_path=${kb} \
    --passages_path=${passages} \
    --k=${k} \
    --save_path=${save_path}

echo "get image"
python -m process_data.get_image \
    --image_path=${image} \
    --file_path=${save_path}/relevant.json \
    --folder_path=${save_path}/images

echo "DONE"
