#! /bin/csh -f
# rotate the conformed averaged scan into the canonical postion:
#	the volume is to be turned until tkmedits ideas about coronal sagittal and transversal are sattisfied
#	on coronal sections the right hemisphere HAS to be on the left side
#	# this most likely means: but this should be the output of one the previous script
#	#	in the midsagital view, frontal is to the right, and rostral is to the left (tkmedit)
#	#	in the horizontal view, the eyes are at up, the occipital pole is at bottom
#	#	in the coronal view higher slice numbers are anterior of lower slice numbers
# 20060625:
#	the midsagital slice should be at s(128)
#	the anterior and posterior commissure have to be on the same level (see ac_pc.jpg) (h128 is a great pos for the commisures)
#	the coronal AP0 slice has to be at position c(128)
# 	the rotated volume is then resliced into the orig volume (in the following script)
#20070118:
#	allow for target volumes from other sessions...
#20070803:
#	label the registration matrix to allow arbitrary labels, this allows multiple registrations per session


# set the source directory...
set src_dir = ../mri
set src_vol = conformed_rawavg.mgz
set out_dir = $src_dir
set base_dir = /space/data/moeller/cooked
set try_fsl_rigid_registration = 1	# if set try the automatic version first
set redo_initial_reg = 0		# redo the initial registration (this forces a clean start)
set edit_string = "--noedit"
set flirt_opts_string = #"-maxangle 15 -dof 6"	# sometims flirt needs constraints...

# define the identity of the registration
set reg_id = "atlas" 		# "atlas" (plain old atlas, the default for starting a surface reconstruction from) identity template,
#set reg_id = "electrode"	# "electrode" (optimally aligned to the electrode) identity template, 
#set reg_id = "chamber"		# "chamber" (aligned to chamber and grid main axis), 
#set reg_id = "surf"		# "surf" (aligned to the surface recon vol) 

set out_vol = fsl-rotated_${reg_id}_${src_vol}

# uncomment only the monkey in question
switch (${reg_id})
case "chamber":
    # to coregister Monchichi microstim data for early 2007
    set targ_dir = ${SUBJECTS_DIR}/070123Monchichi/mri
    set targ_vol = rawavg_electrode.mgz
    # to coregister Bert microstim data for early 2007
    set targ_dir = ${SUBJECTS_DIR}/061213Bert-moe/mri
    set targ_vol = rawavg_chamber.mgz
    # to coregister Napoleon microstim data
#    set targ_dir = ${base_dir}/061119Napoleon/mri
#    set targ_vol = rawavg_chamber.mgz#T1_chamber.mgz
    breaksw
#case "electrode":
    # to coregister Monchichi microstim data for early 2007
#    set targ_dir = ${SUBJECTS_DIR}/070123Monchichi/mri
#    set targ_vol = nu_electrode.mgz
    # to coregister Napoleon microstim data
#    set targ_dir = ${base_dir}/061119Napoleon/mri
#    set targ_vol = rawavg_chamber.mgz#T1_chamber.mgz
#    breaksw
case "surf":    
#    set targ_dir = ${SUBJECTS_DIR}/060421Napoleon_a/mri # 060421Napoleon_a is not orinted correctly, switch to 060421Napoleon_c once this is ready...
#    set targ_vol = rawavg_surf.mgz #  the rawavg_surf is the conformed rawavg.mgz after the rotation
    set targ_dir = ${SUBJECTS_DIR}/060519Bert/mri
    set targ_vol = rawavg.mgz #  the rawavg_surf is the conformed rawavg.mgz after the rotation
#    set targ_dir = ${SUBJECTS_DIR}/060702Monchichi/mri
#    set targ_vol = rawavg.mgz #  the rawavg is the conformed_rawavg.mgz after the rotation
    set edit_string = #"--noedit"
    set flirt_opts_string = "-maxangle 15 -dof 6"	# sometims flirt needs constraints...
    breaksw
default:
    # for electrode and atlas we start with the identity registration, so flirt would be a waste of time
    set try_fsl_rigid_registration = 0	# if set try the automatic version first
    set targ_dir = ${src_dir}
    set targ_vol = ${src_vol}
endsw

# set the variables for the registration file
set out_reg = rotate_conf_2_${reg_id}.dat
set reg_dir = ${src_dir}

# get the current session identifier...
set start_dir = `pwd`
cd ../
set session = [0-9][0-9][0-9][0-9][0-9][0-9][A-Z]*
cd $start_dir


# does a register file already exist?
if (!(-e ${reg_dir}/${out_reg}) || (${redo_initial_reg} == 1)) then
    echo "Creating initial register file..."
    tkregister2 --targ ${targ_dir}/${targ_vol} --mov ${src_dir}/${src_vol} --s $session --regheader ${edit_string} --reg ${reg_dir}/${out_reg}        
endif

# try to coregister the volumes using fsl's flirt...
if (${try_fsl_rigid_registration} == 1) then
    if (!(-e ${reg_dir}/${out_reg}.done_by_fsl) || (${redo_initial_reg} == 1)) then
	# now convert the initial registration matrix into fsl format, to seed the registration...
	set fs2fslreg = initxfm.fslmat
	tkregister2 --targ ${targ_dir}/${targ_vol} --mov ${src_dir}/${src_vol} --s $session --reg ${reg_dir}/${out_reg} ${edit_string} --fslregout ${reg_dir}/${fs2fslreg}
	echo "using FLIRT for registration... might take a while"
	fsl_rigid_register -r ${targ_dir}/${targ_vol} -i ${src_dir}/${src_vol} -o ${out_dir}/${out_vol} \
			    -regmat ${reg_dir}/${out_reg} -initxfm ${reg_dir}/${fs2fslreg} ${flirt_opts_string}
	tkmedit -f ${out_dir}/${out_vol} -aux ${targ_dir}/${targ_vol}
	touch ${reg_dir}/${out_reg}.done_by_fsl
    endif
endif

# now do/check the registration      
tkregister2 --targ ${targ_dir}/${targ_vol} --mov ${src_dir}/${src_vol} --reg ${reg_dir}/${out_reg}

# last line follows...
