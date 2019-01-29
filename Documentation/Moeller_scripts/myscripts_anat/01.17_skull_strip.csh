#! /bin/csh -f
# run automatic skull stripping
# tweak invocation parameters in this script and rerun until satisfied
# ATM the bet route is better...
# for the surface coil monkey data, the rawavg.mgz is better fur skull stripping than the nu.mgz

# set directories and filenames
set src_dir = ../mri
set targ_dir = ${src_dir}
set src_vol = rawavg.mgz#nu.mgz	# for the surface coil monkey data the rawavg is better than the nu
set t1_vol = T1.mgz
set use_bet = 1	# either use freesurfer or FSL's bet
# FSL related variables
set fsl_prefix = "fsl_"
set fsl_ext = nii.gz	
set in_stem =  rawavg
set brain_center_string = #"-c 128 128 128"	# only use if necessary
set brain_radius = 60

if (${use_bet} == 0) then
	# do the skull stripping
	# repeat with -surf_debug until the parameters are okay, the run without...
	#mri_watershed -surf_debug -atlas ${targ_dir}/${t1}  ${targ_dir}/brainmask.auto.mgz
	#mri_watershed -surf_debug -atlas -wat+temp ${targ_dir}/${t1}  ${targ_dir}/brainmask.auto.mgz
	#mri_watershed -surf_debug -h 25 -wat+temp ${targ_dir}/${t1}  ${targ_dir}/brainmask.auto.mgz
	#mri_watershed -h 10 -wat -n ${targ_dir}/${t1}  ${targ_dir}/brainmask.auto.mgz
	mri_watershed -r ${brain_radius} ${brain_center_string} -h 10 -wat+temp  ${src_dir}/${t1_vol}  ${targ_dir}/brainmask.fs.mgz
	
	# check results...
	tkmedit -f ${targ_dir}/brainmask.fs.mgz -aux ${targ_dir}/${t1_vol}
	# create the brainmask
	cp ${targ_dir}/brainmask.fs.mgz ${targ_dir}/brainmask.auto.mgz
else
	set out_stem = brainmask.fsl
	set fsl_out_vol = ${targ_dir}/${out_stem}
	## first, convert the rawavg into nifti (BET)
	mri_convert -i ${src_dir}/${in_stem}.mgz -o ${src_dir}/${in_stem}.${fsl_ext}
	mri_convert -i ${targ_dir}/${t1_vol} -o ${targ_dir}/T1.${fsl_ext} -nc

	# let bet do its thing... (activate next line to pick the center)
	#fslview ${src_dir}/${in_stem}
	# -f sets the threshold, r sets the brain radius to 60 mm
	bet ${src_dir}/${in_stem} $fsl_out_vol -v -f 0.4 -g 0.0 -r ${brain_radius} -m ${brain_center_string}
	# make the mask slightly larger...
	avwmaths ${fsl_out_vol}_mask -dil ${fsl_out_vol}_mask

	# visualize all results...
	fslview  ${targ_dir}/T1.${fsl_ext} ${fsl_out_vol} ${fsl_out_vol}_mask #${fsl_out_vol}_masked.${fsl_ext}

	## now convert back into mgz and check the final results...
	mri_convert -i ${fsl_out_vol}_mask.${fsl_ext} -o ${targ_dir}/${out_stem}_mask.mgz --conform
	# now use the mask to create the brainmask.fsl.mgz
	mri_mask ${targ_dir}/${t1_vol} ${targ_dir}/${out_stem}_mask.mgz ${targ_dir}/${out_stem}.mgz

	# check the result
	tkmedit -f ${targ_dir}/${out_stem}.mgz -aux ${targ_dir}/${t1_vol}
	
	cp ${targ_dir}/${out_stem}.mgz ${targ_dir}/brainmask.auto.mgz
endif

# last line follows...
