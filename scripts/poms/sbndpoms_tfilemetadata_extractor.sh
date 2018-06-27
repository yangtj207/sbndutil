#!/bin/bash

#Because of the way metadata_extractor works in fife_launch, the extractor script should only take one argument which is the name of the file (not the json) to be declared
#The TFile metadata creation scheme makes a json file as part of the job running.  We can't pass the name of the json to the extractor so we will need to assume a json name
#The assumed name is thet name of the tfile with .json appended i.e. $1.json

INPUTFILE="$1"
JSONFILE="${1}.json"



#We need to remove the braces at the end of the file as we are going to append more information
sed -i '$ d' $JSONFILE
#We also need to add a comma to the end of the last line now that we are going to add more line
sed -i '$ s/$/\,/g' $JSONFILE


#Add the filename back in
echo "\"file_name\": \"`basename $INPUTFILE`\"," >> $JSONFILE
#Add the file size
FILESIZE=`wc -c < $INPUTFILE`
echo "\"file_size\": \"$FILESIZE\"," >> $JSONFILE


#calculate checksum
CHECKSUM=`samweb -e sbnd file-checksum $INPUTFILE`
echo "\"checksum\": $CHECKSUM," >> $JSONFILE


#Make sure that the last entry does not have a comma at the end of its line
sed -i '$ s/,//g' $JSONFILE
#
##re-add the closing brace
echo "}" >> $JSONFILE

#Dump the json to std::out, needed for metadata_extractor
cat $JSONFILE
