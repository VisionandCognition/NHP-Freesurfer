#!/bin/bash
echo 'Swapping x voxel order'
for f in $(find ./* -name '*.nii.gz'); do 
	fslswapdim $f -x y z $f
done
echo 'Done'
