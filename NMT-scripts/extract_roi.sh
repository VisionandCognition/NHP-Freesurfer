#!/bin/bash
MONKEY=$1
ROI_FLD=$MONKEY/ROI
mkdir -p $ROI_FLD

filename="../atlases/D99_atlas/D99_labeltable_reformat.txt"

while read -r line
do
    set $line
    LABLENUM=$1
    LABLENAME=$2
    echo "${MONKEY}: Creating ROI mask for $LABLENAME"
    fslmaths ${MONKEY}/D99_in_${MONKEY}.nii.gz \
        -thr $LABLENUM \
        -uthr $LABLENUM \
        -bin $ROI_FLD/${LABLENAME}.nii.gz
done < "$filename"

