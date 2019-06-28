#!/bin/bash


INPUTFILE="$1"
OUTPUTFILE="${1}.json"

#dump the output to a json file
sam_metadata_dumper $INPUTFILE > $OUTPUTFILE

#we need to remove the 2nd line from the json file (the name of the file without the file_name label, we will re-add the filename using the argument later on 
sed -i '2d' $OUTPUTFILE

#we need to remove the 2nd to last line of the file which contains the additional curly brace that went with the incorrect syntax filename
#Get the number of lines in the file
NLINES=`cat $OUTPUTFILE | wc -l`
let SECONDLASTLINENO=NLINES-1
sed -i "${SECONDLASTLINENO}d" $OUTPUTFILE

#We need to remove the braces at the end of the file as we are going to append more information
sed -i '$ d' $OUTPUTFILE
#We also need to add a comma to the end of the last line now that we are going to add more line
sed -i '$ s/$/\,/g' $OUTPUTFILE

#Remove the lines that are bad
#run_type
sed -i '/run_type/d' $OUTPUTFILE
##applicationVersion
#sed -i '/applicationVersion/d' $OUTPUTFILE
##applicationFamily
#sed -i '/applicationFamily/d' $OUTPUTFILE
##process_name
#sed -i '/process_name/d' $OUTPUTFILE
##fclVersion
sed -i '/fclVersion/d' $OUTPUTFILE
##file_format_era
sed -i '/file_format_era/d' $OUTPUTFILE
##file_format_version
sed -i '/file_format_version/d' $OUTPUTFILE

#Define the application object
#First collect application name
APPNAME=`grep "process_name" $OUTPUTFILE`
#Now remove it from the json
sed -i '/process_name/d' $OUTPUTFILE
#Separate APPNAME on the comma
FS=\: read -a APPNAMEARRAY <<<"$APPNAME"
#Collect the value of the process_name i.e. SinglesGen
APPNAME=${APPNAMEARRAY[1]}
#Remove the comma if there is one
APPNAME=`echo ${APPNAME} | sed 's/,//g'`
#Do the same for application family
APPFAMILY=`grep "application.family" $OUTPUTFILE`
sed -i '/application.family/d' $OUTPUTFILE
FS=\: read -a APPFAMILYARRAY <<<"$APPFAMILY"
APPFAMILY=${APPFAMILYARRAY[1]}
APPFAMILY=`echo ${APPFAMILY} | sed 's/,//g'`
#and the app version
APPVERSION=`grep "application.version" $OUTPUTFILE`
sed -i '/application.version/d' $OUTPUTFILE
FS=\: read -a APPVERSIONARRAY <<<"$APPVERSION"
APPVERSION=${APPVERSIONARRAY[1]}
APPVERSION=`echo ${APPVERSION} | sed 's/,//g'`
#Now constrcut the application object
echo "\"application\" : {" >> $OUTPUTFILE
echo "\"name\": $APPNAME," >> $OUTPUTFILE
echo "\"family\": $APPFAMILY," >> $OUTPUTFILE
echo "\"version\": $APPVERSION" >> $OUTPUTFILE
echo "}," >> $OUTPUTFILE

#Correct first_event
#Get the line
FIRSTEVENTLINE=`grep "first_event" $OUTPUTFILE`
#extract the number from the line
FIRSTEVENTNO=`echo $FIRSTEVENTLINE | cut -d "[" -f2 | cut -d "]" -f1 | cut -d "," -f3`
#Replace the old line with a newly constructed one
sed -i "s/.*first_event.*/\"first_event\": $FIRSTEVENTNO,/" $OUTPUTFILE

#Correct last_event
#Get the line
LASTEVENTLINE=`grep "last_event" $OUTPUTFILE`
#extract the number from the line
LASTEVENTNO=`echo $LASTEVENTLINE | cut -d "[" -f2 | cut -d "]" -f1 | cut -d "," -f3`
#Replace the old line with a newly constructed one
sed -i "s/.*last_event.*/\"last_event\": $LASTEVENTNO,/" $OUTPUTFILE

#Add the filename back in
echo "\"file_name\": \"`basename $INPUTFILE`\"," >> $OUTPUTFILE
#Add the file size
FILESIZE=`wc -c < $INPUTFILE`
echo "\"file_size\": \"$FILESIZE\"," >> $OUTPUTFILE

#production.name, which is a string, can contain only numbers.  sam_metadata_dumper will convert this value to a double which makes the metadata invalid.
#We need to ensure that production.name's value is a string
#Store production.name
PRODUCTIONNAME=`grep "production.name" $OUTPUTFILE`
#Split the Key : Value on the colon
IFS=\: read -a PRODUCTIONNAMEARRAY <<<"$PRODUCTIONNAME"
#Remove the trailing , if there is one
PRODUCTIONNAMEARRAY[1]=`echo ${PRODUCTIONNAMEARRAY[1]} | sed 's/,//g'`
#Remove quotes if there are any
PRODUCTIONNAMEARRAY[1]=`echo ${PRODUCTIONNAMEARRAY[1]} | sed 's/\"//g'`
#Now reconstruct the key value pair
PRODUCTIONNAME="${PRODUCTIONNAMEARRAY[0]}: \"${PRODUCTIONNAMEARRAY[1]}\","
#Remove the old production.name from the json
sed -i '/production.name/d' $OUTPUTFILE
#and add the new one
echo $PRODUCTIONNAME >> $OUTPUTFILE

#calculate checksum
CHECKSUM=`samweb -e sbnd file-checksum $INPUTFILE`
echo "\"checksum\": $CHECKSUM," >> $OUTPUTFILE

##Get the CRC  Format from fileEnstoreChecsum is {'crc_value': '3325351510', 'crc_type': 'adler 32 crc type'}
#CRC=`python -c "import root_metadata; print root_metadata.fileEnstoreChecksum(\"$INPUTFILE\")"`
##Drop the Curly braces
#CRC=`echo $CRC | sed 's/{//'`
#CRC=`echo $CRC | sed 's/}//'`
##Replace single quotes with double quotes
#CRC=`echo $CRC | sed s/\'/\"/g`
##Now split the CRC lines on the commas
#IFS=\, read -a CRCARRAY <<<"$CRC"
##Now add the CRC info to the json
#echo "\"crc\": {" >> $OUTPUTFILE
#echo "${CRCARRAY[0]}," >> $OUTPUTFILE
#echo "${CRCARRAY[1]}" >> $OUTPUTFILE
#echo "}" >> $OUTPUTFILE


#Make sure that the last entry does not have a comma at the end of its line
sed -i '$ s/,//g' $OUTPUTFILE
#
##re-add the closing brace
echo "}" >> $OUTPUTFILE

#Dump the json to std::out, needed for metadata_extractor
cat $OUTPUTFILE
