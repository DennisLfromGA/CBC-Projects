#!/bin/bash

############################################################
## To retrieve this file enter one of the below: ########### 
## curl -L http://bit.ly/2HAM6TH -o Crostini-extractor.sh ##
## wget -q http://bit.ly/2HAM6TH -O Crostini-extractor.sh ##
############################################################

echo "Self Extracting Installer"
echo ""

export TMPDIR=`mktemp -d /tmp/selfextract.XXXXXX`

ARCHIVE=`awk '/^__ARCHIVE_BELOW__/ {print NR + 1; exit 0; }' $0`

tail -n+$ARCHIVE $0 | tar xzv -C $TMPDIR
echo ""

CDIR=`pwd`
cd $TMPDIR
sh ./installer.sh

cd $CDIR
#rm -rf $TMPDIR

exit 0

__ARCHIVE_BELOW__
