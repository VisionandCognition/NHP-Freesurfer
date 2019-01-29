#! /bin/tcsh
# prepare the necessary steps for the registration of the functionals to the structural scans
# this should allow arbitrary structurals
#TODO unify all register scripts (func2func func2arb_struct func2struct func2session_struct)
#TODO: automagically load surface if one exists
#	switch to bbregister from flirt
# test for V4
# tkregister2 will fail to display volumes of type float as target (they show up nicely as moveables)
#	TODO figure out a viable workaround for that problem


set calling_dir = `pwd`
cd ../mystudy

#1. create the subjectname file, 
#	this has to point to a valid subdirectory of freesurfers $SUBJECTDIR
#	bail out if subjectname exists...
#EDIT THIS
set base_dir = /space/data/moeller/cooked/2010

# define stuff for the coregistration
set redo_initial_reg = 0			# start with a fresh registration matrix baesd on the headers...
set try_fsl_rigid_registration = 1		# use flirt for the initial matrix
set try_fs_bbregister_registration = 0		# use freesurfer bbregister for a registration guess, ATTENTION requires reconstructed surfaces on the structural session
set check_reg = 1				# if set to 1 display the registration in tkregister2, otherwise skip
set edit_string = "--noedit"
set flirt_opts_string = "-maxangle 15 -dof 12"	# sometimes flirt needs constraints...
set reg_id = #.undistorted#".chamber"#".electrode"		# allow registation labels
set func_template_type = averaged		# averaged or mocovol
set tkregister2_opts = "--fov 128"		# additional options for tkregister2

# TREAT AS MAIN REGISTRATION?
set reg_2_main_struct = 0	# if one treat the structural as the main structural (and create bold/register.dat)
set reg_2_sess_struct = 0	# register to same session structural?


## Julien
set structural_session = 091204Julien
set targ_dir = ${base_dir}/2009/${structural_session}/mri
set targ_vol = T1.mgz
#set targ_dir = $targ_dir
set structural_session = 100117Julien
set targ_dir = ${base_dir}/${structural_session}/mri
set targ_vol = conformed_rawavg.mgz

set structural_session = 100219Julien
set targ_dir = ${base_dir}/${structural_session}/mri
set targ_vol = T1.mgz #conformed_rawavg.mgz


if (${reg_2_sess_struct} == 1) then
    set structural_session = `cat ./sf`
    set targ_dir = ${calling_dir}/../mri
    set targ_vol = T1_chair.mgz #conformed_rawavg.mgz
    set reg_id = .in_session
endif


# the volume to be moved
set mov_sess = `cat ./sf`
set mov_dir = ../t1epi
set mov_stem = fmcu
set mov_stem = fmc
set mov_ext = nii
set mov_vol = ${mov_stem}.${mov_ext}
echo functional session: $mov_sess



#2. create the t1epi directory for the registration
#	and copy the first functional average into it
#   why not simply symlink ../bold/101/001 to t1epi ???

set out_dir = ../t1epi
if  !(-e ${out_dir}) then
    mkdir ${out_dir}
endif
if (${func_template_type} == averaged) then
    set in_dir = ../bold/901/001
    set mov_file = ${mov_vol}
else
    set in_dir = ../bold/MOCOVOL
    if (${mov_stem} == fmc) then
	set mov_file = mocovol.nii
    else
	set mov_file = mocovolu.nii
    endif
endif
cp ${in_dir}/${mov_file} ${out_dir}/${mov_vol}

set out_vol = tmp_fsl_rotated.${mov_sess}_2_${structural_session}${reg_id}


#3. set the in_register.dat file (do not overwrite existing files)
set out_reg = ${mov_sess}_2_${structural_session}${reg_id}.register.dat
set out_reg_dir = ../t1epi


# create the initial registration...
if (!(-e ${out_reg_dir}/${out_reg}) || (${redo_initial_reg} == 1)) then
    echo "Initial step, header creation..."
    # the monkey structurals' scanned at 0.5mm have been imported into freesurfer with the resolution forced to be 1.0mm
    # so the functionals have to be scaled by the same factor of 2 to allow the registration... (--noedit does not apply --movescale 2, so skip this)
    tkregister2 --sd ${targ_dir} --s ${structural_session} --targ ${targ_dir}/${targ_vol} --mov ${mov_dir}/${mov_vol} --reg ${out_reg_dir}/${out_reg} --regheader --movscale 2 ${tkregister2_opts}#--noedit
endif


# try to coregister the volumes using fsl's flirt...
if (${try_fsl_rigid_registration} == 1) then
    if (!(-e ${out_reg_dir}/${out_reg}.done_by_fsl) || (${redo_initial_reg} == 1)) then
	# now convert the initial registration matrix into fsl format, to seed the registration...
	set fs2fslreg = initxfm.fslmat
	tkregister2 --targ ${targ_dir}/${targ_vol} --mov ${mov_dir}/${mov_vol} --s ${structural_session} --reg ${out_reg_dir}/${out_reg} ${edit_string} --fslregout ${out_reg_dir}/${fs2fslreg} ${tkregister2_opts}
	echo "using FLIRT for registration... might take a while"
	fsl_rigid_register -r ${targ_dir}/${targ_vol} -i ${mov_dir}/${mov_vol} -o ${out_dir}/${out_vol} \
			    -regmat ${out_reg_dir}/${out_reg} -initxfm ${out_reg_dir}/${fs2fslreg} ${flirt_opts_string}
	#tkmedit -f ${out_dir}/${out_vol} -aux ${targ_dir}/${targ_vol}
	touch ${out_reg_dir}/${out_reg}.done_by_fsl
    endif
endif


# try to coregister the volumes using freesurfer's bbregister...
if (${try_fs_bbregister_registration} == 1) then
    if (!(-e ${out_reg_dir}/${out_reg}.done_by_bbregister) || (${redo_initial_reg} == 1)) then
	cp ${out_reg_dir}/${out_reg} ${out_reg_dir}/${out_reg}.4.bbregister
	echo "using BBREGISTER for registration... might take a while"
	# bbregister requires proper freesurfer subjects, so fake one
	if !(-e ${SUBJECTS_DIR}/${structural_session}) then
	    ln -s ${base_dir}/${structural_session} ${SUBJECTS_DIR}/${structural_session}
	    set clean_up_session_link = 1
	endif
	bbregister --s ${structural_session} --mov ${mov_dir}/${mov_vol} --bold \
		    --init-reg ${out_reg_dir}/${out_reg}.4.bbregister --reg ${out_reg_dir}/${out_reg}
	touch ${out_reg_dir}/${out_reg}.done_by_bbregister
	if (${clean_up_session_link} == 1) then
	    rm ${SUBJECTS_DIR}/${structural_session}
	    set clean_up_session_link = 0
	endif    
    endif
endif


if ((${%check_reg} > 0) & (${check_reg} == 1)) then
    # actually register the session averages..
    if ((-e ${targ_dir}/../surf/lh.white) && (-e ${targ_dir}/../surf/lh.white)) then
        tkregister2 --s ${structural_session} --targ ${targ_dir}/${targ_vol} --mov ${mov_dir}/${mov_vol} --reg ${out_reg_dir}/${out_reg} --surf white ${tkregister2_opts}
    else
	tkregister2 --sd ${targ_dir} --s ${structural_session} --targ ${targ_dir}/${targ_vol} --mov ${mov_dir}/${mov_vol} --reg ${out_reg_dir}/${out_reg} #--surf white ${tkregister2_opts}
    endif
endif


#6. copy register.dat into fsd (bold)
set reg_targ_dir = ../bold/regs
set targ_reg = $out_reg
if !(-e ${reg_targ_dir}) then
    mkdir -p ${reg_targ_dir}
endif
cp ${out_reg_dir}/${out_reg} ${reg_targ_dir}/${targ_reg}

if (${reg_2_main_struct} == 1) then
    echo "treating as main registration (creating bold/register.dat)..."
    cp ${out_reg_dir}/${out_reg} ${out_reg_dir}/${structural_session}.register.dat
    cp ${out_reg_dir}/${out_reg} ${out_reg_dir}/register.dat
    cp ${out_reg_dir}/${out_reg} ${reg_targ_dir}/../register.dat	# should live in bold/
    
endif

exit 0
# last line follows...
