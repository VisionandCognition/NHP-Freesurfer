#! /bin/csh -f
# make sure the input volume is 256 by 256 by 256 voxels in size

# set the source directory...
set src_dir = ../mri
# set the target directory and file_name
set targ_dir = ../mri
set src_vol = conformed_rawavg.mgz
set fsl_src_vol = fsl_${src_vol}
set targ_vol = $src_vol
set fsl_targ_vol = fsl_${targ_vol}

set start_dir = `pwd`
cd ../
set session = [0-9][0-9][0-9][0-9][0-9][0-9][A-Z]*
cd $start_dir

# the voxel dimenswions are already tweaked to 1mm isotropic, now enforce 256 x 256 x 256 voxels
mri_convert -i ${src_dir}/$src_vol -o ${targ_dir}/$targ_vol --conform
mri_convert -i ${src_dir}/$fsl_src_vol -o ${targ_dir}/$fsl_targ_vol --conform --no_scale 1 -nc # do not reduce to 8 bit yet

#tkmedit -f ${targ_dir}/tmp_$fsl_targ_vol
#mri_info ${targ_dir}/tmp_$fsl_targ_vol
# last line follows...
