#!/bin/bash
#Default PBS requests if not overridden on qsub command line
#PBS -l nodes=1:ppn=4
#PBS -l walltime=24:00:00
#PBS -A mnh5174_c_g_sc_default
#PBS -j oe

set -e
cd $PBS_O_WORKDIR

####
#setup compute environment
[ -z "$pipedir" ] && pipedir="$PWD"
source "${pipedir}/pipeline_functions"

#in principle, we could pass all environment variables in with -v
[ -z "$env_file" ] && env_file="${pipedir}/compute_environment.cfg" #set default
[ ! -r "$env_file" ]  && echo "Cannot access compute config file ${env_file}" && exit 1
source "$env_file" #setup relevant variables for this processing environment

[[ -n "${study_cfg}" && -r "${study_cfg}" ]] && source "${study_cfg}" #source a study config file if passed as environment variable

####
#verify necessary arguments
[ -z "$fmriprep_nthreads" ] && echo "No fmriprep_nthreads environment variable. Defaulting to 4" && fmriprep_nthreads=4
[ -z "$loc_mrproc_root" ] && echo "loc_mrproc_root not set. Exiting." && exit 1
[ -z "$loc_root" ] && echo "loc_root not set. Exiting." && exit 1
[ -z "$loc_bids_root" ] && echo "loc_bids_root not set. Exiting." && exit 1
[ -z "$sub" ] && echo "sub not set. Exiting." && exit 1

####
[[ "$debug_pipeline" -eq 1 ]] && rel_suffix=c #if debug_pipeline is 1, only echo command to log, don't run it
rel "${pipedir}/fmriprep_wrapper ${loc_bids_root} ${loc_mrproc_root}/ participant --participant_label $sub --nthreads $fmriprep_nthreads -w ${loc_root}/fmriprep_tempfiles" $rel_suffix

#add --low-mem?
#add --mem-mb?
