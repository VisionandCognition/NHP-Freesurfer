#! /bin/csh -f
# use tkmedit to find the cutt off points (voxel coordinates) for pons and corpus callosum
#	for CC just pick the coordinates of a voxel in the middle of the CC
#
#	pick the pons on a slice, where midbrain and cerebellum are not yet connected
#	make sure the is a t least a two pixel wide separation between cerebellum and midbrain
#	then delete the midbrain the downward next two slices, so C and MB are properly separated
#	make sure there are no C-MB connections above the cutting plane


# set the source directory...
set src_dir = ../mri

# set the target directory and file_name
set targ_dir = ../mri
set src_vol = T1.mgz
#set brain = brain.mgz
set targ_vol = wm.mgz
#set controlpoints = ../tmp/control.dat

# display the volume
tkmedit -f ${targ_dir}/wm.mgz -aux ${targ_dir}/${src_vol}

# last line follows...
