#!/usr/bin/sh

#SBATCH -J LuLab 
#SBATCH -p general 
#SBATCH -o output_%j.txt
#SBATCH -e error_%j.err
#SBATCH --mail-user=$USER@indiana.edu
#SBATCH --mail-type=ALL
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=64
#SBATCH --time=5:00:00
#SBATCH --mem=300GB

module load matlab
matlab -batch "Modol_script(\"$1\")"
