#! /bin/csh -f
# segment the white matter
#setenv FIX_VERTEX_AREA
# set the source directory...
set src_dir = ../mri

# set the target directory and file_name
set targ_dir = ../mri
set src_vol = brain.mgz #T1.mgz
#set brain = brain.mgz
#set brainmask = brainmask.mgz
set targ_vol = wm.mgz
#set controlpoints = ../tmp/control.dat

#usage: mri_segment <classifier file> <input volume> <output volume>
#	-slope <float s>  set the curvature slope (both n and p)
#	-pslope <float p> set the curvature pslope (default=1.0)
#	-nslope <float n> set the curvature nslope (default=1.0)
#	-debug_voxel <int x y z> set voxel for debugging
#	-auto             automatically detect class statistics (default)
#	-noauto           don't automatically detect class statistics
#	-log              log to ./segment.dat
#	-keep             keep wm edits. maintains all values of 0 and 255
#	-ghi, -gray_hi <int h> set the gray matter high limit (default=100.000)
#	-wlo, -wm_low  <int l> set the white matter low limit (default=90.000)
#	-whi, -wm_hi <int h>   set the white matter high limit (default=125.000)
#	-nseg <int n>      thicken the n largest thin strands (default=20)
#	-thicken           toggle thickening step (default=ON)
#	-fillbg            toggle filling of the basal ganglia (default=OFF)
#	-fillv             toggle filling of the ventricles (default=OFF)
#	-b <float s>       set blur sigma (default=0.25)
#	-n <int i>         set # iterations of border classification (default=1)
#	-t <int t>         set limit to thin strands in mm (default=4)
#	-v                 verbose
#	-p <float p>       set % threshold (default=0.80)
#	-x <filename>      extract options from filename
#	-w <int w>         set wsize (default=11)
#	-u                 usage

# do the heavy lifting...
#mri_segment ${src_dir}/${src_vol} ${targ_dir}/${targ_vol}
#mri_segment -v -fillv -fillbg -keep ${src_dir}/${src_vol} ${targ_dir}/${targ_vol}
set wlo = 100
set ghi = 105
set border_class_it = 2
if (-e ${src_dir}/wm.mgz) then
    mri_segment 	-v \
			-fillv \
			-fillbg \
			-keep \
			-wlo $wlo \
			-ghi $ghi \
			-n $border_class_it \
			${src_dir}/${src_vol} ${targ_dir}/${targ_vol}
else
    mri_segment 	-v \
			-fillv \
			-fillbg \
			-wlo $wlo \
			-ghi $ghi \
			-n $border_class_it \
			${src_dir}/${src_vol} ${targ_dir}/${targ_vol}
endif

# last line...
