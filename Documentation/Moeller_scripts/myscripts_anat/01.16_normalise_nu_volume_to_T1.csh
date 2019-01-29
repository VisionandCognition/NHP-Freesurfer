#! /bin/csh -f
# normalize the intensity corrected volume gently to create the T1 volume

set check_result = 1	# use tkmedit/tkregister2 to see the results
# set directories and volumes
set src_dir = ../mri
set targ_dir = ${src_dir}

# select the registration file to use
#set reg_id = "atlas"
#set reg_id = "electrode"
#set reg_id = "chamber"
#set reg_id = "surf"

set fsl_prefix = "fsl_"
# use freesurfer default for atlas, but labeled output for the special registrations
switch (${reg_id})
case "atlas":
	set src_vol = nu.mgz
	set targ_vol = T1.mgz
	breaksw
default:
	set src_vol = nu_${reg_id}.mgz
	set targ_vol = T1_${reg_id}.mgz

endsw
# mri_normalize requires 8bit input?
set conf_tmp_vol = ${fsl_prefix}_conf_${src_vol}


# make sure the nu.mgz is of type zero
mri_convert -i ${src_dir}/${src_vol} -o ${src_dir}/${src_vol} --conform
# do the first normalisation step (-conform does not handle 256x256x256 volumes of type float well)
mri_normalize -n 1 -no1d -gentle ${src_dir}/${src_vol} ${targ_dir}/${targ_vol} -v

# work on the high bit resolution
if (-e ${src_dir}/${fsl_prefix}${src_vol}) then
	mri_convert -i ${src_dir}/${fsl_prefix}${src_vol} -o ${src_dir}/${conf_tmp_vol} --conform
	mri_normalize -n 1 -no1d -gentle ${src_dir}/${conf_tmp_vol} ${targ_dir}/${fsl_prefix}${targ_vol} -v
	# control the results
	if (${check_result} == 1) then
		tkmedit -f ${targ_dir}/${targ_vol} -aux ${targ_dir}/${fsl_prefix}${targ_vol}
	endif
else
	# control the results
	if (${check_result} == 1) then
		tkmedit -f ${targ_dir}/${targ_vol}
	endif
endif


# last line follows...
