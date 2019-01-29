#! /bin/csh -f
# manually confirm the skull stripping
# only edit the brainmask.man.mgz volume
#TODO fold FS and FSL way of creating the brainmask into one script...

#set the creator of the skull-strip
set mask_type = fsl # fsl or fs

# shall the old mask be kept, or shall we create a new one
set keep_man_mask = 1
# set the source directory...
set src_dir = ../mri
# set the target directory and file_name
set targ_dir = ../mri

# ckoose the underlay
set T1 = ${targ_dir}/T1.mgz

set input_mask = brainmask.${mask_type}.mgz
set manual_mask = brainmask.man.mgz
set canonical_mask = brainmask.mgz

# be smart...
if (!(-e ${targ_dir}/${manual_mask}) || (${keep_man_mask} == 0)) then
    # copy the selected brainmask.auto
    cp ${targ_dir}/${input_mask} ${targ_dir}/${manual_mask}    
endif

# edit the volume & check results...
tkmedit -f ${targ_dir}/${manual_mask} -aux $T1

# copy the selected
cp ${targ_dir}/${manual_mask} ${targ_dir}/${canonical_mask}

# last line follows...
