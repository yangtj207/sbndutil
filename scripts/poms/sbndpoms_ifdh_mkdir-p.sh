#!/bin/bash

#This function makes the equivalent functionality of mkdir -p with ifdh.
#This is shamelessly stolen from redmine: https://cdcvs.fnal.gov/redmine/projects/ifdhc/wiki/What_about_mkdir_-p

ifdh_mkdir_p() {
    local dir=$1
    local force=$2
    echo "$0: Creating $dir with forced protocol: $force"

    if [ `ifdh ls $dir 0 $force | wc -l` -gt 0 ] 
    then
        : # we're done
    else
        ifdh_mkdir_p `dirname $dir` $force
        ifdh mkdir $dir $force
    fi
}

ifdh_mkdir_p $1 $2
