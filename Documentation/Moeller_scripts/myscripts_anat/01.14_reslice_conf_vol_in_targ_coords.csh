#! /bin/csh -f
# reslice the conformed_rawavg.mgz into the coordinate system described
# the rotate_conf_2_${reg_id}.dat file
# add ${reg_id} to the output file names, ecept for "atlas" as this is the way
# towards a proper surface reconstruction, where we want to use freesurfer default names
# if we find a fsl_${src_vol} (this is at full scanner bit resolution) also produce fsl_${targ_vol}
# mri_vol2vol got changed in version stable4 to not accept --in and --out anymore
# fix this for good


set check_result = 1	# use tkmedit/tkregister2 to see the results
# select the registration file to use
set reg_id = "atlas"
#set reg_id = "electrode"
#set reg_id = "chamber"
#set reg_id = "surf"

set reg = rotate_conf_2_${reg_id}.dat
# source and target directories and files...
set src_dir = ../mri
set targ_dir = ${src_dir}
set src_vol = conformed_rawavg.mgz
set fsl_prefix = "fsl_"
# use freesurfer default for atlas, but labeled output for the special registrations
switch (${reg_id})
case "atlas":
	set targ_vol = rawavg.mgz
	set orig_vol = orig.mgz
	breaksw
default:
	set targ_vol = rawavg_${reg_id}.mgz
	set orig_vol = orig_${reg_id}.mgz
endsw

# newer versions require different scripts
set fs_version = `mri_vol2vol --version`
echo $fs_version

if ($fs_version == stable3) then
    # reslice and resample into the target template...
    mri_vol2vol --in ${src_dir}/${src_vol} --out ${targ_dir}/${targ_vol} \
		--xfm ${src_dir}/${reg} --voxres-in-plane 1 1 --invxfm
else
    # reslice and resample into the target template...
    mri_vol2vol --mov ${src_dir}/${src_vol}  --targ ${src_dir}/${src_vol} --o ${targ_dir}/${targ_vol} \
		--reg ${src_dir}/${reg}
endif

# now check the reslicing...#
if (${check_result} == 1) then 
	#tkregister2 --mov ${targ_dir}/${targ_vol} \
	#		--reg ${src_dir}/dummy.reg --targ ${src_dir}/${src_vol}
	tkmedit -f ${targ_dir}/${targ_vol} -aux ${src_dir}/${src_vol}
endif
cp ${targ_dir}/${targ_vol} ${targ_dir}/${orig_vol}

# handle potential high bit resolution vomues
if (-e ${src_dir}/${fsl_prefix}${src_vol}) then
	if ($fs_version == stable3) then
	    # reslice and resample into the target template...
	    mri_vol2vol --in ${src_dir}/${fsl_prefix}${src_vol} --out ${targ_dir}/${fsl_prefix}${targ_vol} \
			    --xfm ${src_dir}/${reg} --voxres-in-plane 1 1 --invxfm
	else
	    # reslice and resample into the target template...
	    mri_vol2vol --mov ${src_dir}/${fsl_prefix}${src_vol} --targ ${src_dir}/${fsl_prefix}${src_vol} --o ${targ_dir}/${fsl_prefix}${targ_vol} \
		    --reg ${src_dir}/${reg}
	endif
	
	# now check the reslicing...#
	if (${check_result} == 1) then 
		#tkregister2 --mov ${targ_dir}/${fsl_prefix}${targ_vol} 
		#		--reg ${src_dir}/${fsl_prefix}dummy.reg --targ ${src_dir}/${fsl_prefix}${src_vol}
		tkmedit -f ${targ_dir}/${fsl_prefix}${targ_vol} -aux ${src_dir}/${fsl_prefix}${src_vol}
	endif
	cp ${targ_dir}/${fsl_prefix}${targ_vol} ${targ_dir}/${fsl_prefix}${orig_vol}
endif

# last line follows...
