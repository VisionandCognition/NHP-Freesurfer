#! /bin/csh -f
# define the patches/cuts to flatten the cortex
#FLATTENING
#
#Flattening is not actually done in this script. This part just documents
#how one would go about performing the flattening. First, load the subject
#surface into tksurfer:
#
#  tksurfer subjid lh inflated
#  
#  Load the curvature through the File->Curvature->Load menu (load
#  lh.curv). This should show a green/red curvature pattern. Red = sulci.
#  
#  Right click before making a cut; this will clear previous points. This
#  is needed because it will string together all the previous places you
#  have clicked to make the cut. To make a line cut, left click on a line
#  of points. Make the points fairly close together; if they are too far
#  appart, the cut fails. After making your line of points, execute the
#  cut by clicking on the Cut icon (scissors with an open triangle for a
#  line cut or scissors with a closed triangle for a closed cut). To make
#  a plane cut, left click on three points to define the plane, then left
#  click on the side to keep. Then hit the CutPlane icon.
#  
#  Fill the patch. Left click in the part of the surface that you want to
#  form your patch. Then hit the Fill Uncut Area button (icon = filled
#  triangle). This will fill the patch with white. The non-patch area
#  will be unaccessible through the interface.  Save the patch through
#  File->Patch->SaveAs. For whole cortex, save it to something like
#  lh.cort.patch.3d. For occipital patches, save it to lh.occip.patch.3d.
#  
#  Cd into the subject surf directory and run
#  
#    mris_flatten -w N -distances Size Radius lh.patch.3d lh.patch.flat
#    
#    where N instructs mris_flatten to write out an intermediate surface
#    every N interations. This is only useful for making movies; otherwise
#    set N=0.  Size is maximum number of neighbors; Radius radius (mm) in
#    which to search for neighbors. In general, the more neighbors that are
#    taken into account, the less the metric distortion but the more
#    computationally intensive. Typical values are Size=12 for large
#    patches, and Size=20 for small patches. Radius is typically 7.
#    Note: flattening may take 12-24 hours to complete. The patch can be
#    viewed at any time by loading the subjects inflated surface, then
#    loading the patch through File->Patch->LoadPatch...

set iterations = 0
set size = 20
set radius = 7

set cur_dir  = `pwd`    
# get the subjid...
cd ..
set tmp_subj = 0?????[A-Z]*
cd ${cur_dir}

set hemi_list = (lh rh)
set patch_list = (temp)
set terminal = xterm

cd ../surf

foreach hemi (${hemi_list})
    foreach patch (${patch_list})
	set in_patch = ${hemi}.${patch}.patch.3d
	set out_patch = ${hemi}.${patch}.patch.flat
	# do the heavy lifting
	mris_flatten -w ${iterations} -distances ${size} ${radius} ${in_patch} ${out_patch}
    end
end

# last line following...
