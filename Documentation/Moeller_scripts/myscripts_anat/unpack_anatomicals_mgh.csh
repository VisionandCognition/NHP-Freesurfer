#! /bin/csh -f
# unpacking of anatomy data without reslicing (keep original high resolution)



# from the unpacksdcmdir output unpack.log (this file contains interesting infos)
#------------------------------------------                                                                                          
#1          CircleScout  ok  256 256   3   1 34849795                                                                              
#2    Makmprage05mmAvg1  ok  256 256 144   1 34849810
#                                                                              
#3    Makmprage05mmAvg1  ok  256 192 160   1 34848924                                                                              
#4    Makmprage05mmAvg1  ok  256 192 160   1 34845234                                                                              
#5    Makmprage05mmAvg1  ok  256 192 160   1 34844579                                                                              
#6          CircleScout  ok  256 256   3   1 34840899                                                                              
#7    Makmprage05mmAvg1  ok  256 192 160   1 34840914                                                                              
#8    Makmprage05mmAvg1  ok  256 192 160   1 34840259       

# run number from the dicom file zero padded to three digits
set run = 008
# number of the first dicom file to contain data for this run (actually any dicom file for a run should do'?)
set first_dicom = 34840259


# the session to work on
set session_dir = 050610Lupo
set dicom_dir = 06131042
set user_id = moeller
# where does the dicom data live
set src_dir = /space/data/raw_data/20${session_dir}/
set src_file = $src_dir/$first_dicom
# where to put the cor files
set targ_base_dir = /space/data/${user_id}/cooked/anatomicals/$session_dir/mri
mkdir $targ_base_dir
# the next one has to match the run number from the dicom information...
set targ_dir = $targ_base_dir/orig


# get the dimensions (read from unpack.log)
# let's do it like freesurfer does (no error checkin though)
set first_two_dims = `mri_probedicom --i $src_file --t 28 30`
# tag 28 30 is of form 0.453125\0.453125, so split the critter at the back slash
#echo $first_two_dims
set first_dim = `echo "$first_two_dims" | awk '{split($0, a, "\\"); print a[1]}'`
#echo $first_dim
set second_dim = `echo "$first_two_dims" | awk '{split($0, a, "\\"); print a[2]}'`
#echo $second_dim
# the slice resolution either in tag 18 50 or 18 88
set third_dim = `mri_probedicom --i $src_file --t 18 50`
#echo $third_dim

# get the shortes dimension, all this requires gnu bc to be installed
set min_dim = `echo "min = $first_dim; if (min > $second_dim) { min = $second_dim }; if (min > $third_dim) { min = $third_dim }; min" | bc -l`
set iis = `echo "scale=6; $first_dim / $min_dim" | bc -l`
set ijs = `echo "scale=6; $second_dim / $min_dim" | bc -l`
set iks = `echo "scale=6; $third_dim / $min_dim" | bc -l`

#for unpacking at raw resolution
mri_convert -i $src_file -o $targ_dir -it siemens_dicom -ot mgh #-iis $iis -ijs $ijs -iks $iks










