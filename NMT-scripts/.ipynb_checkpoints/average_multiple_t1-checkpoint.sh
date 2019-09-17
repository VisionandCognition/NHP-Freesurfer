#!/bin/bash
set -e # exit if a command fails

# assumes first argument is a folder with multiple T1's
in_fld=$1
startpath=pwd; 
subj=${PWD##*/} # get monkey name from the folder we're in

cd ${in_fld} # go to the specified folder
mkdir -p output

# define a preprocessing routing
preprocess_indiv () {
  mri_convert -i ${1} -o rs_${1} --sphinx -vs 0.5 0.5 0.5
  fslreorient2std rs_${1} rs_${1}
  mri_nu_correct.mni --i rs_${1} --o ./output/ro_${1} --distance 24
  rm rs_${1}
}

# do the preprocessing
for f in *.nii.gz; do
  preprocess_indiv $f &
done
wait # wait for individual files preprocessing

# initiate the averaging command
cmd="mri_motion_correct.fsl -o ../${subj}.nii.gz"

# add the preprocessed files
for f in ./output/ro_*.nii.gz; do
    cmd="${cmd} -i ${f}"
done

eval ${cmd} # evaluate the averaging command

wait
 
rm -R ../*mri_motion_correct.fsl*

cd $startpath