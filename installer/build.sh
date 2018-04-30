#!/bin/sh

# build.sh - script to build Crostini self-extracting archive
##############################################################
## To retrieve this file enter:                             ## 
## curl -L# http://snip.li/qyfns   -o Crostini-extractor.sh ##
##############################################################

PREFIX='Crostini'

echo "Building $PREFIX-extractor"

cd $PREFIX
tar cf ../$PREFIX.tar ./*
cd ..

if [ -e "$PREFIX.tar" ]; then
    gzip $PREFIX.tar

    if [ -e "$PREFIX.tar.gz" ]; then
        cat decomp.sh $PREFIX.tar.gz > $PREFIX-extractor.sh
    else
        echo "$PREFIX.tar.gz does not exist - Aborting!"
        exit 1
    fi
else
    echo "$PREFIX.tar does not exist - Aborting!"
    exit 1
fi

exit 0
