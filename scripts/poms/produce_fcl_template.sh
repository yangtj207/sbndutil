#!/bin/bash

FCL={gen-fcl-name}.fcl
FCLNAME={gen-fcl-name}
NFILES={number-of-files-with-100-events-per-file}
MDPRODNAME={production-name}
OUTDIR=/pnfs/sbnd/persistent/sbndpro/initialfcl
WORKDIR=/sbnd/app/users/sbndpro/fcl_gen/$MDPRODNAME/$FCLNAME/
MDPROJVER={version}
MDPRODTYPE=official
MDSTAGENAME=gen

sbndpoms_genfclwithrunnumber_maker.sh --fcl $FCL --outdir $OUTDIR --nfiles $NFILES --workdir $WORKDIR --mdprojver $MDPROJVER --mdprodname $MDPRODNAME --mdprodtype $MDPRODTYPE --mdstagename $MDSTAGENAME --samdeclare
#sbndpoms_genfclwithrunnumber_maker.sh --fcl $FCL --outdir $OUTDIR --nfiles $NFILES --workdir $WORKDIR --mdprojver $MDPROJVER --mdprodname $MDPRODNAME --mdprodtype $MDPRODTYPE --mdstagename $MDSTAGENAME
#sbndpoms_genfclwithrunnumber_maker.sh --fcl prodgenie_nu_singleinteraction_tpc_gsimple-configf-v1.fcl --outdir /pnfs/sbnd/persistent/sbndpro/initialfcl --nfiles 5 --workdir $PWD --mdprojver v08_08_00_i2_MCP1_0 --mdprodname MCP2.0 --mdprodtype official --mdstagename 5
