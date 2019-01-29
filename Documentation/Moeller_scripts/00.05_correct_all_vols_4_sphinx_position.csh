#! /bin/tcsh 
# this writes the image header for all bshort/bfloat/mgh/mgz files so that that orientation follows freesurfers ideas...
# at the moment we do not do this automatically, but once this is tested better, we should...
# as any registration has to be manually adjusted/tweaked anyway

# 20100114sm: automatically go through the session folder and detect all bhdr, fieldmap.nii, and mprage.mgz
# this should only be run an odd number of times, as even numbers are wrong
# and there is no way to recognize this from the corrected volumes, so run this from unpack_CIT.csh

set calling_dir = `pwd`
# this script can be called from the session drectory or 1-level sub directories
if !(-e ./mystudy) then
    cd ..
    if !(-e ./mystudy) then
	echo "Do not know where to find the actual data"
	exit 0
    else
	set calling_dir = `pwd`
    endif
endif

set force_sphinx_correction = 0		# only monkeys can be in the sphinx position inside the scanner, if autodetection of monkey session fails, this allows override
set manual_sphinx_correction = 0	# use manual sphinx correction, otherwise try to use automatic correction


# check whether we run for the first time...
set corrected_4_sphinx_marker = "corrected_4_sphinx_position"
if ( -e ${calling_dir}/${corrected_4_sphinx_marker}) then
    echo "This session has already been corrected for sphinx position, running it a second time will uncorrect it, so bailing out..."
    echo "in case the correction should be truly re done, please delete ${calling_dir}/${corrected_4_sphinx_marker}"
    exit 0
else
    # this should only be set, after we actually corrected something...
    #touch ${calling_dir}/${corrected_4_sphinx_marker}
endif


# check for human data (human sessions are names NNNNNNFML (F: first initial, M: middle name, L: last name, and potentially one session number))
# all monkey names are longer than 3 letters
if (${force_sphinx_correction} == 0) then
    set session_id = `cat ./mystudy/sf`
    echo Session: ${session_id}
    #echo ${%session_id}
    if (${%session_id} > 9) then
	echo "No human style session ID file found, good. Assuming monkey data, trying to correct for sphinx position now..."
    else
	echo "Found human looking ID file ${session_id}, assuming that sphinx correction is not required..."
	echo "(correction for sphinx position can be forced by setting force_sphinx_correction to 1 in $0)."
        exit 0
    endif
else
    echo "Forcing correction of sphinx position..."
    touch ${calling_dir}/forced_${corrected_4_sphinx_marker}
endif

# we are about to actually correct the files header...
touch ${calling_dir}/${corrected_4_sphinx_marker}

# get all MRI volume types, maybe restrict to selected stems like f, mprage, fieldmap
set uncorrected_vol_list = `find -L . -wholename './myscripts' -prune \
			    -o -iwholename './myscripts_anat' -prune \
			    -o -iwholename './myscripts_func_CIT' -prune \
			    -o -iwholename './ica' -prune \
			    -o -iname "*.bhdr" -print \
			    -o -iname "*.nii" -print \
			    -o -iname "*.nii.gz" -print \
			    -o -iname "*.mgz" -print `
#echo $uncorrected_vol_list

# loop over all volumes
foreach uncorrected_vol (${uncorrected_vol_list})
    echo Processing: ${uncorrected_vol}
    set current_fullfilename = `basename ${uncorrected_vol}`
    echo Filename: $current_fullfilename
    set current_stem = `echo "${current_fullfilename}" | awk '{split ($0, a, "."); print a[1]}'`
    echo Stem: $current_stem
    set current_ext = `echo "${current_fullfilename}" | awk '{split ($0, a, "."); print a[2]}'`
    echo Extension: $current_ext
    set current_dir = `dirname ${uncorrected_vol}`
    echo Directory: $current_dir

    # bhdr (bshort and bfloats are different...)
    # FIXME only search for infodump.dat files if they actually do exist...
    ls ${current_dir}/*infodump.dat > & tmp_output.file
    set tmp_ls_output = `cat tmp_output.file | awk '{split($0, a, ":"); print a[1]}'`
    if (${tmp_ls_output[1]} != "ls") then
	set infodump_file = ${current_dir}/*infodump.dat
    else
	set infodump_file = ${current_dir}/infodump.dat.could.not.be.found
    endif
    rm tmp_output.file
    echo Infodump: $infodump_file
    
    if (${current_ext} == bhdr) then
	#set infodump_file = ${current_dir}/${current_stem}-infodump.dat
	set out_name = ${current_stem}
	set proto_fs_ot = `mri_info --type ${uncorrected_vol}`
	set fs_ot = b${proto_fs_ot}
    else
	#set infodump_file = ${uncorrected_vol}-infodump.dat
	set out_name = ${current_fullfilename}
	set fs_ot = ${current_ext}
	echo Type: $fs_ot
    endif
    
    # check the MRI.ext-infodump.dat for "PatientPosition HFS", only run mri_convert --sphinx on those runs
    # attention, .bhdr are special (f-infodump.dat, compared to f.nii-infodump.dat)
    if (-e ${infodump_file}) then
	set proto_patientposition = `grep -e PatientPosition ${infodump_file}`
        set patpos = `echo "$proto_patientposition" | awk '{split($0, a, " "); print a[2]}'`
        echo Patient Position: ${patpos}
    endif

    # sanity check...
    if (!(${patpos} == HFS) && (${manual_sphinx_correction} == 0)) then
	echo "Only PatientPosition HFS (Head First Supine) data (not ${patpos}) can be automatically corrected."
	echo "Set manual_sphinx_correction = 1 to override the automatic correction, make sure that ${patpos} is handled by the script"
	echo "also make sure to delete ${corrected_4_sphinx_marker}"
	echo "this bails out for the first not defined volume, if you mixed patient positions in one session yuo will have to manually fix all runs individually."
	exit 0
    endif

    if (${manual_sphinx_correction} == 0) then
	echo "Automatic..."
	echo mri_convert -i ${uncorrected_vol} -o ${current_dir}/${out_name} -ot ${fs_ot} --sphinx
	mri_convert -i ${uncorrected_vol} -o ${current_dir}/${out_name} -ot ${fs_ot} --sphinx
    else
	# PLEASE ADD new tested combinations...
	echo "Manual..."
	set current_orientation = `mri_info --orientation ${uncorrected_vol}`
	# mri_info on .nii files is overly verbose, make sure to only return the orientation string
	echo ${#current_orientation}
	
	if (${#current_orientation} > 1) then
	    echo ${current_orientation[${#current_orientation}]}
	    set tmp_current_orientation = ${current_orientation[${#current_orientation}]}
	    set current_orientation = ${tmp_current_orientation}
	endif
	echo "original orientation (sphinxed): ${current_orientation}"
	
	# keep this empty, so we only try to convert if we know what orientation to use.
	set corrected_orientation =	
	
	if (${patpos} == HFS) then
	    if (${current_orientation} == LPS) then
		set corrected_orientation = RPI
	    endif
	endif
	
	if (${patpos} == HFP) then
	    if (${current_orientation} == LIP) then
		set corrected_orientation = LPS
	    endif
	endif
	
	if (${patpos} == FFS) then
	    if (${current_orientation} == LIP) then
		set corrected_orientation = LAI
	    endif
	endif
	
	if (${%corrected_orientation} > 0) then
	    echo "corrected orientation (desphinxed): ${current_orientation}"
	    mri_convert -i ${uncorrected_vol} -o ${current_dir}/${out_name} -ot ${fs_ot} --in_orientation ${corrected_orientation}	
	else
	    echo "Could not correct the sphinx position of (${uncorrected_vol})."
	    echo "No corrected_orientation defined for patient position ${patpos} and orientation ${current_orientation}, please fix this script."
	endif
    endif    
end

echo ""
echo "Done... (${0})"
exit 0
# last line follows...
