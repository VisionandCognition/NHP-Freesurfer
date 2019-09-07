#!/bin/bash

cd /media/DATA1/NHP_MRI/Template/NMT/single_subject_scans
cd Eddy
echo "Processing Eddy..."
./align_and_process_singlesubject.sh Eddy
cd ../Dasheng
echo "Processing Dasheng..."
./align_and_process_singlesubject.sh Dasheng
cd ../Tsitian
echo "Processing Tsitian..."
./align_and_process_singlesubject.sh Tsitian