#! /bin/csh -f
# average several runs of anatomicals...
# fill in one line per run to put into average.
# TODO: read in a list of runs and automagically create the list of
# 	"-i" arguuments for mri_motion_correct2...
# 20051207: make structure conform to freesurfer expectations, that is put rawavg.mgz under mri
# 20061209: changed from mri_motion_correct2 to mri_motion_correct.fsl (better result for tricky input volumes)

# name of the input mgh files...
set anat_name = mprage.mgz
#set anat_name = mprage0.5.mgz


# set the source directory...
set source_base_dir = ../mri/orig

# set the target directory and file_name
set targ_dir = ../mri
set targ_file_name = raw_rawavg.mgz

#for averaging (should be done in a seperate script?, yes, this is it, the separate script;))
#mri_motion_correct.fsl -o $targ_dir/${targ_file_name} \
#		    -i ${source_base_dir}/002/${anat_name} \
#		    -i ${source_base_dir}/003/${anat_name} \
#		    -i ${source_base_dir}/004/${anat_name} \
#		    -i ${source_base_dir}/005/${anat_name} \
#		    -i ${source_base_dir}/006/${anat_name} \
#		    -i ${source_base_dir}/007/${anat_name} \
#		    -i ${source_base_dir}/008/${anat_name} \
#		    -i ${source_base_dir}/009/${anat_name} \
#		    -i ${source_base_dir}/010/${anat_name} \
#		    -i ${source_base_dir}/011/${anat_name}

		    
## if only one run available...
set run = 002
cp ${source_base_dir}/${run}/${anat_name} $targ_dir/${targ_file_name}


# create the faked conformed data file, if copy is not enough, use mri_convert with -iis -ijs -iks flags
set conformed_vol = conformed_rawavg.mgz                # this will be put through the freesurfer stream
set fsl_conformed_vol = fsl_conformed_rawavg.mgz        # this will be used for the FSL steps
mri_convert -i ${targ_dir}/${targ_file_name} -o ${targ_dir}/${fsl_conformed_vol} -iis 1 -ijs 1 -iks 1
mri_convert -i ${targ_dir}/${targ_file_name} -o ${targ_dir}/${conformed_vol} -iis 1 -ijs 1 -iks 1

# now make sure the volume is 256 by 256 by 256 voxel...
#mri_convert -i ${targ_dir}/${conformed_vol} -o ${targ_dir}/${conformed_vol} --conform


# check the results...
tkmedit -f ${targ_dir}/${conformed_vol}

# last line follows...
