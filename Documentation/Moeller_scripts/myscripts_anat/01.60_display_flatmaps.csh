#! /bin/csh -f
# display the flattened patches

set cur_dir  = `pwd`    
set cut_surface = inflated
set hemi_list = (lh rh)
set patch = temp
set terminal = xterm
# get the subjid...
cd ..
set tmp_subj = [0-9]?????[A-Z]*
cd ${cur_dir}

# display the help text
#cat ./$0

#Usage:	tksurfer [-]name hemi surf [-tcl script]
#	tksurfer -help, -h [after startup: help]       
#	name:  subjname (dash prefix => don't read MRI images)
#	hemi:  lh,rh
#	surf:  orig,smoothwm,plump,1000,1000a
foreach hemi (${hemi_list})
    $terminal -e tksurfer ${tmp_subj} ${hemi} ${cut_surface} -patch ${patch}.patch.flat #&
end

# last line following...
