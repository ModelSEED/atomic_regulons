#!/bin/bash
if [ -d "SEEDtk" ]; then
    rmdir SEEDtk
    #source SEEDtk/user-env.sh
#else
    git clone https://github.com/SEEDtk/seedtk.git SEEDtk
    cd SEEDtk
    ./seedtk-setup
    source user-env.sh
    mkdir Data
    perl Config.pl --dirs --dna=none --dbhost=db3.chicago.kbase.us --dbpass=when26crazy --dbuser=seedtk --dbname=seedtk_shrub --kbase=../lib/FIG_Config.pm Data
    cd Data/Global

fi
