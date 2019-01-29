#! /bin/tcsh -f
# create the initial template

set initial_subject = 060512Quincy
set hemi_list = (lh rh)
set out_subject = monkey_average_0
set surf = sphere

#mris_make_template [options] <hemi> <surface name> <subject> <subject> ... <output name>
#
#Options:
#
# -addframe which_field where_in_atlas
# -vector : printf additional information for <addframe>
# -norot : align before averaging
# -annot : zero medial wall
# -overlay overlay naverages: use subject/label/hemi.overlay
# -overlay-dir dir: use subject/dir/hemi.overlay
# -s scale
# -a N : smooth curvature N iterations
# -sdir SUBJECTS_DIR
	 

foreach hemi (${hemi_list})
    echo processing: $hemi
    mris_make_template ${hemi} ${surf} ${initial_subject} ${hemi}.${out_subject}.tif
end


exit 0

cd ..
set base_dir = `pwd`
set monkey_list = (060421Napoleon_c 060219Lupo_b 051028Michel_b 060512Quincy 060602Leonid 060702Ernie 060519Bert 060702Monchichi 070329Rocco)
set hemi_list = (lh rh)

foreach monkey ($monkey_list)
    echo processing: $monkey
    cd $monkey/surf
    foreach hemi ($hemi_list)
	echo processing: $hemi
	mris_sphere ${hemi}.inflated ${hemi}.sphere
    end
    cd $base_dir
end

#make_average_subject --out avg_monkey --subjects 060421Napoleon_c 060219Lupo_b 051028Michel_b 060512Quincy 060602Leonid 060702Ernie 060519Bert 060702Monchichi 070329Rocco   
#mris_make_template

# last line follows...
