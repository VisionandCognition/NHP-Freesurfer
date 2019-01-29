#! /bin/csh -f
# use tkmedit to mark critical whitematter points
#setenv FIX_VERTEX_AREA
# set the source directory...
set src_dir = ../mri

# set the target directory and file_name
set targ_dir = ../mri
set src_vol = T1.mgz
set aux_vol = nu.mgz
#set subject = 060219Lupo
set cur_dir = `pwd`
cd ..
set subject = 0?????*
cd ${cur_dir}

#set reg = rotate_conf_2_atlas.dat
#set targ_vol = rawavg.mgz


#tkmedit -f ${src_dir}/${src_vol}
tkmedit ${subject} ${src_vol} -aux ${aux_vol}
#tkmedit -f ${src_dir}/raw_rawavg.mgz

# last line follows...
