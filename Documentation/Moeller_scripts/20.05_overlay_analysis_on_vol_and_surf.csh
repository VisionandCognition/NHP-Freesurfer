#! /bin/tcsh -f
# define and calculate surface based maps
# TODO: make flatmap output work... (done)
#	rotate the flat maps into the proper position
#	make volume slice output work...
#	special case monkeys with flipped structurals (Napoleon) to handle this gracefully...
#	teach this script to get the microstimulation results from the face_localizer sub directories

#cd ../mystudy
set calling_dir = `pwd`
set base_dir = /space/data/moeller/cooked/2010

# define the things to display
set show_slices = 0
set show_timecourse = 0
set show_surface = 0
set show_func_vol = 1
set batch_surf_process = 0	# process the surfaces in batch mode
set batch_vol_process = 1	# process the volume in batch mode

#set ovl_sess_dir = `pwd`
set ovl_sess = 100122-23Julien #060515-16Napoleon
set ovl_sub_sess = #${ovl_sess}
set ovl_sess_dir = ${base_dir}/${ovl_sess}
set in_sess_struct = 0	# display on in session structural?


## undistorted on structural
set stim_loc = _undistorted
set reg_id = #.undistorted
set analysis_list = (a2)
set func_stem = fmc
set func_ext = nii
set show_func_vol = 0
set truncate_pos = 1	# truncate positive values
set truncate_neg = 0	# or truncate negative values




# set some vars
# create the tmp directory 
set base = `pwd`
set uid = #`date +%F-%H-%M-%s`
set paint_tmpdir = ${base}/tmp_paint_${uid}
mkdir ${paint_tmpdir}

# analysis_list either sequence of analysis or keyword all
#set analysis_list = (a1)
#set analysis_list = (a1u)


# some vars are not "universal", asign them here
if (${ovl_sess} == 060515-16Napoleon) then
    set contrast_list = (c27_3456)
    # the anatomical session_id
    set anat_id = 060421Napoleon_a
    set patch_basename = oc.patch.flat		# what patch to load, if any... otherwise leave empty
    set zoomFactor = 1.5			# zoom the brain, leave empty for default
    set zoom_center = "128 128 128"
    set savetiff_slice_list = #(124 118 101 94)	# the list of slices to save as tiffs, SaveTIFFSeries does not work atm
#    set savetiff_slice_list = (`seq 36 1 198`)	# the list of slices to save as tiffs, SaveTIFFSeries does not work atm
    
else if (${ovl_sess} == 060624-25-26Monchichi) then
    set contrast_list = (c13_2456)
    # the anatomical session_id
    set anat_id = 060702Monchichi
    set patch_basename = oc.patch.flat		# what patch to load, if any... otherwise leave empty
    set zoomFactor = 1.2			# zoom the brain, leave empty for default
    set zoom_center = "128 128 128"
    set savetiff_slice_list = (133 140 158 154 160)	# the list of slices to save as tiffs, SaveTIFFSeries does not work atm

else if (${ovl_sess} == 060208-09-13Lupo_07) then
    set contrast_list = (c13_2456)
    # the anatomical session_id
    set anat_id = 060219Lupo
    set patch_basename = oc.patch.flat		# what patch to load, if any... otherwise leave empty
    #set patch_basename = occip1.patch.flat		# what patch to load, if any... otherwise leave empty
    set zoomFactor = 1.3	# zoom the brain, leave empty for default
    set zoom_center = "128 128 128"	#tkmedit
    #set savetiff_slice_list = (133 140 158 154 160)	# the list of slices to save as tiffs, SaveTIFFSeries does not work atm
    set savetiff_slice_list = (`seq 40 1 191`)

else if (${ovl_sess} == 060624-625-703Bert) then
    set contrast_list = (c13_2456)
    # the anatomical session_id
    set anat_id = 060519Bert
    set patch_basename = oc.patch.flat		# what patch to load, if any... otherwise leave empty
#    set patch_basename = occip1.patch.flat		# what patch to load, if any... otherwise leave empty
    set zoomFactor = 1.2			# zoom the brain, leave empty for default
    set zoom_center = "128 89 128" #tkmedit
    #set savetiff_slice_list = (133 140 158 154 160)	# the list of slices to save as tiffs, SaveTIFFSeries does not work atm
    set savetiff_slice_list = (`seq 110 1 167`)	#Bert's fp range (110-167), full brain range (66-221)

else if (${ovl_sess} == 100116Julien) then
    set contrast_list = (c13_2456)
    # the anatomical session_id
    set anat_id = 100116Julien
    set patch_basename = #oc.patch.flat		# what patch to load, if any... otherwise leave empty
#    set patch_basename = occip1.patch.flat		# what patch to load, if any... otherwise leave empty
    set zoomFactor = 1.2			# zoom the brain, leave empty for default
    set zoom_center = "128 128 128" #tkmedit
    #set savetiff_slice_list = (133 140 158 154 160)	# the list of slices to save as tiffs, SaveTIFFSeries does not work atm
    set savetiff_slice_list = (`seq 45 1 210`)	#Bert's fp range (110-167), full brain range (66-221)

else if (${ovl_sess} == 100122-23Julien) then
    set contrast_list = (c13_2456)
    # the anatomical session_id
    set anat_id = 100219Julien
    set patch_basename = #oc.patch.flat		# what patch to load, if any... otherwise leave empty
#    set patch_basename = occip1.patch.flat		# what patch to load, if any... otherwise leave empty
    set zoomFactor = 1.2			# zoom the brain, leave empty for default
    set zoom_center = "128 128 128" #tkmedit
    set savetiff_slice_list = (`seq 70 1 235`)

else if (${ovl_sess} == 100128-N-0213Napoleon) then
    set contrast_list = (c13_2456)
    # the anatomical session_id
    set anat_id = 100208Napoleon
    set patch_basename = #oc.patch.flat		# what patch to load, if any... otherwise leave empty
#    set patch_basename = #occip1.patch.flat		# what patch to load, if any... otherwise leave empty
    set zoomFactor = 1.2			# zoom the brain, leave empty for default
    set zoom_center = "128 128 128" #tkmedit
    #set savetiff_slice_list = (133 140 158 154 160)	# the list of slices to save as tiffs, SaveTIFFSeries does not work atm
    set savetiff_slice_list = #(`seq 45 1 210`)	#Bert's fp range (110-167), full brain range (66-221)

else
    # contrast list either a sequence of contrasts, or keyword all
    #set contrast_list = (all)
    set contrast_list = (c13_2456)
    # the anatomical session_id
    set anat_id = 060421Napoleon_a
    set patch_basename = oc.patch.flat		# what patch to load, if any... otherwise leave empty
    set zoomFactor = 1.5			# zoom the brain, leave empty for default
    set zoom_center = "128 128 128"	#tkmedit
    set savetiff_slice_list = #(100 128 99)	# the list of slices to save as tiffs, SaveTIFFSeries does not work atm

endif

if (${in_sess_struct}) then
    set reg_id = .in_session
    set anat_id = `cat ../mystudy/sf`
    set anat_dir = ${base_dir}/${anat_id}/mri
    set main_vol = T1_chair.mgz #conformed_rawavg.mgz #T1.mgz
else
    #set anat_id = `cat ../subjectname`
    #echo $anat_id
    set anat_dir = ${base_dir}/${anat_id}/mri
    set main_vol = T1.mgz #conformed_rawavg.mgz #T1.mgz
endif

# select the anatomical session to use
set structural = $anat_id


if (${show_func_vol} == 0) then
    set aux_vol = conformed_rawavg.mgz #brain.mgz	# this is the masked brain, nice for masking the overlay...
else
    set aux_vol = func_vol.mgz #brain.mgz	# this is the masked brain, nice for masking the overlay...
endif

set hemi_list = (lh rh)
set hemi_list = (rh)
set surface = inflated
set curv = sulc				# curv or sulc
#set patch_basename = oc.patch.flat	# what patch to load, if any... otherwise leave empty


#set ovl_surf_stem = sig-0-
#set ovl_surf_ext = .w
#set ovl_reg = ${ovl_sess_dir}/bold/register.dat
#set ovl_reg = ${ovl_sess_dir}/t1epi/100116Julien_2_100116Julien${reg_id}.register.dat
set ovl_reg = ${ovl_sess_dir}/t1epi/${ovl_sess}_2_${structural}${reg_id}.register.dat



if (${show_timecourse} == 1) then
    set tc = ${ovl_sess_dir}/bold/901/001/${func_stem}.${func_ext}
    set timecourse_string = "-timecourse ${tc} -timecourse-reg ${ovl_reg}"
else
    set timecourse_string
endif

if (${show_func_vol} == 1) then
    # reslice the functional volume to look like the anatomical...
    set func_dir = ${ovl_sess_dir}/bold/901/001
    set functional_4d = ${func_stem}.${func_ext}
    set functional = ${func_stem}_3d.mgz
    # now we only need the first frame...
    mri_convert -i ${func_dir}/${functional_4d} -o ${func_dir}/${functional} --frame 0
    #tkmedit -f ${func_dir}/${functional}
    # reslice and resample into the target template...
    mri_vol2vol --mov ${func_dir}/${functional}  --targ ${anat_dir}/${main_vol} --o ${anat_dir}/${aux_vol} \
                --reg ${ovl_reg}
    #tkregister2 --regheader --reg tmp.register.dat --targ ${anat_dir}/${main_vol} --mov ${anat_dir}/${aux_vol}
    set main_vol = ${aux_vol}	# force the display of the func volume
endif


# variables...
set map = sig
set terminal = #"xterm -e"
# some variables for mri_vol2surf
#set proj_fract = "--projfrac-avg -0.3 0.7 0.2"
set proj_fract = "--projfrac-avg 0.7 1.0 0.1"	# this averages the probabilty from well inside the white matter (-0.3) almost to the pia
set proj_fract = "--projfrac 0.5"
set target_surf = white
set ovl_stem = $map
set ovl_ext = nii

# some vars for tksurfer batch mode, try to use the same var for tkmedit batch mode as well
set fdr_thresh = #0.05	# if set, use false discovery rate to threshold the overlay to this "rate"
set fthresh = 4#2.3		# if fdr_thresh is empty, fthresh, fslope and fmid control the 
set fslope = 1.0 	#	display of the overlay
set fmid = 10		#
set truncphaseflag = 0	# 1 or 0, only show the positive 
set invphaseflag = 1	# 1 or 0, invert the colorscale (makes MION negative activation look HOT)
set falpha = 1		# [0-1], transparency of the overlay
set i_smooth = 2	# number of iterations for smoothing, or empty for no smoothing
set window_size = 900	# image size (default is 600)
#set zoomFactor = 1.5	# zoom the brain, leave empty for default
# tkmedit specific varibales
set sampleType = 1	# 0 nearest neighbor, 1 trilinear
#set truncate_pos = 0	# truncate positive values
#set truncate_neg = 0	# or truncate negative valoues
set ori = cor		# keep manually in sync with the next line...
set orientation = 0	# 0 = cor, 1 = hor, 2 = sag
#set start_slice = 128	# start saving from this slice
#set end_slice = 130	# stop saving at that slice
set savetiff_basename = vol_img_${ovl_sess}	# if empty do not save any tiffs
#set savetiff_slice_list = (100 128 99)		# the list of slices to save as tiffs, SaveTIFFSeries does not work atm
set zoom_vol = 2	# zoom factor for volumes
set alpha_vol = 1#0.5	# transparency of overlay
set vol_brightness = 0.35	# default is: 0.35
set vol_contrast = 12.0		# default is: 12.0

#echo "debug"
# collect all analysis...			   
if (${analysis_list[1]} == all) then
    cd ${ovl_sess_dir}/bold
    # analysis names have to follow the aN convention
    set analysis_list = a[0-9]*
    cd $ovl_sess_dir
endif

# loop over the analysis
foreach analysis (${analysis_list})
    echo $analysis
    # get all the contrast for this analysis
    if (${contrast_list[1]} == all) then
	cd ${ovl_sess_dir}/bold/${analysis}
	set tmp_contrasts = c[0-9]*_[0-9]*
	cd $ovl_sess_dir
    else
	set tmp_contrasts = $contrast_list    
    endif

    foreach contrast (${tmp_contrasts})
	echo $contrast
	foreach hemi (${hemi_list})
	    # create the surfaceized volume image
#	    mri_vol2surf --src ${ovl_sess_dir}/bold/${analysis}/${contrast}/${ovl_stem}.${ovl_ext} --src_type bfloat --srcreg ${ovl_reg} ${proj_fract} \
#		    --trgsubject ${structural}  --surf ${target_surf} --hemi ${hemi} \
#		    --out ${paint_tmpdir}/${ovl_stem}-${hemi}.mgz  --out_type mgz \
#		    --frame 0
	    #echo debug	     
	    set ovl = ${ovl_sess_dir}/bold/${analysis}/${contrast}/${map}.${ovl_ext}
	    
	    if (${show_slices} == 1) then
#		$terminal tkmedit ${anat_id} ${main_vol} ${hemi}.white -aux ${aux_vol} -overlay ${ovl} -overlay-reg ${ovl_reg} ${timecourse_string}&
		$terminal tkmedit -f ${anat_dir}/${main_vol} -aux ${anat_dir}/${aux_vol} -overlay ${ovl} -overlay-reg ${ovl_reg} ${timecourse_string}
	    endif

	    if (${show_surface} == 1) then
		# deal with the patch to load... ATTENTION might require rotation befor it gets visible in tksurfer, sigh...
		if (${%patch_basename} > 0) then
		    set patch_str = "-patch ${hemi}.${patch_basename}"
		else
		    set patch_str = 
		endif
	        ${terminal} tksurfer ${structural} ${hemi} ${surface} -overlay ${paint_tmpdir}/${ovl_stem}-${hemi}.mgh -colorscalebarflag 0 ${patch_str}
		#$terminal surf-sess -sf sf -df df -analysis ${analysis} -contrast ${contrast} -hemi ${hemi} -surf ${surface} -curv $curv ${patch_str}
	    endif
	    
	    # batch process the surfaces
	    if (${batch_surf_process} == 1) then
    		set structural = $anat_id
		set tmp_script = surface_batcher.tcl
		set image_dir = `pwd`/images${stim_loc}
		if !(-e ${image_dir}) then
		    mkdir ${image_dir}
		endif
		# create the script...
		# > truncates the file, basically deletes the content if the file already existed
		# >> appends
		# to create $ in the tcl script they have to be escaped, so that csh leaves them alone, "\$" is how it is done... 
		echo "#temporary tcl scripting file to remote control tksurfer">`pwd`/${tmp_script}
		
		# create larger output image
		if (${%window_size} > 0) then
		    echo "resize_window ${window_size}">>`pwd`/${tmp_script}
		endif
		
		echo "set gaLinkedVars(scalebarflag) 1">>`pwd`/${tmp_script}
		echo "SendLinkedVarGroup view">>`pwd`/${tmp_script}
	
		echo "set gaLinkedVars(colscalebarflag) 1">>`pwd`/${tmp_script}
		echo "SendLinkedVarGroup view">>`pwd`/${tmp_script}
	    
		# truncate overlay?
		echo "set gaLinkedVars(truncphaseflag) ${truncphaseflag}">>`pwd`/${tmp_script}
		echo "SendLinkedVarGroup overlay">>`pwd`/${tmp_script}
		# invert overlay?
		echo "set gaLinkedVars(invphaseflag) ${invphaseflag}">>`pwd`/${tmp_script}
		echo "SendLinkedVarGroup overlay">>`pwd`/${tmp_script}
		# transparency of overlay
		echo "set gaLinkedVars(falpha) ${falpha}">>`pwd`/${tmp_script}
		echo "SendLinkedVarGroup overlay">>`pwd`/${tmp_script}
	
		# zoom?
		if (${%zoomFactor} > 0) then
		    echo "scale_brain ${zoomFactor}">>`pwd`/${tmp_script}
		endif
	
		echo "puts "\$"curv">>`pwd`/${tmp_script}
		echo "set curv ${SUBJECTS_DIR}/${structural}/surf/${hemi}.${curv}">>`pwd`/${tmp_script}
		echo "read_binary_curv">>`pwd`/${tmp_script}
		
		# display on flatmap?
		if (${%patch_basename} > 0) then
		    echo "puts ¨"\$"patch¨">>`pwd`/${tmp_script}    
		    echo "set patch ${SUBJECTS_DIR}/${structural}/surf/${hemi}.${patch_basename}">>`pwd`/${tmp_script}
		    echo "read_binary_patch">>`pwd`/${tmp_script}
		    # now make the patch visible (Napoleon need -90 in x to show the patch)
		    echo "rotate_brain_x -90">>`pwd`/${tmp_script}
		    echo "redraw">>`pwd`/${tmp_script}
		    # custom rotations
		    switch (${patch_basename})
		    case oc.patch.flat:
			if (${anat_id} == 060421Napoleon_a) then	
			    if (${hemi} == lh) then
				echo "rotate_brain_z 180">>`pwd`/${tmp_script}
			    else
				echo "rotate_brain_z -30">>`pwd`/${tmp_script}
			    endif
			endif
 			
			if (${anat_id} == 060702Monchichi) then	
			    if (${hemi} == lh) then
				echo "rotate_brain_z 180">>`pwd`/${tmp_script}
			    else
				echo "rotate_brain_z -30">>`pwd`/${tmp_script}
			    endif
			endif
			if (${anat_id} == 060219Lupo) then	
			    if (${hemi} == lh) then
				echo "rotate_brain_z 210">>`pwd`/${tmp_script}
			    else
				echo "rotate_brain_z -10">>`pwd`/${tmp_script}
			    endif
			endif

			if (${anat_id} == 060519Bert) then	
			    if (${hemi} == lh) then
				echo "rotate_brain_z 150">>`pwd`/${tmp_script}
			    else
				echo "rotate_brain_z -0">>`pwd`/${tmp_script}
			    endif
			endif
		    
			breaksw
		    case occip1.patch.flat:
			if (${anat_id} == 060519Bert) then	
			    if (${hemi} == lh) then
				echo "rotate_brain_z 150">>`pwd`/${tmp_script}
			    else
				echo "rotate_brain_z -0">>`pwd`/${tmp_script}
			    endif
			endif

 			breaksw
		    default:
			echo "no special casing for (${patch_basename}"
		    endsw
		    		    
		endif
		
		# load the overlay...
		echo "set val ${paint_tmpdir}/${ovl_stem}-${hemi}.\mgh">>`pwd`/${tmp_script}
		echo "sclv_read_binary_values 0">>`pwd`/${tmp_script}

		# use fdr, or manual adjustment of the thresholding... (only works AFTER the overlay has been loaded, obviously...)
		if (${%fdr_thresh} > 0) then
		    echo "sclv_set_current_threshold_using_fdr ${fdr_thresh} 0">>`pwd`/${tmp_script}
		else
		    echo "set gaLinkedVars(fthresh) ${fthresh}">>`pwd`/${tmp_script}
		    echo "SendLinkedVarGroup overlay">>`pwd`/${tmp_script}
		    echo "set gaLinkedVars(fslope) ${fslope}">>`pwd`/${tmp_script}
		    echo "SendLinkedVarGroup overlay">>`pwd`/${tmp_script}
		    echo "set gaLinkedVars(fmid) ${fmid}">>`pwd`/${tmp_script}
		    echo "SendLinkedVarGroup overlay">>`pwd`/${tmp_script}
		endif

	    	if (${%i_smooth} > 0) then
		    echo "sclv_smooth ${i_smooth} 0">>`pwd`/${tmp_script}		# smoothing of 3 looks nicer...
		endif
		
		echo "redraw">>`pwd`/${tmp_script}
	    
		# save the created image
		echo "save_tiff ${image_dir}/${ovl_sess}_${ovl_stem}_${analysis}_${contrast}_on_${structural}-${hemi}.tif">>`pwd`/${tmp_script}
	    
		# make sure to exit tksurfer...
#		echo "exit">>`pwd`/${tmp_script}
	    
		#less $tmp_script
		# do the heavy lifting
		tksurfer ${structural} ${hemi} ${surface} -tcl `pwd`/${tmp_script}
	    
		# clean up...
		rm `pwd`/${tmp_script}
	    endif
	end

	# batch process the volumes
        if (${batch_vol_process} == 1) then
    	    set structural = $anat_id
	    set tmp_script = volume_batcher.tcl
	    set image_dir = `pwd`/images${stim_loc}
	    if !(-e ${image_dir}) then
		mkdir ${image_dir}
	    endif
	    # create the script...
	    # > truncates the file, basically deletes the content if the file already existed
	    # >> appends
	    # to create $ in the tcl script they have to be escaped, so that csh leaves them alone, "\$" is how it is done... 
	    echo "#temporary tcl scripting file to remote control tkMedit">`pwd`/${tmp_script}
		
	    # load an overlay, if not already done... (the zero arg tells to use use arg 3 as registration file)
	    echo "LoadFunctionalOverlay ${ovl} 0 ${ovl_reg}">>`pwd`/${tmp_script}		
		
	    # the orientation
	    echo "SetOrientation ${orientation}">>`pwd`/${tmp_script} 	# control points
	    # zoom
	    echo "SetZoomLevel ${zoom_vol}">>`pwd`/${tmp_script}
	    echo "SetZoomCenter ${zoom_center}">>`pwd`/${tmp_script}
		
	    # toggle main display setting
	    echo "SetDisplayFlag 9 0">>`pwd`/${tmp_script} 	# control points
	    echo "SetDisplayFlag 14 1">>`pwd`/${tmp_script}	# mask the overlay to the aux volume (hopefully the stripped brain)
	    echo "SetDisplayFlag 3 0">>`pwd`/${tmp_script} 	# cursor
	    
    	    # set volume brightness and contrast 0 is the main_vol, 1 the aux_vol
            if (${%vol_brightness} > 0) then
        	echo "SetVolumeBrightnessContrast 0 ${vol_brightness} ${vol_contrast}">>`pwd`/${tmp_script}
        	echo "SetVolumeBrightnessContrast 1 ${vol_brightness} ${vol_contrast}">>`pwd`/${tmp_script}
            endif
                                                
	    # set the overlay flags
    	    echo "Overlay_SetDisplayFlag 2 ${invphaseflag}">>`pwd`/${tmp_script}
	    if (${truncate_neg} == 1) then
		echo "Overlay_SetDisplayFlag 0 ${truncate_neg}">>`pwd`/${tmp_script}
	    endif
	    if (${truncate_pos} == 1) then
		echo "Overlay_SetDisplayFlag 1 ${truncate_pos}">>`pwd`/${tmp_script}
	    endif		
	    # nearest neighbor or trilinear
	    echo "Overlay_SetVolumeSampleType ${sampleType}">>`pwd`/${tmp_script}

	    # use fdr, or manual adjustment of the thresholding... (only works AFTER the overlay has been loaded, obviously...)
	    if (${%fdr_thresh} > 0) then
		echo "Overlay_SetThresholdUsingFDR ${fdr_thresh} 0">>`pwd`/${tmp_script}
		echo "Overlay_CalcNewPiecewiseThresholdMaxFromMidSlope">>`pwd`/${tmp_script}
	    else
		echo "Overlay_SetThreshold ${fthresh} ${fmid} ${fslope}">>`pwd`/${tmp_script}
	    endif
	    
	    # transparency
	    echo "SetFuncOverlayAlpha ${alpha_vol}">>`pwd`/${tmp_script}
	    echo "Overlay_SaveConfiguration">>`pwd`/${tmp_script}
	    echo "RedrawScreen">>`pwd`/${tmp_script}
	    
	    # save the output
	    if ((${%savetiff_slice_list} > 0) & (${%savetiff_basename} > 0)) then
	    
		foreach slice (${savetiff_slice_list})
		    #echo $slice
		end
		#echo ${savetiff_slice_list}
		foreach slice (${savetiff_slice_list})
		    #echo debug
		    #echo ${savetiff_slice_list}
		    set padded_slice = `printf "%03d" $slice`
		    echo "SetSlice ${slice}">>`pwd`/${tmp_script}
		    echo "RedrawScreen">>`pwd`/${tmp_script}
		    echo "SaveTIFF ${image_dir}/${savetiff_basename}_${ori}_${padded_slice}.tif">>`pwd`/${tmp_script}
		    #exit 0
		end
                # export the colorbar plot...
                echo "SetDisplayFlag 12 1">>`pwd`/${tmp_script} # show the colorbar
                echo "RedrawScreen">>`pwd`/${tmp_script}
                echo "SaveTIFF ${image_dir}/colorbar_${ovl_sub_sess}_${contrast}.tif">>`pwd`/${tmp_script}
	
	    endif 

	    # make sure to exit tkMedit...
#	    echo "QuitMedit">>`pwd`/${tmp_script}
	    
    	    #less $tmp_script
	    # do the heavy lifting
	    #set hemi = lh
	    #tkmedit ${anat_id} ${main_vol} ${hemi}.white -aux ${aux_vol} -overlay ${ovl} -overlay-reg ${ovl_reg} ${timecourse_string} -tcl `pwd`/${tmp_script}
	    tkmedit -f ${anat_dir}/${main_vol} -aux ${anat_dir}/${aux_vol} ${timecourse_string} -tcl `pwd`/${tmp_script}
			    
	    # clean up...
	    rm `pwd`/${tmp_script}
	endif
    end
end

## clean up
#rm -r ${paint_tmpdir}

exit 0
# last line follows...
    