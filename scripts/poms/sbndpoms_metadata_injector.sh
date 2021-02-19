#!/bin/bash

#Take in all of the arguments
while :; do
    case $1 in
        -h|-\?|--help)
            show_help    # Display a usage synopsis.
            exit
            ;;
        --mdappfamily)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                MDAPPFAMILY="$2"
                shift
            else
                echo "$0 ERROR: mdappfamily requires a non-empty option argument."
                exit 1
            fi
            ;;

        --mdappversion)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                MDAPPVERSION="$2"
                shift
            else
                echo "$0 ERROR: mdappversion requires a non-empty option argument."
                exit 1
            fi
            ;;

        --inputfclname)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                INPUTFCLNAME="$2"
                shift
            else
                echo "$0 ERROR: inputfclname requires a non-empty option argument."
                exit 1
            fi
            ;;

        --mdfiletype)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                MDFILETYPE="$2"
                shift
            else
                echo "$0 ERROR: mdfiletype requires a non-empty option argument."
                exit 1
            fi
            ;;
        --mdruntype)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                MDRUNTYPE="$2"
                shift
            else
                echo "$0 ERROR: mdruntype requires a non-empty option argument."
                exit 1
            fi
            ;;
        --mdgroupname)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                MDGROUPNAME="$2"
                shift
            else
                echo "$0 ERROR: mdgroupname requires a non-empty option argument."
                exit 1
            fi
            ;;
        --mdfclname)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                MDFCLNAME="$2"
                shift
            else
                echo "$0 ERROR: mdfclname requires a non-empty option argument."
                exit 1
            fi
            ;;
        --mdprojectname)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                MDPROJECTNAME="$2"
                shift
            else
                echo "$0 ERROR: mdprojectname requires a non-empty option argument."
                exit 1
            fi
            ;;
        --mdprojectstage)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                MDPROJECTSTAGE="$2"
                shift
            else
                echo "$0 ERROR: mdprojectstage requires a non-empty option argument."
                exit 1
            fi
            ;;
        --mdprojectversion)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                MDPROJECTVERSION="$2"
                shift
            else
                echo "$0 ERROR: mdprojectversion requires a non-empty option argument."
                exit 1
            fi
            ;;
        --mdprojectsoftware)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                MDPROJECTSOFTWARE="$2"
                shift
            else
                echo "$0 ERROR: mdprojectsoftware requires a non-empty option argument."
                exit 1
            fi
            ;;
        --mdproductionname)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                MDPRODUCTIONNAME="$2"
                shift
            else
                echo "$0 ERROR: mdproductionname requires a non-empty option argument."
                exit 1
            fi
            ;;
        --mdproductiontype)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                MDPRODUCTIONTYPE="$2"
                shift
            else
                echo "$0 ERROR: mdproductiontype requires a non-empty option argument."
                exit 1
            fi
            ;;
        --tfilemdjsonname)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                TFILEMDJSONNAME="$2"
                shift
            else
                echo "$0 ERROR: tfilemdjsonname requires a non-empty option argument."
                exit 1
            fi
            ;;
        --cafname)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                CAFNAME="$2"
                shift
            else
                echo "$0 ERROR: cafname requires a non-empty option argument."
                exit 1
            fi
            ;;
#
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

if [ -z "$MDAPPFAMILY" ]; then
  echo "$0 ERROR: mdappfamily is mandatory"
  exit 2
fi

if [ -z "$MDAPPVERSION" ]; then
  echo "$0 ERROR: mdappversion is mandatory"
  exit 2
fi

if [ -z "$INPUTFCLNAME" ]; then
  echo "$0 ERROR: inputfclname is mandatory"
  exit 2
fi

if [ -z "$MDFILETYPE" ]; then
  echo "$0 ERROR: mdfiletype is mandatory"
  exit 2
fi

if [ -z "$MDRUNTYPE" ]; then
  echo "$0 ERROR: mdruntype is mandatory"
  exit 2
fi

if [ -z "$MDGROUPNAME" ]; then
  echo "$0 ERROR: mdgroupname is mandatory"
  exit 2
fi

if [ -z "$MDFCLNAME" ]; then
  echo "$0 ERROR: mdfclname is mandatory"
  exit 2
fi

if [ -z "$MDPROJECTNAME" ]; then
  echo "$0 ERROR: mdprojectname is mandatory"
  exit 2
fi

if [ -z "$MDPROJECTSTAGE" ]; then
  echo "$0 ERROR: mdprojectstage is mandatory"
  exit 2
fi

if [ -z "$MDPROJECTVERSION" ]; then
  echo "$0 ERROR: mdprojectverson is mandatory"
  exit 2
fi

if [ -z "$MDPROJECTSOFTWARE" ]; then
  echo "$0 ERROR: mdprojectsoftware is mandatory"
  exit 2
fi

if [ -z "$MDPRODUCTIONNAME" ]; then
  echo "$0 ERROR: mdproductionname is mandatory"
  exit 2
fi

if [ -z "$MDPRODUCTIONTYPE" ]; then
  echo "$0 ERROR: mdproductiontype is mandatory"
  exit 2
fi

#Start the injection
echo -e "\n#Metadata injection by $0" >> $INPUTFCLNAME
echo "services.FileCatalogMetadata.applicationFamily: \"$MDAPPFAMILY\"" >> $INPUTFCLNAME
echo "services.FileCatalogMetadata.applicationVersion: \"$MDAPPVERSION\"" >> $INPUTFCLNAME
echo "services.FileCatalogMetadata.fileType: \"$MDFILETYPE\"" >> $INPUTFCLNAME
echo "services.FileCatalogMetadata.runType: \"$MDRUNTYPE\"" >> $INPUTFCLNAME
echo "services.FileCatalogMetadata.group: \"$MDGROUPNAME\"" >> $INPUTFCLNAME
echo "services.FileCatalogMetadataSBND.FCLName: \"$MDFCLNAME\"" >> $INPUTFCLNAME
echo "services.FileCatalogMetadataSBND.ProjectName: \"$MDPROJECTNAME\"" >> $INPUTFCLNAME
echo "services.FileCatalogMetadataSBND.ProjectStage: \"$MDPROJECTSTAGE\"" >> $INPUTFCLNAME
echo "services.FileCatalogMetadataSBND.ProjectVersion: \"$MDPROJECTVERSION\"" >> $INPUTFCLNAME
echo "services.FileCatalogMetadataSBND.ProjectSoftware: \"$MDPROJECTSOFTWARE\"" >> $INPUTFCLNAME
echo "services.FileCatalogMetadataSBND.ProductionName: \"$MDPRODUCTIONNAME\"" >> $INPUTFCLNAME
echo "services.FileCatalogMetadataSBND.ProductionType: \"$MDPRODUCTIONTYPE\"" >> $INPUTFCLNAME
#only include the TFile metadata json production if the name of the json has been specified
if [ "$TFILEMDJSONNAME" ]; then
  echo "services.TFileMetadataSBND: @local::sbnd_file_catalog_tfile" >> $INPUTFCLNAME
  echo "services.TFileMetadataSBND.JSONFileName: \"$TFILEMDJSONNAME\"" >> $INPUTFCLNAME
  echo "services.TFileMetadataSBND.GenerateTFileMetadata: true" >> $INPUTFCLNAME
fi
# If we want to make caf files in production, lets set the output name here also
if [ "$CAFNAME" ]
then
  echo "physics.producers.mycafmaker.CAFFilename: \"$CAFNAME\"" >> $INPUTFCLNAME
fi
