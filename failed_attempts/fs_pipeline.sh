#!/bin/bash
# freesurfer pipeline for monkeys
# c.klink@nin.knaw.nl

## SET SOME VARIABLES #####################################################
fsSUB=Danny  #NMT
BRAIN_0=$fsSUB.nii.gz
#BRAIN_0_path=/NHP_MRI/Template/NMT/single_subject_scans/$fsSUB
BRAIN_0_path=/Users/chris/Dropbox/CURRENT_PROJECTS/NHP_MRI/T1/$fsSUB  #/NHP_MRI/Template/$fsSUB
NMT_path=/NHP_MRI/Template/NMT

tmpdir=~/fs_tmp
SCRIPT_path=$(pwd)

## STEP 00 - Prepping the data & initiate #################################
# copy to temp folder
mkdir -p $tmpdir
cp $BRAIN_0_path/$BRAIN_0 $tmpdir/tmp_brain.nii.gz
# align rigidly to NMT
flirt -in $tmpdir/tmp_brain.nii.gz \
    -ref $NMT_path/NMT.nii.gz \
    -out $tmpdir/tal_brain.nii.gz \
    -omat $tmpdir/brain_to_tal.mat \
    -dof 6
# resample to 0.5 mm iso    
mri_convert -i $tmpdir/tal_brain.nii.gz \
    -o $tmpdir/tal_brain_rs.nii.gz \
    -vs 0.5 0.5 0.5
# fake the header to make fs think we have 1 mm voxels   
3drefit -xdel 1.0 -ydel 1.0 -zdel 1.0 -keepcen $tmpdir/tal_brain_rs.nii.gz

# additional allignment to make things work
# 1 - center between left/right should be at 128
# 2 - AC and PC should be at same height
freeview -v $tmpdir/tal_brain_rs.nii.gz
# save the corrected volume as tal_brain_rs2.mgz 

## STEP 01 - CROP THE VOLUME TO 25x256x256 ################################
# find center
freeview $tmpdir/tal_brain_rs2.nii.gz
CTR[1]=63
CTR[2]=87
CTR[3]=61

mri_convert -i $tmpdir/tal_brain_rs2.nii.gz \
    -o $tmpdir/orig.mgz \
    --crop ${CTR[1]} ${CTR[2]} ${CTR[3]} \
    --conform -nc


## STEP 02 - SKULL-STRIP ##################################################
WST=30 # play with this parameter to get better skullstrip (30/24/15)
recon-all -i $tmpdir/orig.mgz -subjid $fsSUB \
    -autorecon1 -no-wsgcaatlas -wsthresh $WST \
    -notal-check -notalairach

# check skullstripping result with:
freeview -v $SUBJECTS_DIR/$fsSUB/mri/T1.mgz \
    $SUBJECTS_DIR/$fsSUB/mri/brainmask.mgz

# if necessary (cerebellum should be present!), rerun skullstrip with:
WST2=10
recon-all -subjid $fsSUB -skullstrip \
    -no-wsgcaatlas -wsthresh $WST2 \
    -notal-check -notalairach -clean-bm

# manually adjust brainmask.nii.gz untill ok
freeview -v $SUBJECTS_DIR/$fsSUB/mri/T1.mgz \
    $SUBJECTS_DIR/$fsSUB/mri/brainmask.mgz


## STEP 03 - SEGMENTATION #################################################
# get corpus callosum and pons coordinates

CC[1]=129 #130 X
CC[2]=119 #116 Y
CC[3]=138 #140 Z
PONS[1]=127
PONS[2]=151
PONS[3]=119

# first stab at freesurfer reconstruction
recon-all -s $fsSUB -autorecon2-inflate1 -noaseg \
    -cc-crs ${CC[1]} ${CC[2]} ${CC[3]} \
    -pons-crs ${PONS[1]} ${PONS[2]} ${PONS[3]} \
    -notal-check -notalairach


# add control points to improve (see freesurfer documentation)
freeview -v $SUBJECTS_DIR/$fsSUB/mri/brainmask.mgz \
    $SUBJECTS_DIR/$fsSUB/mri/wm.mgz:colormap=heat:opacity=0.4 \
    -f $SUBJECTS_DIR/$fsSUB/surf/lh.orig.nofix:edgecolor=yellow \
    $SUBJECTS_DIR/$fsSUB/surf/rh.orig.nofix:edgecolor=yellow \
    $SUBJECTS_DIR/$fsSUB/surf/rh.inflated.nofix:visible=0 \
    $SUBJECTS_DIR/$fsSUB/surf/lh.inflated.nofix:visible=0

# pick seed point in hemispheres to try to fix the cutting error
LH[1]=144
LH[2]=11
LH[3]=129 # X Y Z left hemisphere
RH[1]=110
RH[2]=113
RH[3]=131 # X Y Z right hemisphere

# rerun taking control points into account
recon-all -s $fsSUB -autorecon2-inflate1 -noaseg \
    -cc-crs ${CC[1]} ${CC[2]} ${CC[3]} \
    -pons-crs ${PONS[1]} ${PONS[2]} ${PONS[3]} \
    -notal-check -notalairach

# repeat untill ok
# manually edit WM

# check in surface rendering using
tksurfer $MONKEY rh inflated.nofix


## STEP 04 - INFLATE ######################################################
# this one will take many hours so make sure 
# you're happy with the previous results

recon-all -s $fsSUB -autorecon2-wm -noaseg \
    -cc-crs ${CC[1]} ${CC[2]} ${CC[3]} \
    -pons-crs ${PONS[1]} ${PONS[2]} ${PONS[3]}