#!/bin/bash

#source.firstSubRun: 1
#Subrun follows $PROCESS+1
#After every 100 subruns, a new run is started
export NSUBRUNSPERRUN=100

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
#        --file=?*)
#            file=${1#*=} # Delete everything up to "=" and assign the remainder.
#            ;;
#        --file=)         # Handle the case of an empty --file=
#            echo 'ERROR: "--file" requires a non-empty option argument.'
#            ;;
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

#We need to extract what the default run number is.  Let's get this from running lar and dumping the config
lar --debug-config lar_config_dump.txt -c $FCL
DEFAULTRUN=`grep -r "firstRun" lar_config_dump.txt`
#THis line is of the form firstRun: RUN
#We need to extract RUN
#Delimit on the colon
IFS=\: read -a DEFAULTRUNARRAY <<<"$DEFAULTRUN"
#Extract the run number
DEFAULTRUN=${DEFAULTRUNARRAY[1]}
#Get the subrun candidate number.  We will need to do some modulo arithmetic to work out the actual run and subrun numbers
let "SUBRUNCANDIDATE= $PROCESS +1"
#Calculate how much to increment the run by
RUNINCREMENT=`python -c "print $SUBRUNCANDIDATE//$NSUBRUNSPERRUN"`
#Calculate the run number
let "RUNNUMBER= $DEFAULTRUN + $RUNINCREMENT"
#Now the subrun
SUBRUNNUMBER=`python -c "print $SUBRUNCANDIDATE % $NSUBRUNSPERRUN"`
echo "#Metadata injection by $0" >> $FCL
echo "source.firstRun: $RUNNUMBER" >> $FCL
echo "source.firstSubRun: $SUBRUNNUMBER" >> $FCL
