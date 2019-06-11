#!/bin/bash

#source.firstSubRun: 1
#Subrun follows $PROCESS+1
#After every 100 subruns, a new run is started
export NSUBRUNSPERRUN=100
export WORKDIR="/sbnd/app/users/dbrailsf/generated_fcls"

while :; do
    case $1 in
        -h|-\?|--help)
            show_help    # Display a usage synopsis.
            exit
            ;;
        --fcl)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                FCL="$2"
                shift
            else
                echo "$0 ERROR: fcl requires a non-empty option argument."
                exit 1
            fi
            ;;
        --outdir)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                OUTDIR="$2"
                shift
            else
                echo "$0 ERROR: outdir requires a non-empty option argument."
                exit 1
            fi
            ;;
        --samdeclare)
            SAMDECLARE=true
            ;;
        --nfiles)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                NFILES="$2"
                shift
            else
                echo "$0 ERROR: nfiles requires a non-empty option argument."
                exit 1
            fi
            ;;
        --workdir)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                WORKDIR="$2"
                shift
            else
                echo "$0 ERROR: workdir requires a non-empty option argument."
                exit 1
            fi
            ;;

        -v|--verbose)
            verbose=$((verbose + 1))  # Each -v adds 1 to verbosity.
            ;;
        --)              # End of all options.
            shift
            break
            ;;
        -?*)
            printf "$0 WARN: Unknown option (ignored): %s\n" "$1" >&2
            ;;
        *)               # Default case: No more options, so break out of the loop.
            break
    esac
    shift
done

if [ -z "$FCL" ]; then
  echo "$0 ERROR: fcl is mandatory"
  exit 2
fi
if [ -z "$OUTDIR" ]; then
  echo "$0 ERROR: outdir is mandatory"
  exit 2
fi
if [ -z "$NFILES" ]; then
  echo "$0 ERROR: nfiles is mandatory"
  exit 2
fi

#make the output direcrory
mkdir -p $OUTDIR
mkdir -p $WORKDIR

#We need to extract what the default run number is.  Let's get this from running lar and dumping the config
lar --debug-config lar_config_dump.txt -c $FCL
DEFAULTRUN=`grep -r "firstRun" lar_config_dump.txt`
#THis line is of the form firstRun: RUN
#We need to extract RUN
#Delimit on the colon
IFS=\: read -a DEFAULTRUNARRAY <<<"$DEFAULTRUN"
#Extract the run number
DEFAULTRUN=${DEFAULTRUNARRAY[1]}

#starting making the files
NPROCESSEDFILES=0
#Needed to make subruns always start at 1
let "SUBRUNCANDIDATE= 0"
while [[ $NPROCESSEDFILES -lt $NFILES ]]
do
#Do arithmetic to modulo-ise the run number and subrun number whilst making sure subrun always starts at 1
  let "SUBRUNCANDIDATE++"
  RUNINCREMENT=`python -c "print $SUBRUNCANDIDATE//$NSUBRUNSPERRUN"`
  let "RUNNUMBER= $DEFAULTRUN + $RUNINCREMENT"
  SUBRUNNUMBER=`python -c "print $SUBRUNCANDIDATE % $NSUBRUNSPERRUN"`
#Never let subrun be 0
  if [[ $SUBRUNNUMBER -eq 0 ]]
  then
   continue
  fi
#We now have  run and subrun number
#make the fcl
  OUTFCL="${FCL%.*}_run${RUNNUMBER}_subrun${SUBRUNNUMBER}.fcl"
  if [ -e $WORKDIR/$OUTFCL ]
  then
    rm $WORKDIR/$OUTFCL
  fi
  echo "Producing $WORKDIR/$OUTFCL"
  echo -e "#include \"$FCL\"\n" \
          "source.firstRun: $RUNNUMBER\n" \
          "source.firstSubRun: $SUBRUNNUMBER" >> $WORKDIR/$OUTFCL
  ifdh addOutputFile $WORKDIR/$OUTFCL
  ifdh renameOutput unique
  UNIQUEOUTFCL=`find $WORKDIR -name ${OUTFCL%.*}*`
  UNIQUEOUTFCL=`basename $UNIQUEOUTFCL`
  ifdh copyBackOutput $OUTDIR
  ifdh cleanup

echo $name

  #Now make a json
  echo -e "
  {
      \"file_type\": \"mc\",
      \"group\": \"sbnd\",
      \"fcl.name\": \"$FCL\",
      \"sbnd_project.name\": \"${FCL%.*}\",
      \"sbnd_project.stage\": \"fcl\",
      \"sbnd_project.version\": \"v06_70_01_01_SBNWorkshop0318\",
      \"sbnd_project.software\": \"sbndcode\",
      \"production.name\": \"SBNWorkshop0318\",
      \"production.type\": \"workshop\",
      \"data_tier\": \"fcl\",
      \"file_format\": \"fcl\",
      \"start_time\": \"`date +"%FT%T"`\",
      \"end_time\": \"`date +"%FT%T"`\",
      \"runs\": [ [ $RUNNUMBER, $SUBRUNNUMBER, \"physics\" ] ],
      \"event_count\": 0,
  \"first_event\":  -9999 ,
  \"last_event\":  -9999 ,
  \"group\": \"sbnd\",
    \"file_name\": \"$UNIQUEOUTFCL\",
    \"file_size\": \"`wc -c < $WORKDIR/$UNIQUEOUTFCL`\",
    \"checksum\": 
      `ifdh checksum $WORKDIR/$UNIQUEOUTFCL`
    
  }
  " >> $WORKDIR/${UNIQUEOUTFCL}.json
  let "NPROCESSEDFILES++"
done
  echo $name

##Calculate how much to increment the run by
#RUNINCREMENT=`python -c "print $SUBRUNCANDIDATE//$NSUBRUNSPERRUN"`
##Calculate the run number
#let "RUNNUMBER= $DEFAULTRUN + $RUNINCREMENT"
##Now the subrun
#SUBRUNNUMBER=`python -c "print $SUBRUNCANDIDATE % $NSUBRUNSPERRUN"`
#echo "#Metadata injection by $0" >> $FCL
#echo "source.firstRun: $RUNNUMBER" >> $FCL
#echo "source.firstSubRun: $SUBRUNNUMBER" >> $FCL
