#! /bin/csh -f
# use tkmedit to mark critical whitematter points

# set the source directory...
set src_dir = ../mri

# set the target directory and file_name
set targ_dir = ../mri
set src_vol = wm.mgz
#set brain = brain.mgz
set targ_vol = filled.mgz
set controlpoints = ../tmp/control.dat
set cur_dir  = `pwd`

# ATTENTION please specify the cutting planes for the pons and the corpus callosum
# define the raw voxel coordinates for CC and PONS
set CC_string = "128 110 132"
set PONS_string = "128 136 125"#"127 129 112"

# do an initial filling to check the cutting planes
set check_filling = 0

cd ..
set tmp_subj = 0?????*
cd ${cur_dir}


if (${check_filling} == 1) then
    echo "Testing the CC and Pons coordinates, if the filled volume is okay rerun this script with set check_filling = 0"
    #mri_fill -CV 127 128 128 -PV 127 154 128 ${src_dir}/${src_vol} ${targ_dir}/${targ_vol}
    mri_fill -a ../scripts/ponscc.cut.log -PV ${PONS_string} -CV ${CC_string} ${src_dir}/wm.mgz ${src_dir}/filled.mgz
    # check the results, left and right white matter should be colored differently and the cerebellum should be excluded
    tkmedit -f ${src_dir}/filled.mgz -aux ${src_dir}/T1.mgz
    exit 0
endif


# fill needs the aseg.mgz, which we do not have, evade... or use newer dev release...
#recon-all -autorecon2-wm -cc-xyz 127 128 128 -pons-xyz 127 128 154 -subjid ${tmp_subj} -mgz -disable-autoseg -nofill
# 20051005
#recon-all -autorecon2-wm -subjid ${tmp_subj} -mgz -disable-autoseg -nofill -disable-autoseg
# 20060224
recon-all 	-autorecon2-wm \
		-subjid ${tmp_subj} \
		-cc-crs ${CC_string} \
		-pons-crs ${PONS_string} \
		-noaseg \
		-xopts-use

#tkmedit -f ${targ_dir}/wm.mgz -aux ${targ_dir}/${src_vol}

#csurf

# does a register file already exist?
#if !(-e ${targ_dir}/${reg}) then
#    cp ./${reg} ${targ_dir}/${reg}
#endif
