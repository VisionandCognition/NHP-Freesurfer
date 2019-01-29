#! /bin/tcsh -x
# batch create the missing parts to create a common monkey template
cd ..

set base_dir = `pwd`
set monkey_list = (060421Napoleon_c 060219Lupo_b 051028Michel_b 060512Quincy 060602Leonid 060702Ernie 060519Bert 060702Monchichi 070329Rocco)
set hemi_list = (lh rh)

set create_spheres = 0		# the template is made from the spherical representation
set create_inflated2 = 1	# the template generation needs additional information

if (${create_spheres} == 1) then
    foreach monkey ($monkey_list)
	echo processing: $monkey
        cd $monkey/surf
	foreach hemi ($hemi_list)
	    echo processing: $monkey $hemi
    	    mris_sphere ${hemi}.inflated ${hemi}.sphere
	end
        cd $base_dir
    end
    set create_inflated2 = 1
endif

if (${create_inflated2} == 1) then
    foreach monkey ($monkey_list)
	echo processing: $monkey
        cd $monkey/surf
	foreach hemi ($hemi_list)
	    echo processing: $monkey $hemi
    	    #mris_sphere ${hemi}.inflated ${hemi}.sphere
	    mris_curvature -thresh .999 -n -a 5 -w -distances 10 10 ${hemi}.inflated	
	end
        cd $base_dir
    end
endif








#make_average_subject --out avg_monkey --subjects 060421Napoleon_c 060219Lupo_b 051028Michel_b 060512Quincy 060602Leonid 060702Ernie 060519Bert 060702Monchichi 070329Rocco   
#mris_make_template

# last line follows...
