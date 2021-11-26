#!/bin/bash

for FILE in $(samweb -e sbnd list-definition-files test_3_official_test_MCP2021C_test_prodoverlay_corsika_cosmics_proton_genie_fullosc_spill_gsimple-configh-v1_tpc_reco2_caf_sbnd); 
do 
  RUN=$(samweb -e sbnd get-metadata $FILE | grep Runs |  cut -d" " -f19); 
  if [[ $(samweb -e sbnd list-files "defname: test_3_official_test_MCP2021C_test_prodoverlay_corsika_cosmics_proton_genie_fullosc_spill_gsimple-configh-v1_tpc_reco2_caf_sbnd and run_number $RUN" | wc -l) -gt 1 ]]
  then
    echo $FILE
    LOC=$(samweb -e sbnd get-file-access-url $FILE)
    ifdh rm $LOC
    samweb -e sbnd retire-file $FILE
  fi
done
