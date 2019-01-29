#! /bin/tcsh -f
# create an intermediate template from all subjects registration to the initial template

cd ..
set base_dir = `pwd`
set monkey_list = (060421Napoleon_c 060219Lupo_b 051028Michel_b 060512Quincy 060602Leonid 060702Ernie 060519Bert 060702Monchichi 070329Rocco)

set initial_subject = 060512Quincy
set hemi_list = (lh rh)
set out_subject = monkey_average_1
set surf = sphere




#USAGE:
#mris_register [options] <input surface> <average surface> <output surface>
#
#Options:
#
# -norot            : disable initial rigid alignment
# -nosulc           : disable initial sulc alignment
# -curv             : use smoothwm curvature for final alignment
# -jacobian <fname> : write-out jacobian overlay data to fname
# -dist <num>       : specify distance term
# -l <label file> <atlas (*.gcs)> <label name>
#                   : this option will specify a manual label
#                     to align with atlas label <label name>
# -addframe <which_field> <where_in_atlas> <l_corr> <l_pcorr>
# -overlay <surfvals> <navgs> : subject/labels/hemi.surfvals
# -overlay-dir <dir> : subject/dir/hemi.surfvals
# -1                 : target specifies a subject's surface,
#                      not a template file
#								     
#    This program registers a surface with an atlas.
										     

foreach monkey ($monkey_list)
    echo processing: $monkey
    cd $monkey/surf
    foreach hemi ($hemi_list)
	echo processing: $hemi
	mris_register -curv ${hemi}.sphere $SUBJECTS_DIR/avg_monkey/${hemi}.monkey_average_1.tif ${hemi}.sphere.reg1
	#cp ${hemi}.sphere.reg1 ${hemi}.sphere.reg
    end
    cd $base_dir
end




exit 0
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
    mris_make_template ${hemi} ${surf} ${monkey_list[*]} ${hemi}.${out_subject}.tif
end






exit 0

#USAGE:
#mris_register [options] <input surface> <average surface> <output surface>
#
#Options:
#
# -norot            : disable initial rigid alignment
# -nosulc           : disable initial sulc alignment
# -curv             : use smoothwm curvature for final alignment
# -jacobian <fname> : write-out jacobian overlay data to fname
# -dist <num>       : specify distance term
# -l <label file> <atlas (*.gcs)> <label name>
#                   : this option will specify a manual label
#                     to align with atlas label <label name>
# -addframe <which_field> <where_in_atlas> <l_corr> <l_pcorr>
# -overlay <surfvals> <navgs> : subject/labels/hemi.surfvals
# -overlay-dir <dir> : subject/dir/hemi.surfvals
# -1                 : target specifies a subject's surface,
#                      not a template file
#								     
#    This program registers a surface with an atlas.
										     

foreach monkey ($monkey_list)
    echo processing: $monkey
    cd $monkey/surf
    foreach hemi ($hemi_list)
	echo processing: $hemi
	mris_register -curv ${hemi}.sphere $SUBJECTS_DIR/avg_monkey/${hemi}.monkey_average_0.tif ${hemi}.sphere.reg0
    end
    cd $base_dir
end



#mris_register -curv ?h.sphere $FREESURFER_HOME/average/?h.average.curvature.filled.buckner40.tif ?h.sphere.reg

exit 0


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
