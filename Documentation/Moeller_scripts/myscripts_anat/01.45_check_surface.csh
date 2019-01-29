#! /bin/csh -f
# use tkmedit to mark critical whitematter points


# set the source directory...
set src_dir = ../mri

# for speed editing the wm.mgz it is helpfull to show both hemisphere's surfaces
set show_2_surf_in_tkmedit = 0

# set the target directory and file_name
set targ_dir = ../mri
set src_vol = wm.mgz
#set brain = brain.mgz
set targ_vol = filled.mgz
set controlpoints = ../tmp/control.dat
set cur_dir  = `pwd`

cd ..
set tmp_subj = 0?????*
cd ${cur_dir}

#Usage:	tksurfer [-]name hemi surf [-tcl script]
#	tksurfer -help, -h [after startup: help]       
#	name:  subjname (dash prefix => don't read MRI images)
#	hemi:  lh,rh
#	surf:  orig,smoothwm,plump,1000,1000a

		
set terminal = "xterm -e"
# check/correct the white matter surfaces
set aux_vol = T1.mgz # brain.mgz
set surface = inflated # white, pial, inflated
set curv = sulc #sulc or curv
set hemi_list = (lh rh)

foreach hemi ($hemi_list)
    #tkmedit -f ${targ_dir}/wm.mgz -aux ${targ_dir}/T1.mgz
    # here we load the white matter into tkmedit and the surface borders...
    ${terminal} tksurfer ${tmp_subj} ${hemi} ${surface} -overlay ${hemi}.${curv} &
    if ($show_2_surf_in_tkmedit == 0) then
	tkmedit ${tmp_subj} wm.mgz ${hemi}.white -aux $aux_vol
    else
	# always show the surface on both hemispheres
	tkmedit ${tmp_subj} wm.mgz lh.white -aux $aux_vol -aux-surface rh.white
    endif
end


# last line follows...
