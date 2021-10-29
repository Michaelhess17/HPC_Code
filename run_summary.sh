#!/usr/bin/sh

#SBATCH -J LuLab 
#SBATCH -p general 
#SBATCH -o output_%j.txt
#SBATCH -e error_%j.err
#SBATCH --mail-type=END
#SBATCH --mail-user=$USER@indiana.edu
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=12
#SBATCH --time=1:00:00
#SBATCH --mem=64GB

module load matlab
matlab -batch "Summarize_Modol(\"$1\")"

