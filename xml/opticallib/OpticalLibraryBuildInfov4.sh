#!/bin/bash
#
# Author: bjpjones@fnal.gov from echurch@fnal.gov from dbox@fnal.gov
#
# Small subset of a script to run the optical library building job on the grid within larbatch infrastructure, modified by pkryczyn@fnal.gov
#
#
# To run this job:
#
# jobsub -X509_USER_PROXY /scratch/[user]/grid/[user].uboone.proxy -N [NoOfJobs] -q OpticalLibraryBuild_Grid.sh `whoami` `pwd`
#
# You will get outputs in the area specified by the "outstage" variable 
# which is specified below.
#
# The form of the output is one file for each few voxels. These then need 
# stitching together, which is done after all jobs are done, with a
# dedicated stitching script.
#

umask 0002
verbose=T

# Copy arguments into meaningful names.

process=${PROCESS}
cluster=${CLUSTER}



# Library building parameters

# In each grid job, do this many voxels:
NVoxelsPerJob=320


# In each voxel, run this many photons:
NPhotonsPerVoxel=100000

NTopVoxel=320001
echo $FHICL_FILE_PATH "fhicl file path"
# This works out which voxels this job should focus on: 
FirstVoxel=`echo "($NVoxelsPerJob * $PROCESS ) % $NTopVoxel" | bc`
LastVoxel=`echo "(($NVoxelsPerJob * $PROCESS ) + $NVoxelsPerJob - 1 ) % $NTopVoxel" | bc`


# And then tell the user about it:
echo "This job will run from voxel $FirstVoxel to $LastVoxel, generating $NPhotonsPerVoxel in each"

echo "physics.producers.generator.FirstVoxel: $FirstVoxel" >> $FCL
echo "physics.producers.generator.LastVoxel: $LastVoxel" >> $FCL
echo "physics.producers.generator.N: $NPhotonsPerVoxel">> $FCL
echo "services.TFileService.fileName: \"${process}_hist.root\"" >> $FCL



