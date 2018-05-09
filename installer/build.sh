#!/bin/sh

# build.sh - script to build Crostini self-extracting archive
##############################################################
## To retrieve this file enter:                             ## 
## curl -L# http://snip.li/qyfns   -o Crostini-extractor.sh ##
##############################################################

PREFIX='Crostini'

echo "Building $PREFIX-extractor"

cd $PREFIX
tar czf ../$PREFIX.tar.gz ./*
cd ..

if [ -e "$PREFIX.tar.gz" ]; then
    cat decomp.sh $PREFIX.tar.gz > $PREFIX-extractor.sh
else
    echo "$PREFIX.tar.gz does not exist - Aborting!"
    exit 1
fi

exit 0
