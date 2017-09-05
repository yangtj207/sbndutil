#! /bin/bash
#----------------------------------------------------------------------
#
# Name: make_xml_mcc1.0.sh
#
# Purpose: Make xml files for mcc 1.0.  This script loops over all
#          generator-level fcl files in the source area of the currently 
#          setup version of sbndcode (that is, under 
#          $SBNDCODE_DIR/source/fcl/gen), and makes a corresponding xml
#          project file in the local directory.
#
# Usage:
#
# make_xml_mcc1.0.sh [-h|--help] [-r <release>] [-u|--user <user>] [--local <dir|tar>] [--nev <n>] [--nevjob <n>] [--nevgjob <n>]
#
# Options:
#
# -h|--help     - Print help.
# -r <release>  - Use the specified larsoft/sbndcode release.
# -u|--user <user> - Use users/<user> as working and output directories
#                    (default is to use sbndpro).
# --local <dir|tar> - Specify larsoft local directory or tarball (xml 
#                     tag <local>...</local>).
# --nev <n>     - Specify number of events for all samples.  Otherwise
#                 use hardwired defaults.
# --nevjob <n>  - Specify the default number of events per job.
# --nevgjob <n> - Specify the maximum number of events per gen/g4 job.
#
#----------------------------------------------------------------------

function print_xml_to_file {

  echo "Making ${newxml}"

  cat <<EOF > $newxml
  <?xml version="1.0"?>
  
  <!-- Production Project -->
  
  <!DOCTYPE project [
  <!ENTITY release "$rel">
  <!ENTITY file_type "mc">
  <!ENTITY run_type "physics">
  <!ENTITY name "$newprj">
  <!ENTITY tag "mcc1.0">
  ]>
  
  <project name="&name;">
  
    <!-- Project size -->
    <numevents>$nev</numevents>
  
    <!-- Operating System -->
    <os>SL6</os>
  
    <!-- Batch resources -->
    <resource>DEDICATED,OPPORTUNISTIC</resource>
  
    <!-- Larsoft information -->
    <larsoft>
      <tag>&release;</tag>
      <qual>${qual}</qual>
EOF
    if [ x$local != x ]; then
      echo "local=$local"
      echo "    <local>${local}</local>" >> $newxml
    fi
cat <<EOF >> $newxml
    </larsoft>
  
    <!-- Project stages -->
  
    <stage name="gen">
      <fcl>$genfcl</fcl>
      <outdir>/pnfs/sbnd/persistent/${userdir}/&tag;/&release;/&name;/gen</outdir>
      <workdir>/pnfs/sbnd/persistent/${userdir}/&tag;/&release;/work/&name;/gen</workdir>
      <numjobs>$njob1</numjobs>
      <datatier>generated</datatier>
      <defname>&name;_&tag;_gen</defname>
    </stage>
  
    <stage name="g4">
      <fcl>$g4fcl</fcl>
      <outdir>/pnfs/sbnd/persistent/${userdir}/&tag;/&release;/&name;/g4</outdir>
      <workdir>/pnfs/sbnd/persistent/${userdir}/&tag;/&release;/work/&name;/g4</workdir>
      <numjobs>$njob1</numjobs>
      <datatier>simulated</datatier>
      <defname>&name;_&tag;_g4</defname>
    </stage>
  
    <stage name="detsim">
      <fcl>$detsimfcl</fcl>
      <outdir>/pnfs/sbnd/persistent/${userdir}/&tag;/&release;/&name;/detsim</outdir>
      <workdir>/pnfs/sbnd/persistent/${userdir}/&tag;/&release;/work/&name;/detsim</workdir>
      <numjobs>$njob2</numjobs>
      <datatier>detector-simulated</datatier>
      <defname>&name;_&tag;_detsim</defname>
    </stage>
  
    <stage name="reco">
      <fcl>$recofcl</fcl>
      <outdir>/pnfs/sbnd/persistent/${userdir}/&tag;/&release;/&name;/reco</outdir>
      <workdir>/pnfs/sbnd/persistent/${userdir}/&tag;/&release;/work/&name;/reco</workdir>
      <numjobs>$njob2</numjobs>
      <datatier>reconstructed</datatier>
      <defname>&name;_&tag;_reco</defname>
    </stage>
  
    <stage name="anatree">
      <fcl>$anatreefcl</fcl>
      <outdir>/pnfs/sbnd/persistent/${userdir}/&tag;/&release;/&name;/anatree</outdir>
      <workdir>/pnfs/sbnd/persistent/${userdir}/&tag;/&release;/work/&name;/anatree</workdir>
      <numjobs>$njob2</numjobs>
      <targetsize>8000000000</targetsize>
      <datatier>reconstructed</datatier>
      <defname>&name;_&tag;</defname>
    </stage>
  
    <!-- file type -->
    <filetype>&file_type;</filetype>
  
    <!-- run type -->
    <runtype>&run_type;</runtype>
  
  </project>
EOF
}

function set_default_fcl { 
  # G4
  g4fcl=standard_g4_sbnd.fcl

  # Detsim (optical + tpc).
  detsimfcl=standard_detsim_sbnd.fcl

  # Reco 
  recofcl=standard_reco_sbnd.fcl

  # Anatree 
  anatreefcl=standard_ana_sbnd.fcl
}


#Parse arguments.

rel=v00_07_00
userdir=sbndpro
qual=e9:prof
userbase=$userdir
nevarg=0
nevjob=100
nevgjobarg=0
local=''

while [ $# -gt 0 ]; do
  case "$1" in

    # User directory.

    -h|--help )
      echo "Usage: make_xml_mcc1.0.sh [-h|--help] [-r <release>] [-q <qual>] [-u|--user <user>] [--local <dir|tar>] [--nev <n>] [--nevjob <n>] [--nevgjob <n>]"
      exit
    ;;

    # Release.

    -r )
    if [ $# -gt 1 ]; then
      rel=$2
      shift
    fi
    ;;

    # Qualifier.

    -q)
    if [ $# -gt 1 ]; then
      qual=$2
      shift
    fi
    ;;


    # User.

    -u|--user )
    if [ $# -gt 1 ]; then
      userdir=users/$2
      userbase=$2
      shift
    fi
    ;;

    # Local release.

    --local )
    if [ $# -gt 1 ]; then
      local=$2
      shift
    fi
    ;;

    # Total number of events.

    --nev )
    if [ $# -gt 1 ]; then
      nevarg=$2
      shift
    fi
    ;;

    # Number of events per job.

    --nevjob )
    if [ $# -gt 1 ]; then
      nevjob=$2
      shift
    fi
    ;;

    # Number of events per gen/g4 job.

    --nevgjob )
    if [ $# -gt 1 ]; then
      nevgjobarg=$2
      shift
    fi
    ;;

  esac
  shift
done

# Get qualifier.

#qual=e9

# Delete existing xml files.

rm -f *.xml

# Loop over existing generator fcl files.

find $SBNDCODE_DIR/source/fcl/gen -name \*.fcl | while read fcl
do
  if ! echo $fcl | grep -q common; then
    newprj=`basename $fcl .fcl`
    newxml=${newprj}.xml
    filt=1

    # Make xml file.



    # Set number of gen/g4 events per job.

    nevgjob=$nevgjobarg
    if [ $nevgjob -eq 0 ]; then
      if echo $newprj | grep -q dirt; then
        if echo $newprj | grep -q cosmic; then
          nevgjob=200
        else
          nevgjob=2000
        fi
      else
        nevgjob=nevjob
      fi
    fi

    # Set number of events.

    nev=$nevarg
    if [ $nev -eq 0 ]; then
      if [ $newprj = prodgenie_bnb_nu_cosmic_sbnd ]; then
        nev=50000
      elif [ $newprj = prodgenie_bnb_nu_sbnd ]; then
        nev=20000
      elif [ $newprj = prodgenie_bnb_nue_cosmic_sbnd ]; then
        nev=20000
      elif [ $newprj = prodgenie_bnb_nue_sbnd ]; then
        nev=20000
      elif [ $newprj = prodcosmics_sbnd ]; then
        nev=20000
      else
        nev=10000
      fi
    fi
    nev=$(( $nev * $filt ))

    # Calculate the number of worker jobs.

    njob1=$(( $nev / $nevgjob ))         # Pre-filter (gen, g4)
    njob2=$(( $nev / $nevjob / $filt ))  # Post-filter (detsim and later)
    if [ $njob1 -lt $njob2 ]; then
      njob1=$njob2
    fi



    # Define the generator-level fcl
    genfcl=`basename $fcl`
    #Assume that we are going to produce this sample with the default fcls
    makedefaultsample=true
    #Loop over the MCCSTATEMENTs in this fcl file to figure out what alternative samples need making
    grep "MCCSTATEMENT" $fcl | 
    {  #being the moron I am, I forgot that a while loop uses a subshell.  I want to maybe 
       #change the value of makedefaultsample and check it outside of the loop.  So
       #complete hack; wrap from here to the final makedefaultsample check in braces
       #so it is all in the same subshell.  Basically not having the braces means that
       #makedefaultsample will evaluate to true outside of this while loop
    while read mccstatement
    do
      #At time of writing, the MCCSTATEMENT should define an altnerative set of fcl files to 
      #process this particular sample through.  Technically each MCCSTATEMENT line is a 
      #comma separated list of fcl files and a name for the alternative project.  The first element in the 
      #comma separated list is a pair of statements separated by white space, the second of the pair is the 
      #name of the project.  All subsequent elements in the list are also pairs separated by white space.
      #The first element defines which stage to change the fcl file and can have the following names: G4:
      #DETSIM: RECO: and ANATREE:.

      #It is also possible that one of the statement lines asks us not to make the default sample path
      #Check for this and set the flag to false if necessary
      if echo $mccstatement | grep -q SKIPDEFAULT; then
        makedefaultsample=false
        #There shouldn't be anything else useful on this line so continue to the next statement
        continue
      fi

      #For each new MCCSTATEMENT line we should initially reset the fcl files
      set_default_fcl
      #Also reset the project name to that of the default sample as otherwise the new project names keep 
      #getting appended to the previous new project name
      newprj=`basename $fcl .fcl`
      newxml=${newprj}.xml

      #Delimit the MCCSTATEMENT line on the commas
      IFS=','
      statementarray=($mccstatement)
      unset IFS
      for statementelement in "${statementarray[@]}"
      do
        #The statementelement should be a string pair basically with a key and a value.  This time
        #separated by whitespace
        pair=($statementelement)
        key=${pair[0]}
        value=${pair[1]}
        if echo $key | grep -q MCCSTATEMENT; then
          newprj="${newprj}_${value}"
          newxml=${newprj}.xml
        elif echo $key | grep -q G4; then
          g4fcl=$value
        elif echo $key | grep -q DETSIM; then
          detsimfcl=$value
        elif echo $key | grep -q RECO; then
          recofcl=$value
        elif echo $key | grep -q ANATREE; then
          anatreefcl=$value
        else echo "ISSUE WITH MCCSTATEMENT IN $newprj.  CAN NOT FIND THE SET STATEMENTS (MCCSTATEMENT G4 DETSIM RECO OR ANATREE)"
        fi
      done
      #make an XML file for each MCCSTATEMENT line
      print_xml_to_file

    done
    #if we still want to make the default file then make the XML
    if [ "$makedefaultsample"=true ] ; then

      newprj=`basename $fcl .fcl` #reset the newprj back to the default project
      newxml=${newprj}.xml
      set_default_fcl
      print_xml_to_file
    fi
    } #while loop subshell
  fi

done
