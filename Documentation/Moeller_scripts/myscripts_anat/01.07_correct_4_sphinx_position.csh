#! /bin/csh -f
# at least the Bremen Siemens Allegra does not allow to correctly specify the sphinx position
# (the mnonkeys view axis is throug the bore from front to back) we use for the monkeys. To correct
# this, mir_convert comes to the rescue... (--in_orientation)
# A correctly specified Volume loaded in tkmedit will produce the following views: (capital letters denote what you see)
#	the RAS coordinates can not be used for the matchning (c, h, s(N) are slice numbers, which are reliable) 
# coronal: (c(0) is posterior, c(255) is anterior)
#	X: LEFTT right RIGHT left (so the subjects right hemisphere is on the left)
#	Y: TOP superior, BOTTOM inferior
# horizontal: (h(0) is superior, h(255) is inferior)
#	X: LEFT right RIGHT left (so the subjects right hemisphere is on the left)
#	Y: TOP anterior, BOTTOM posterior
# sagital: (s(0) is right, s(255) is left)
#	X: LEFT posterior, RIGHT anterior
#	Y: TOP superior, BOTTOM inferior
# HOWTO: if the initial orientation of the conformed_rawavg.mgz does not match the axis as seen in tkmedit
#	try different position strings and rerun until the displayed volume looks right


# set the target directory and file_name
set targ_dir = ../mri
# we do thid with the "conformed" raw average
set input_vol = conformed_rawavg.mgz
set fsl_input_vol = fsl_conformed_rawavg.mgz

## 20060622: account for sphinx
# allowd are R, L, A, P , S, P
# bert is in LIA, so maybe --out_orientation LIA would be useful?
set pos_string = RPI	# works for "transversal slices, head first supine, with monkey in sphinx ppsition"
#set pos_string = SPL # this works for MARIAs Dagobert scan, patient position unknown...

# do the deed
mri_convert -i ${targ_dir}/${input_vol} -o ${targ_dir}/${input_vol} --in_orientation ${pos_string}
mri_convert -i ${targ_dir}/${fsl_input_vol} -o ${targ_dir}/${fsl_input_vol} --in_orientation ${pos_string}

# check the results...
tkmedit -f ${targ_dir}/${input_vol}


# last line follows...
