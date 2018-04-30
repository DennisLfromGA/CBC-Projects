#!/bin/sh

# Crostini-extractor.sh - Crostini archive file.
############################################################
## To retrieve this file enter:                           ## 
## curl -L# http://snip.li/qyfns -o Crostini-extractor.sh ##
############################################################

# Built from:
# decomp.sh - Decompression script for Crostini archive file.
################################################
## To retrieve this file enter:               ## 
## curl -L# http://snip.li/rlnxe -o decomp.sh ##
################################################

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
rm -rf $TMPDIR

exit 0

__ARCHIVE_BELOW__
