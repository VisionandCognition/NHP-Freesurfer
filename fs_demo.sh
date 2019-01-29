# Freesurfer demo

# test FS
cd ~/Desktop
cp $FREESURFER_HOME/subjects/sample-001.mgz .
mri_convert sample-001.mgz sample-001.nii.gz

# if 'bert' doesn't exist yet
recon-all -i sample-001.nii.gz -s bert -all 
# if 'bert' already exists
recon-all -s bert -all

# view results
cd $SUBJECTS_DIR
freeview -v \
    bert/mri/T1.mgz \
    bert/mri/wm.mgz \
    bert/mri/brainmask.mgz \
    bert/mri/aseg.mgz:colormap=lut:opacity=0.2 \
    -f \
    bert/surf/lh.white:edgecolor=blue \
    bert/surf/lh.pial:edgecolor=red \
    bert/surf/rh.white:edgecolor=blue \
    bert/surf/rh.pial:edgecolor=red