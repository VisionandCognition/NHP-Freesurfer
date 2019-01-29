#! /bin/csh -f
# create the input files for the proper segmentation
# fsl allows more control over the intensity normalisation...
# from here on both ways are merged...

# set the source directory...
set src_dir = ../mri

# set the target directory and file_name
set targ_dir = ../mri

# common vars
set controlpoints = ../tmp/control.dat
set unmasked_brain = ${targ_dir}/brain.unmasked.mgz
set brain = ${targ_dir}/brain.mgz
set mask = ${targ_dir}/brainmask.mgz
set final = ${targ_dir}/brain.finalsurfs.mgz

if !(-e ${src_dir}/brainmask.auto.mgz.bak) then
    cp ${src_dir}/brainmask.auto.mgz ${src_dir}/brainmask.auto.mgz.bak
    cp ${src_dir}/brainmask.mgz ${src_dir}/brainmask.auto.mgz
endif


# use FSLs idea of a nu
set use_fsl_nu = 0

if (${use_fsl_nu} == 0) then
    # the FS way
    set in_vol = ${src_dir}/nu.mgz #T1.mgz #orig.mgz
    
    mri_normalize -f ${controlpoints} -monkey -MASK ${mask} ${in_vol} ${unmasked_brain}
    # mask the brain out, manual mask edits have a low value of 1 by default, so
    #	set the low cutoff at 2
    set threshold = "-T 2"
    mri_mask ${threshold} ${unmasked_brain} ${mask} ${brain}
    # control the results
    tkmedit -f ${brain}


    # mask the brain out, side step aseg...
    set threshold = "-T 2"
    mri_mask ${threshold} ${unmasked_brain} ${mask} ${final}
    tkmedit -f ${final}
else
    # the FSL way
    set in_vol = ${src_dir}/fsl_conf_nu.mgz #T1.mgz #orig.mgz
    set tmp_vol = ${src_dir}/fsl_nu.mgz
    # make it 8bit...
    mri_convert -i ${tmp_vol} -o ${in_vol} --conform

    mri_normalize -f ${controlpoints} -monkey -MASK ${mask} ${in_vol} ${unmasked_brain}
    # mask the brain out, manual mask edits have a low value of 1 by default, so
    #	set the low cutoff at 2
    set threshold = "-T 2"
    mri_mask ${threshold} ${unmasked_brain} ${mask} ${brain}
    # control the results
    tkmedit -f ${brain}


    # mask the brain out, side step aseg...
    set threshold = "-T 2"
    mri_mask ${threshold} ${unmasked_brain} ${mask} ${final}
    tkmedit -f ${final}    
endif

# last line follows...
