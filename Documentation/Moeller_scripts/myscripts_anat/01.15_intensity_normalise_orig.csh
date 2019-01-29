#! /bin/csh -f
# try to get rid of the RF bias fied
# either use MNI N3 as called by freesurfer, or use FSL's fast (for high bit reolution volumes)
# special case in-session structurals, if necessary
# add ${reg_id} to the output file names, ecept for "atlas" as this is the way
# towards a proper surface reconstruction, where we want to use freesurfer default names
# TODO test whether high-bit resolution inputs result in nicer results even for N3


set check_result = 1	# use tkmedit/tkregister2 to see the results
# select the registration file to use
#set reg_id = "atlas"
#set reg_id = "electrode"
#set reg_id = "chamber"
#set reg_id = "surf"

set reg = rotate_conf_2_${reg_id}.dat
# source and target directories and files...
set src_dir = ../mri
set targ_dir = ${src_dir}
set use_mni_n3 = 1	# use the mni tools
# FSL related stuff
set use_fsl_fast = 0	# use FSLs RF bias removal, DOES NOT WORK YET
set fsl_prefix = "fsl_"
set fsl_ext = nii.gz
set tmp_dir = ${src_dir}	# fsl

# use freesurfer default for atlas, but labeled output for the special registrations
switch (${reg_id})
case "atlas":
	set src_vol = rawavg.mgz
	set targ_vol = nu.mgz
	set orig_vol = orig.mgz
	set targ_stem = fsl_nu
	breaksw
default:
	set src_vol = rawavg_${reg_id}.mgz
	set targ_vol = nu_${reg_id}.mgz
	set orig_vol = orig_${reg_id}.mgz
	set targ_stem = fsl_nu_${reg_id}
endsw


# use N3
if (${use_mni_n3} == 1) then
	mri_nu_correct.mni --i ${src_dir}/${orig_vol} --o ${targ_dir}/${targ_vol} --n 1 --proto-iters 150 --stop .0001
	if (${check_result} == 1 ) then
		tkmedit -f ${targ_dir}/${targ_vol} -aux ${targ_dir}/${orig_vol}
	endif
endif

# use FSL fast
if (${use_fsl_fast} == 1) then
	set tmp_stem = tmp_fsl_inorm
	set tmp_bet_stem = tmp_fsl_bet_inorm
	set debug = 1
	# should we run on a roughly extracted brain?
	set use_bet = 1		# this allows the use of a brainmask...
	set do_bet = 0		# this controls the creation of the mask...

	# convert the rawavg.mgz into nifti
	mri_convert -i ${src_dir}/${fsl_prefix}${src_vol} -o ${tmp_dir}/${tmp_stem}.${fsl_ext}

	# extract a rough hull of the brain...
	if (${do_bet} == 1) then
		# pick the brain center...
    		fslview ${tmp_dir}/${tmp_stem}.${fsl_ext}
    		set brain_center = # -c 128 128 128	# only do if necessary
    		bet ${tmp_dir}/${tmp_stem} ${tmp_dir}/${tmp_bet_stem} -v -f 0.4 -g 0.0 -r 60 -m ${brain_center}
    		# enlarge the mask...
    		avwmaths ${tmp_dir}/${tmp_bet_stem}_mask -dil ${tmp_dir}/${tmp_bet_stem}_mask
    		# check the results
    		fslview ${tmp_dir}/${tmp_bet_stem}.${fsl_ext} ${tmp_dir}/${tmp_bet_stem}_brain.${fsl_ext} ${tmp_dir}/${tmp_bet_stem}_mask.${fsl_ext}
    		# only go to FAST once BET is finished (set do_bet back to zero)
    		exit 0
	endif

	# run FSL's FAST on the nifti...
	if (${use_bet} == 1) then
		# -i 8 -l 300 looks good
		#fast -v2 -n -or -i 8 -l 100 -od ${tmp_dir}/${tmp_bet_stem}_i08l100 ${tmp_dir}/${tmp_bet_stem}
		#fast -v2 -n -or -i 20 -l 100 -od ${tmp_dir}/${tmp_bet_stem}_i20l100 ${tmp_dir}/${tmp_bet_stem}
		#fast -v2 -n -or -i 8 -l 200 -od ${tmp_dir}/${tmp_bet_stem}_08l200 ${tmp_dir}/${tmp_bet_stem}	
		#fast -v2 -n -or -i 20 -l 200 -od ${tmp_dir}/${tmp_bet_stem}_20l200 ${tmp_dir}/${tmp_bet_stem}
		#fast -v2 -n -or -i 8 -l 50 -od ${tmp_dir}/${tmp_bet_stem}_08l050 ${tmp_dir}/${tmp_bet_stem}
		#fast -v2 -n -or -i 8 -l 300 -od ${tmp_dir}/${tmp_bet_stem}_i08l300 ${tmp_dir}/${tmp_bet_stem}
		#fast -v2 -n -or -i 20 -l 300 -od ${tmp_dir}/${tmp_bet_stem}_i20l300 ${tmp_dir}/${tmp_bet_stem}
		#fast -v2 -n -or -i 8 -l 400 -od ${tmp_dir}/${tmp_bet_stem}_i08l400 ${tmp_dir}/${tmp_bet_stem}
		#fast -v2 -n -or -i 20 -l 400 -od ${tmp_dir}/${tmp_bet_stem}_i20l400 ${tmp_dir}/${tmp_bet_stem}
		#fast -v2 -n -or -i 8 -l 300 -2 -od ${tmp_dir}/${tmp_bet_stem}_i08l300_2D ${tmp_dir}/${tmp_bet_stem}
		#fast -v2 -n -or -i 20 -l 300 -2 -od ${tmp_dir}/${tmp_bet_stem}_i20l300_2D ${tmp_dir}/${tmp_bet_stem}
		#fast -v2 -n -or -i 8 -l 300 -od ${tmp_dir}/${tmp_bet_stem} ${tmp_dir}/${tmp_bet_stem}
    		fast -v2 -n -or -i 20 -l 500 ${tmp_dir}/${tmp_bet_stem}
		#fslview ${tmp_dir}/${tmp_bet_stem}_i08l100 ${tmp_dir}/${tmp_bet_stem}_08l200 ${tmp_dir}/${tmp_bet_stem}_i08l300 ${tmp_dir}/${tmp_bet_stem}_i08l400 ${tmp_dir}/${tmp_bet_stem}_i28l300 ${tmp_dir}/${tmp_bet_stem}_i20l400 ${tmp_dir}/${tmp_bet_stem}_i08l300_2D ${tmp_dir}/${tmp_bet_stem}_i20l300_2D
		#exit 0

		if (${debug} == 1) then
			fslview ${tmp_dir}/${tmp_bet_stem}_restore.${fsl_ext} ${tmp_dir}/${tmp_bet_stem}.${fsl_ext}
    		endif
   		# convert the output back into freesurfer...
    		mri_convert -i ${tmp_dir}/${tmp_bet_stem}_restore.${fsl_ext} -o ${targ_dir}/${targ_stem}.mgz
    		# clean up, unnecessary fsl files...
    		rm ${tmp_dir}/${tmp_bet_stem}.${fsl_ext}
    		rm ${tmp_dir}/${tmp_bet_stem}_restore.${fsl_ext}
	else
    		fast -n -or -i 8 -l 100 ${tmp_dir}/${tmp_stem}
    		if (${debug} == 1) then
			fslview ${tmp_dir}/${tmp_stem}_restore.${fsl_ext} ${tmp_dir}/${tmp_stem}.${fsl_ext}
    		endif
    		# convert the output back into freesurfer...
    		mri_convert -i ${tmp_dir}/${tmp_stem}_restore.${fsl_ext} -o ${targ_dir}/${targ_stem}.mgz
    		# clean up, unnecessary fsl files...
    		rm ${tmp_dir}/${tmp_stem}.${fsl_ext}
    		rm ${tmp_dir}/${tmp_stem}_restore.${fsl_ext}
	endif

	# check the results?
	if (${check_result} == 1 ) then
		# view the intensity normalised volume
		tkmedit -f ${targ_dir}/${targ_stem}.mgz -aux ${targ_dir}/${orig_vol}
	endif
endif

echo "Done..."
exit 0

# last line follows...
