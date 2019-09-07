#!/bin/bash
#Align and process single subject data using the NIMH Macaque Template.
##Example: bash align_and_process_example.sh Danny

SUBJ=${1}

echo "Aligning and processing single subject scans using the NIMH Macaque Template:"
echo "1) Changing your current directory"
cd "$(dirname $0)/${SUBJ}"
echo "2) Aligning Single Subject Scan to the NIMH Macaque Template and align the D99 atlas to your single subject scan"

tcsh ../../NMT_subject_align.csh ${SUBJ}.nii.gz ../../NMT.nii.gz ../../atlases/D99_atlas/D99_atlas_1.2a_al2NMT.nii.gz

if [ -z ${ANTSPATH+x} ]
    then
        echo "ANTSPATH could be found. While this will not affect NMT_subject_align.csh, "
        echo "both NMT_subject_morph and NMT_subject process require ANTs to be installed."
    else
        echo "3) Perform skull-striping and segmentation on you single subject dataset:"
        bash ../../NMT_subject_process ${SUBJ}.nii.gz
        echo "4) Estimate cortical thickness, surface area and curvature for single subject:"
        bash ../../NMT_subject_morph ${SUBJ}.nii.gz
fi
