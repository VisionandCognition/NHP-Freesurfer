#!/bin/bash 
# this script will give you some handles for creating inflated brain surfaces
# and getting started with freesurfer for flatmap functionality

# it's work in progress so it's far from complete

# Chris Klink (c.klink@nin.knaw.nl)

## INPUT #################################################################################
# I assume you have manually corrected the segmentation that was previously generated
# by using the NMT template segmentation as priors (this is a reasonably good start)
# pick the best possible segmentation as input and adjust where necessary

# adjust these for your system --
SEGM_path="/NHP_MRI/Template/NMT/single_subject_scans/Danny/NMT_Danny_process/manual_adjust" # path to segmentation file
SEGM=Danny_segmentation.nii.gz # segmentation file
BRAIN_path=$SEGM_path # path to brain file
BRAIN=Danny_brain.nii.gz # brain file (best possible)
NMT_path="/NHP_MRI/Template/NMT"

OUTPUT=~/Desktop/Surf
SCRIPT_path=$(pwd)

MONKEY='Danny'

mkdir $OUTPUT
cd $OUTPUT

## Extract segmented classes to surfaces and rename ######################################
# Requires:
# AFNI (https://afni.nimh.nih.gov/) 
# Connectome Workbench (https://www.humanconnectome.org/software/connectome-workbench)
echo 'Extracting surfaces from segmentation'
IsoSurface  -input $SEGM_path/$SEGM -isorois -o_gii surf
mv surf.k1.gii csf.surf.gii # csf surface (unused)
mv surf.k2.gii gm.surf.gii # gm surface
mv surf.k3.gii wm.surf.gii # wm surface

# Smooth these surfaces a bit
echo 'Smoothing the surfaces a bit' 
wb_command -surface-smoothing wm.surf.gii 0.5 1 wm_sm.surf.gii
wb_command -surface-smoothing gm.surf.gii 0.5 1 gm_sm.surf.gii

# inflate the surfaces
echo 'Inflating the surfaces'
wb_command -surface-generate-inflated wm_sm.surf.gii infl_wm_sm.surf.gii vinfl_wm_sm.surf.gii
wb_command -surface-generate-inflated gm_sm.surf.gii infl_gm_sm.surf.gii vinfl_gm_sm.surf.gii

# view the result in your favorite viewer
# here I use freesurfer's freeview
echo 'Inspect the surfaces in a viewer'
freeview -f wm_sm.surf.gii infl_wm_sm.surf.gii vinfl_wm_sm.surf.gii \
    gm_sm.surf.gii infl_gm_sm.surf.gii vinfl_gm_sm.surf.gii


## Freesurfer ###########################################################################
# Requires 
# FSL (https://www.fmrib.ox.ac.uk/fsl)
# Freesurfer (https://surfer.nmr.mgh.harvard.edu/)
# >>>>>>>>>> THIS IS WORK IN PROGRESS [INCOMPLETE] <<<<<<<<<

# copy the brain image to the output folder
cp $BRAIN_path/$BRAIN brain.nii.gz

# use the WM segment to enhance T1 contrast
echo 'Enhancing T1 contrast with segmentation'
GAIN=0.5 #1+gain
fslmaths $SEGM_path/$SEGM -thr 2.8 -bin wm_seg.nii.gz
fslmaths wm_seg.nii.gz -add $GAIN wm_gain.nii.gz
fslmaths brain.nii.gz -mul wm_gain.nii.gz brain_enhanced.nii.gz

# align rigidly to NMT to do pseudo-Talairach
flirt -in brain_enhanced.nii.gz \
    -ref $NMT_path/NMT_SS.nii.gz \
    -out brain_enh_tal.nii.gz \
    -omat brain_to_tal.mat \
    -dof 6

flirt -in brain.nii.gz \
    -ref $NMT_path/NMT_SS.nii.gz \
    -applyxfm -init brain_to_tal.mat \
    -out brain_tal.nii.gz


# 3drefit to trick freesurfer into thinking voxels are 1 mm iso
3drefit -xdel 1.0 -ydel 1.0 -zdel 1.0 brain_enh_tal.nii.gz
3drefit -xdel 1.0 -ydel 1.0 -zdel 1.0 brain_tal.nii.gz

mksubjdirs $SUBJECTS_DIR/$MONKEY # SUBJECTS_DIR should be defined in freesurfer install
mri_convert brain_enh_tal.nii.gz $SUBJECTS_DIR/$MONKEY/mri/orig/001.mgz

# FS step 1: Skullstrip (has been done already so should be ok)
recon-all -subjid $MONKEY -autorecon1 -no-wsgcaatlas -wsthresh 15 -notal-check -cw256

# Pick cutting points (corpus callosum and pons)
# -cc-crs= 127 112 144 
# -pons_crs= 125 139 122

# first stab at freesurfer reconstruction
recon-all -s $MONKEY -autorecon2-inflate1 -noaseg -cc-crs 127 112 144 -pons-crs 125 139 122 

# add control points to improve (see freesurfer documentation)
freeview -v $SUBJECTS_DIR/$MONKEY/mri/brainmask.mgz \
    $SUBJECTS_DIR/$MONKEY/mri/wm.mgz:colormap=heat:opacity=0.4 \
    -f $SUBJECTS_DIR/$MONKEY/surf/lh.orig.nofix:edgecolor=yellow \
    $SUBJECTS_DIR/$MONKEY/surf/rh.orig.nofix:edgecolor=yellow \
    $SUBJECTS_DIR/$MONKEY/surf/rh.inflated.nofix:visible=0 \
    $SUBJECTS_DIR/$MONKEY/surf/lh.inflated.nofix:visible=0

# rerun taking control points into account
recon-all -s $MONKEY -autorecon2-inflate1 -noaseg -cc-crs 127 112 144 -pons-crs 125 139 122

# repeat untill ok
# manually edit WM

# check in surface rendering using
tksurfer $MONKEY rh inflated.nofix


cd $SCRIPT_path
